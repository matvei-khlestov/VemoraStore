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
        requestLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // показать шит один раз при первом попадании
        if !didShowSheet {
            didShowSheet = true
            presentAddressSheet(with: "Определяем адрес…")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.reverseGeocodeCenterAndFillSheet()
            }
        }
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
        // Throttle by time window and distance so we don't exceed Apple's 50/min cap
        let now = Date()
        let center = currentCenterLocation.coordinate

        // If last geocode was very recent, delay the execution instead of firing immediately
        let elapsed = now.timeIntervalSince(lastGeocodeAt)
        let scheduleDelay = max(0, minGeocodeInterval - elapsed)

        // If center hasn't moved meaningfully, skip
        if let prev = lastGeocodeCoordinate {
            let p1 = MKMapPoint(center)
            let p2 = MKMapPoint(prev)
            let meters = p1.distance(to: p2)
            if meters < 35 { return } // ignore tiny pans/zooms
        }

        geocodeWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.performReverseGeocode(at: center)
        }
        geocodeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + scheduleDelay, execute: work)
    }

    private func performReverseGeocode(at coordinate: CLLocationCoordinate2D) {
        guard !geocodeInFlight else { return }
        geocodeInFlight = true
        lastGeocodeAt = Date()
        lastGeocodeCoordinate = coordinate

        geocoder.cancelGeocode()
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        geocoder.reverseGeocodeLocation(loc, preferredLocale: Locale(identifier: "ru_RU")) { [weak self] placemarks, error in
            guard let self else { return }
            self.geocodeInFlight = false

            if let error = error as NSError? {
                // For transient errors: network / no result / partial result — soft retry once after interval
                if let clErr = error as? CLError,
                   [.network, .geocodeFoundNoResult, .geocodeFoundPartialResult].contains(clErr.code) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.minGeocodeInterval) { [weak self] in
                        self?.reverseGeocodeCenterAndFillSheet()
                    }
                } else {
                    self.updateAddressSheet(with: "Адрес не найден")
                }
                return
            }

            guard let p = placemarks?.first else {
                self.updateAddressSheet(with: "Адрес не найден")
                return
            }

            let city   = p.locality ?? p.administrativeArea ?? ""
            let street = p.thoroughfare ?? ""
            let house  = p.subThoroughfare ?? ""
            let formatted = [city, street, house].filter { !$0.isEmpty }.joined(separator: ", ")
            self.updateAddressSheet(with: formatted.isEmpty ? "Адрес не найден" : formatted)
        }
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
        var region = mapView.region
        region.span = clampedSpan(MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2,
                                                   longitudeDelta: region.span.longitudeDelta / 2))
        mapView.setRegion(region, animated: true)
    }

    @objc func zoomOutTapped() {
        var region = mapView.region
        region.span = clampedSpan(MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2,
                                                   longitudeDelta: region.span.longitudeDelta * 2))
        mapView.setRegion(region, animated: true)
    }

    @objc func locateTapped() {
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
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted:
            break
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        centerMap(on: loc.coordinate)
        manager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Можно показать тост/алерт, но пока просто оставим
        print("Location error:", error)
    }
}

extension MapPickerViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard !isSheetEditing, !isProgrammaticMove else { return }
        geocodeWorkItem?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.reverseGeocodeCenterAndFillSheet()
        }
        geocodeWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7, execute: work)
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
