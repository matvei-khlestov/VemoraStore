//
//  AddressSearchServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import MapKit

/// Протокол `AddressSearchServiceProtocol`
///
/// Определяет интерфейс для поиска адресов и подсказок с помощью Apple MapKit.
/// Используется для получения текстовых подсказок (`MKLocalSearchCompletion`)
/// и преобразования их в реальные координаты и адреса (`MKPlacemark`).
///
/// Основные задачи:
/// - предоставление реактивных подсказок по мере ввода текста;
/// - геокодирование выбранных подсказок в координаты;
/// - поддержка поиска произвольного текста (free-text);
/// - ограничение области поиска регионом (`MKCoordinateRegion`).
///
/// Используется в:
/// - `AddressConfirmSheetViewModel`
///   для управления поиском и выбором адреса при оформлении доставки.

protocol AddressSearchServiceProtocol: AnyObject {
    
    /// Текущий список текстовых подсказок.
    var completions: [MKLocalSearchCompletion] { get }
    
    /// Коллбек, вызываемый при обновлении списка подсказок.
    var onResultsChanged: (([MKLocalSearchCompletion]) -> Void)? { get set }
    
    /// Устанавливает регион поиска для ограничения подсказок по местоположению.
    /// - Parameter region: Географический регион (`MKCoordinateRegion`) или `nil` для поиска без ограничений.
    func setRegion(_ region: MKCoordinateRegion?)
    
    /// Обновляет поисковый запрос для получения актуальных подсказок.
    /// - Parameter text: Текст, введённый пользователем.
    func updateQuery(_ text: String)
    
    /// Разрешает выбранную подсказку (`MKLocalSearchCompletion`) в адрес и координаты.
    /// - Parameters:
    ///   - completion: Выбранная подсказка.
    ///   - fallback: Текст, используемый, если адрес не найден.
    ///   - completion: Замыкание с результатом (`MKPlacemark`, координата, fallback-строка).
    func resolve(
        completion: MKLocalSearchCompletion,
        fallback: String,
        completion: @escaping (MKPlacemark, CLLocationCoordinate2D, String) -> Void
    )
    
    /// Выполняет геокодирование произвольного текста (без подсказок).
    /// - Parameters:
    ///   - query: Строка с произвольным текстом адреса.
    ///   - completion: Замыкание с результатом (`MKPlacemark`, координата, fallback-строка).
    func resolveFreeText(
        _ query: String,
        completion: @escaping (MKPlacemark, CLLocationCoordinate2D, String) -> Void
    )
}
