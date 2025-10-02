//
//  MapPickerViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import MapKit
import CoreLocation

final class MapPickerViewController: UIViewController {
    
    // MARK: - ViewModels
    
    private let viewModel: MapPickerViewModelProtocol
    private let makeAddressConfirmVM: () -> AddressConfirmSheetViewModelProtocol
    private let makeDeliveryDetailsVM: (String) -> DeliveryDetailsViewModelProtocol
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onAddressComposed: ((String) -> Void)?
    
    // MARK: - Metrics / Texts / Symbols
    
    private enum Metrics {
        enum Insets {
            static let side: CGFloat = 16
        }
        
        enum Spacing {
            static let rightButtonsStack: CGFloat = 15
        }
        
        enum Layout {
            static let rightButtonsCenterYOffset: CGFloat = -40
            static let rightStackTopMinFromSafe: CGFloat = 80
            static let rightStackBottomMinFromSafe: CGFloat = 180
        }
        
        enum Sizes {
            static let circleButton: CGFloat = 44
            static let squareButton: CGFloat = 44
            static let pinSide: CGFloat = 32
        }
        
        enum Corners {
            static let square: CGFloat = 8
            static let circle: CGFloat = 22
        }
        
        enum Shadows {
            static let opacity: Float = 0.08
            static let radius: CGFloat = 6
            static let offset: CGSize = .init(width: 0, height: 2)
        }
        
        enum Fonts {
            static let zoomButton: UIFont = .systemFont(ofSize: 22, weight: .bold)
        }
        
        enum Durations {
            static let cameraSettleDelay: TimeInterval = 0.35
        }
    }
    
    private enum Texts {
        static let zoomInTitle  = "+"
        static let zoomOutTitle = "−"
    }
    
    private enum Symbols {
        static let locationFill = "location.fill"
        static let centerPin    = "mappin.circle.fill"
    }
    
    // MARK: - UI
    
    private let mapView = MKMapView()
    
    // три кнопки справа: гео, +, −
    private let locateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: Symbols.locationFill), for: .normal)
        button.tintColor = .brightPurple
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = Metrics.Corners.circle
        button.layer.shadowOpacity = Metrics.Shadows.opacity
        button.layer.shadowRadius = Metrics.Shadows.radius
        button.layer.shadowOffset = Metrics.Shadows.offset
        button.widthAnchor.constraint(equalToConstant: Metrics.Sizes.circleButton).isActive = true
        button.heightAnchor.constraint(equalToConstant: Metrics.Sizes.circleButton).isActive = true
        return button
    }()
    
    private lazy var zoomInButton: UIButton = {
        Factory.makeSquareTextButton(
            title: Texts.zoomInTitle,
            font: Metrics.Fonts.zoomButton,
            tint: .brightPurple
        )
    }()
    
    private lazy var zoomOutButton: UIButton = {
        Factory.makeSquareTextButton(
            title: Texts.zoomOutTitle,
            font: Metrics.Fonts.zoomButton,
            tint: .brightPurple
        )
    }()
    
    private let rightButtonsStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = Metrics.Spacing.rightButtonsStack
        return stackView
    }()
    
    private let centerPin: UIImageView = {
        let imageView = UIImageView(image: UIImage(
            systemName: Symbols.centerPin
        ))
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .brightPurple
        return imageView
    }()
    
    // MARK: - Location/State
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var didShowSheet = false
    private weak var addressSheet: AddressConfirmSheetViewController?
    private var geocodeWorkItem: DispatchWorkItem?
    private var isSheetEditing = false
    
    private var lastGeocodeAt: Date = .distantPast
    private let minGeocodeInterval: TimeInterval = 1.5
    private var geocodeInFlight = false
    private var lastGeocodeCoordinate: CLLocationCoordinate2D?
    private var isProgrammaticMove = false
    
    // MARK: - Init
    
    init(
        viewModel: MapPickerViewModelProtocol,
        makeAddressConfirmVM: @escaping () -> AddressConfirmSheetViewModelProtocol,
        makeDeliveryDetailsVM: @escaping (String) -> DeliveryDetailsViewModelProtocol
    ) {
        self.viewModel = viewModel
        self.makeAddressConfirmVM = makeAddressConfirmVM
        self.makeDeliveryDetailsVM = makeDeliveryDetailsVM
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupActions()
        bindViewModel()
        requestLocation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.onViewDidAppear()
    }
}

// MARK: - Setup

private extension MapPickerViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
        setupNavigationBarWithNavLeftItem(
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
        
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.delegate = self
    }
    
    func setupHierarchy() {
        view.addSubviews(
            mapView,
            centerPin,
            rightButtonsStack
        )
        rightButtonsStack.addArrangedSubviews(
            zoomInButton,
            zoomOutButton,
            locateButton
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupMapAndPinConstraints()
        setupRightButtonsConstraints()
    }
    
    func setupActions() {
        zoomInButton.onTap(self, action: #selector(zoomInTapped))
        zoomOutButton.onTap(self, action: #selector(zoomOutTapped))
        locateButton.onTap(self, action: #selector(locateTapped))
    }
    
    func bindViewModel() {
        viewModel.requestPresentAddressSheet = { [weak self] text in
            self?.presentAddressSheet(with: text)
        }
        viewModel.requestCenterMap = { [weak self] coordinate, meters in
            self?.centerMap(on: coordinate, meters: meters)
        }
        viewModel.updateAddressText = { [weak self] text in
            self?.updateAddressSheet(with: text)
        }
    }
    
    func requestLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
    }
}

// MARK: - Layout

private extension MapPickerViewController {
    func prepareForAutoLayout() {
        [mapView, centerPin, rightButtonsStack].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupMapAndPinConstraints() {
        NSLayoutConstraint.activate([
            // карта
            mapView.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            mapView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            mapView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            mapView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            ),
            
            // пин в центре
            centerPin.centerXAnchor.constraint(
                equalTo: view.centerXAnchor
            ),
            centerPin.centerYAnchor.constraint(
                equalTo: view.centerYAnchor
            ),
            centerPin.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.pinSide
            ),
            centerPin.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.pinSide
            )
        ])
    }
    
    func setupRightButtonsConstraints() {
        NSLayoutConstraint.activate([
            rightButtonsStack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: -Metrics.Insets.side
            ),
            rightButtonsStack.centerYAnchor.constraint(
                equalTo: view.centerYAnchor,
                constant: Metrics.Layout.rightButtonsCenterYOffset
            ),
            rightButtonsStack.topAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,
                constant: Metrics.Layout.rightStackTopMinFromSafe
            ),
            rightButtonsStack.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Metrics.Layout.rightStackBottomMinFromSafe
            )
        ])
    }
}

// MARK: - Address Sheet
private extension MapPickerViewController {
    func presentAddressSheet(with text: String?) {
        let sheet = AddressConfirmSheetViewController(
            viewModel: makeAddressConfirmVM(),
            makeDeliveryDetailsVM: makeDeliveryDetailsVM
        )
        sheet.address = text
        sheet.searchRegion = mapView.region
        
        sheet.onAddressPicked = { [weak self] formatted, coordinate in
            guard let self else { return }
            self.centerMap(on: coordinate)
            self.updateAddressSheet(with: formatted)
        }
        
        sheet.onEditingChanged = { [weak self] isEditing in
            self?.isSheetEditing = isEditing
            self?.viewModel.setIsSheetEditing(isEditing)
        }
        
        sheet.onFullAddressComposed = { [weak self] full in
            guard let self else { return }
            self.onAddressComposed?(full)
            self.presentedViewController?.dismiss(animated: true)
        }
        
        addressSheet = sheet
        present(sheet, animated: true)
    }
    
    func updateAddressSheet(with text: String) {
        guard !isSheetEditing else { return }
        addressSheet?.address = text
    }
}

// MARK: - Map helpers
private extension MapPickerViewController {
    var currentCenterLocation: CLLocation {
        CLLocation(latitude: mapView.centerCoordinate.latitude,
                   longitude: mapView.centerCoordinate.longitude)
    }
    
    func centerMap(on coordinate: CLLocationCoordinate2D, meters: CLLocationDistance = 600) {
        isProgrammaticMove = true
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: meters,
                                        longitudinalMeters: meters)
        mapView.setRegion(region, animated: true)
        // триггерим обратное геокодирование после завершения движения камеры
        DispatchQueue.main.asyncAfter(deadline: .now() + Metrics.Durations.cameraSettleDelay) { [weak self] in
            self?.isProgrammaticMove = false
            self?.reverseGeocodeCenterAndFillSheet()
        }
    }
    
    func reverseGeocodeCenterAndFillSheet() {
        let center = currentCenterLocation.coordinate
        viewModel.onRegionDidChange(center: center)
    }
    
    func performReverseGeocode(at coordinate: CLLocationCoordinate2D) {
        viewModel.onRegionDidChange(center: coordinate)
    }
}

// MARK: - Actions

private extension MapPickerViewController {
    @objc func zoomInTapped() {
        let newRegion = viewModel.onZoomIn(currentRegion: mapView.region)
        mapView.setRegion(newRegion, animated: true)
    }
    
    @objc func zoomOutTapped() {
        let newRegion = viewModel.onZoomOut(currentRegion: mapView.region)
        mapView.setRegion(newRegion, animated: true)
    }
    
    @objc func locateTapped() {
        viewModel.onLocateTapped()
        requestLocation()
    }
    
    @objc func backTapped() {
        onBack?()
    }
}

// MARK: - CLLocationManagerDelegate

extension MapPickerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        viewModel.onLocationAuthChanged(status, manager: manager)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        viewModel.onLocationsUpdated(locations, manager: manager)
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        viewModel.onLocationFailed(error)
    }
}

// MARK: - MKMapViewDelegate

extension MapPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard !isSheetEditing, !isProgrammaticMove else { return }
        viewModel.onRegionDidChange(center: mapView.centerCoordinate)
    }
}

// MARK: - Free helpers

func clampedSpan(_ span: MKCoordinateSpan) -> MKCoordinateSpan {
    let minDelta = 0.0001
    let maxDelta = 180.0
    let lat = min(max(span.latitudeDelta, minDelta), maxDelta)
    let lon = min(max(span.longitudeDelta, minDelta), maxDelta)
    return MKCoordinateSpan(latitudeDelta: lat, longitudeDelta: lon)
}

// MARK: - Factory

private extension MapPickerViewController {
    enum Factory {
        static func makeSquareTextButton(
            title: String,
            font: UIFont,
            tint: UIColor
        ) -> UIButton {
            let b = UIButton(type: .system)
            b.setTitle(title, for: .normal)
            b.titleLabel?.font = font
            b.tintColor = tint
            b.backgroundColor = .systemBackground
            b.layer.cornerRadius = Metrics.Corners.square
            b.layer.shadowOpacity = Metrics.Shadows.opacity
            b.layer.shadowRadius = Metrics.Shadows.radius
            b.layer.shadowOffset = Metrics.Shadows.offset
            b.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                b.widthAnchor.constraint(equalToConstant: Metrics.Sizes.squareButton),
                b.heightAnchor.constraint(equalToConstant: Metrics.Sizes.squareButton)
            ])
            return b
        }
    }
}
