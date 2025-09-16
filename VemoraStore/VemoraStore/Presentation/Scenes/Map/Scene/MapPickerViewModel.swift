//
//  MapPickerViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation
import CoreLocation
import MapKit
import FactoryKit

final class MapPickerViewModel: MapPickerViewModelProtocol {

    // MARK: - Deps
    private let geocoder: GeocodingServiceProtocol
    private let formatter: AddressFormattingProtocol
    private let locale: Locale

    // MARK: - State (бизнес-логика)
    private var didShowSheet = false
    private var isSheetEditing = false
    private var lastGeocodeAt: Date = .distantPast
    private var geocodeInFlight = false
    private var lastGeocodeCoordinate: CLLocationCoordinate2D?
    private var pendingWork: DispatchWorkItem?
    private let minGeocodeInterval: TimeInterval = 1.5
    private let minDistanceMeters: CLLocationDistance = 35

    // MARK: - Outputs
    var requestPresentAddressSheet: ((String?) -> Void)?
    var requestCenterMap: ((CLLocationCoordinate2D, CLLocationDistance) -> Void)?
    var updateAddressText: ((String) -> Void)?

    // MARK: - Init
    init(container: Container = .shared,
         locale: Locale = Locale(identifier: "ru_RU")) {
        self.geocoder = container.geocodingService()
        self.formatter = container.addressFormatter()
        self.locale = locale
    }

    // MARK: - Inputs
    func setIsSheetEditing(_ isEditing: Bool) {
        isSheetEditing = isEditing
    }

    func onViewDidAppear() {
        guard !didShowSheet else { return }
        didShowSheet = true
        requestPresentAddressSheet?("Определяем адрес…")
        // Небольшая задержка перед первым геокодом, как было в VC
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [] in
            // Первый реверс выполнится после первого onRegionDidChange, чтобы знать центр
            // (если хочешь форсануть — можно хранить текущий центр и вызывать тут)
        }
    }

    func onRegionDidChange(center: CLLocationCoordinate2D) {
        guard !isSheetEditing else { return }
        // distance gate
        if let prev = lastGeocodeCoordinate {
            let p1 = MKMapPoint(center)
            let p2 = MKMapPoint(prev)
            if p1.distance(to: p2) < minDistanceMeters { return }
        }

        // time throttle
        let elapsed = Date().timeIntervalSince(lastGeocodeAt)
        let delay = max(0, minGeocodeInterval - elapsed)

        pendingWork?.cancel()
        let work = DispatchWorkItem { [weak self] in
            self?.performReverseGeocode(center)
        }
        pendingWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: work)
    }

    func onLocateTapped() {
        // Просто просим у VC перезапросить локацию (старая логика остаётся в VC)
        // Либо можно тут генерировать событие/флаг — но не ломаем текущую архитектуру.
    }

    func onZoomIn(currentRegion: MKCoordinateRegion) -> MKCoordinateRegion {
        var region = currentRegion
        region.span = clampedSpan(MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta / 2,
                                                   longitudeDelta: region.span.longitudeDelta / 2))
        return region
    }

    func onZoomOut(currentRegion: MKCoordinateRegion) -> MKCoordinateRegion {
        var region = currentRegion
        region.span = clampedSpan(MKCoordinateSpan(latitudeDelta: region.span.latitudeDelta * 2,
                                                   longitudeDelta: region.span.longitudeDelta * 2))
        return region
    }

    func onLocationAuthChanged(_ status: CLAuthorizationStatus, manager: CLLocationManager) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        case .denied, .restricted, .notDetermined:
            break
        @unknown default:
            break
        }
    }

    func onLocationsUpdated(_ locations: [CLLocation], manager: CLLocationManager) {
        guard let last = locations.last else { return }
        requestCenterMap?(last.coordinate, 600)
        manager.stopUpdatingLocation()
    }

    func onLocationFailed(_ error: Error) {
        // без побочных эффектов; при желании можно логировать/аналитику
        print("Location error:", error)
    }

    // MARK: - Internal
    private func performReverseGeocode(_ center: CLLocationCoordinate2D) {
        guard !geocodeInFlight else { return }
        geocodeInFlight = true
        lastGeocodeAt = Date()
        lastGeocodeCoordinate = center

        geocoder.reverseGeocode(CLLocation(latitude: center.latitude, longitude: center.longitude),
                                locale: locale) { [weak self] placemark in
            guard let self else { return }
            self.geocodeInFlight = false

            guard let pm = placemark else {
                self.updateAddressText?("Адрес не найден")
                return
            }

            let text = self.formatter.displayString(from: MKPlacemark(placemark: pm), fallback: "Адрес не найден")
            self.updateAddressText?(text.isEmpty ? "Адрес не найден" : text)
        }
    }
}
