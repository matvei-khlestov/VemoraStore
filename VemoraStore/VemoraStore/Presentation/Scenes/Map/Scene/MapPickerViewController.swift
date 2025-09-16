//
//  MapPickerViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import MapKit
import CoreLocation
import FactoryKit

final class MapPickerViewController: UIViewController {
    
    // MARK: - ViewModel
    
    private let viewModel: MapPickerViewModelProtocol = Container.shared.mapPickerViewModel()
    
    // MARK: - Callbacks
    
    var onBack: (() -> Void)?
    var onAddressComposed: ((String) -> Void)?
    
    // MARK: - UI
    
    private let mapView = MKMapView()
    
    // три кнопки справа: гео, +, −
    private let locateButton: UIButton = {
        let b = UIButton(type: .system)
        b.setImage(UIImage(systemName: "location.fill"), for: .normal)
        b.tintColor = .brightPurple
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 22
        b.layer.shadowOpacity = 0.08
        b.layer.shadowRadius = 6
        b.layer.shadowOffset = .init(width: 0, height: 2)
        b.widthAnchor.constraint(equalToConstant: 44).isActive = true
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return b
    }()
    
    private let zoomInButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("+", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        b.tintColor = .brightPurple
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 8
        b.widthAnchor.constraint(equalToConstant: 44).isActive = true
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return b
    }()
    
    private let zoomOutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("−", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 22, weight: .bold)
        b.tintColor = .brightPurple
        b.backgroundColor = .systemBackground
        b.layer.cornerRadius = 8
        b.widthAnchor.constraint(equalToConstant: 44).isActive = true
        b.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return b
    }()
    
    private let centerPin: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "mappin.circle.fill"))
        iv.tintColor = .brightPurple
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    // MARK: - Location
    
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNavigationBar()
        setupMap()
        setupRightButtons()
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
    
    func setupNavigationBar() {
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = .backItem(
            target: self,
            action: #selector(backTapped),
            tintColor: .brightPurple
        )
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func setupMap() {
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        mapView.delegate = self
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // центровой пин
        view.addSubview(centerPin)
        NSLayoutConstraint.activate([
            centerPin.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerPin.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            centerPin.widthAnchor.constraint(equalToConstant: 32),
            centerPin.heightAnchor.constraint(equalToConstant: 32)
        ])
    }
    
    func setupRightButtons() {
        let stack = UIStackView(arrangedSubviews: [zoomInButton, zoomOutButton, locateButton])
        stack.axis = .vertical
        stack.spacing = 15
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            stack.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -180)
        ])
    }
    
    func setupActions() {
        zoomInButton.addTarget(self, action: #selector(zoomInTapped), for: .touchUpInside)
        zoomOutButton.addTarget(self, action: #selector(zoomOutTapped), for: .touchUpInside)
        locateButton.addTarget(self, action: #selector(locateTapped), for: .touchUpInside)
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
        // Do not startUpdatingLocation here; wait for authorization callback
    }
    
    func presentAddressSheet(with text: String?) {
        let sheet = AddressConfirmSheetViewController()
        sheet.address = text
        // передаём регион карты для подсказок и поиска
        sheet.searchRegion = mapView.region
        
        // когда пользователь выбирает адрес или жмёт Return — центрируем карту и сворачиваемся
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
            // Передаём наружу (в координатор/Checkout)
            self.onAddressComposed?(full)
            
            // Закрываем любые представленные поверх шиты (если ещё открыты)
            self.presentedViewController?.dismiss(animated: true)
        }
        
        self.addressSheet = sheet
        present(sheet, animated: true)
    }
    
    func updateAddressSheet(with text: String) {
        // Не обновляем, если пользователь сейчас редактирует адрес вручную
        guard !isSheetEditing else { return }
        addressSheet?.address = text
    }
    
    private func centerMap(on coordinate: CLLocationCoordinate2D, meters: CLLocationDistance = 600) {
        isProgrammaticMove = true
        let region = MKCoordinateRegion(center: coordinate,
                                        latitudinalMeters: meters,
                                        longitudinalMeters: meters)
        mapView.setRegion(region, animated: true)
        // trigger geocode once after the camera move completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.isProgrammaticMove = false
            self?.reverseGeocodeCenterAndFillSheet()
        }
    }
    
    private func reverseGeocodeCenterAndFillSheet() {
        let center = currentCenterLocation.coordinate
        viewModel.onRegionDidChange(center: center)
    }
    
    private func performReverseGeocode(at coordinate: CLLocationCoordinate2D) {
        viewModel.onRegionDidChange(center: coordinate)
    }
}

func clampedSpan(_ span: MKCoordinateSpan) -> MKCoordinateSpan {
    let minDelta = 0.0001
    let maxDelta = 180.0
    let lat = min(max(span.latitudeDelta, minDelta), maxDelta)
    let lon = min(max(span.longitudeDelta, minDelta), maxDelta)
    return MKCoordinateSpan(latitudeDelta: lat, longitudeDelta: lon)
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

// MARK: - Геокодинг

private extension MapPickerViewController {
    var currentCenterLocation: CLLocation {
        CLLocation(latitude: mapView.centerCoordinate.latitude,
                   longitude: mapView.centerCoordinate.longitude)
    }
}

// MARK: - CLLocationManagerDelegate

extension MapPickerViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        viewModel.onLocationAuthChanged(status, manager: manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        viewModel.onLocationsUpdated(locations, manager: manager)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        viewModel.onLocationFailed(error)
    }
}

extension MapPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard !isSheetEditing, !isProgrammaticMove else { return }
        viewModel.onRegionDidChange(center: mapView.centerCoordinate)
    }
}

// MARK: - Хранилки

private extension MapPickerViewController {
    // чтобы собрать Address при подтверждении
    var currentCityKey: String { "currentCityKey" }
    var currentStreetKey: String { "currentStreetKey" }
    
    private struct Holder {
        static var city: String?
        static var street: String?
    }
    
    var currentCity: String? {
        get { Holder.city }
        set { Holder.city = newValue }
    }
    var currentStreet: String? {
        get { Holder.street }
        set { Holder.street = newValue }
    }
}
