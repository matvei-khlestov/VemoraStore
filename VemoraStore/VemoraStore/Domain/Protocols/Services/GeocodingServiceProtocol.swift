//
//  GeocodingServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import Foundation
import CoreLocation
import MapKit

/// Протокол `GeocodingServiceProtocol`
///
/// Определяет интерфейс для геокодирования и обратного геокодирования.
/// Используется для преобразования координат `CLLocation`
/// в человекочитаемые адреса (`MKPlacemark`).
///
/// Основные задачи:
/// - получение информации об адресе по заданным координатам;
/// - использование локали (`Locale`) для локализованных результатов (например, на русском языке);
/// - возврат результата через замыкание (асинхронная операция).
///
/// Используется в:
/// - `MapPickerViewModel` и `AddressConfirmSheetViewModel`
///   для преобразования координат при выборе точки на карте
///   или поиске адреса вручную.

protocol GeocodingServiceProtocol: AnyObject {
    
    /// Выполняет обратное геокодирование координат в объект `MKPlacemark`.
    /// - Parameters:
    ///   - location: Координаты `CLLocation`, для которых требуется определить адрес.
    ///   - locale: Локаль, влияющая на язык возвращаемых данных.
    ///   - completion: Замыкание с результатом (`MKPlacemark?`) — может быть `nil`, если адрес не найден.
    func reverseGeocode(
        _ location: CLLocation,
        locale: Locale,
        completion: @escaping (MKPlacemark?) -> Void
    )
}
