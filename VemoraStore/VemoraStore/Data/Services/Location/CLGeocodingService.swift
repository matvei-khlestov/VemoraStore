//
//  CLGeocodingService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation
import CoreLocation
import MapKit

/// Класс `CLGeocodingService`
///
/// Реализует протокол `GeocodingServiceProtocol`
/// и отвечает за выполнение обратного геокодирования координат в человекочитаемый адрес.
///
/// Основные задачи:
/// - преобразование координат (`CLLocation`) в `MKPlacemark`;
/// - поддержка локали для корректного отображения адреса пользователю;
/// - управление активными запросами геокодера (отмена предыдущих).
///
/// Используется в:
/// - `MapPickerViewModel` — для отображения адреса по выбранной точке на карте;
/// - `AddressConfirmSheetViewModel` — при вводе или выборе адреса вручную.

final class CLGeocodingService: GeocodingServiceProtocol {
    
    private let geocoder = CLGeocoder()
    
    func reverseGeocode(_ location: CLLocation,
                        locale: Locale,
                        completion: @escaping (MKPlacemark?) -> Void) {
        geocoder.cancelGeocode()
        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, _ in
            completion(placemarks?.first.map { MKPlacemark(placemark: $0) })
        }
    }
}
