//
//  AddressConfirmSheetViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import MapKit

/// Протокол `AddressConfirmSheetViewModelProtocol`
/// описывает контракт ViewModel для экрана подтверждения адреса.
///
/// Отвечает за:
/// - управление поисковыми подсказками `MKLocalSearchCompletion`;
/// - определение региона поиска (`MKCoordinateRegion`);
/// - разрешение выбранных адресов и обратный возврат результата в виде строки и координат.
///
/// Используется в `AddressConfirmSheetViewController`
/// для организации поиска и выбора адреса пользователем.

protocol AddressConfirmSheetViewModelProtocol: AnyObject {
    
    // MARK: - State
    
    /// Список подсказок, полученных из MapKit при поиске.
    var completions: [MKLocalSearchCompletion] { get }
    
    /// Регион, в котором выполняется поиск (для повышения релевантности).
    var region: MKCoordinateRegion? { get set }
    
    // MARK: - Callbacks
    
    /// Вызывается при изменении списка найденных адресов.
    /// Передаёт массив `MKLocalSearchCompletion`.
    var onResultsChanged: (([MKLocalSearchCompletion]) -> Void)? { get set }
    
    /// Вызывается при успешном разрешении адреса.
    /// Передаёт строку адреса и координаты.
    var onResolvedAddress: ((String, CLLocationCoordinate2D) -> Void)? { get set }
    
    // MARK: - Intents
    
    /// Обновляет текст поискового запроса.
    /// - Parameter text: Введённая пользователем строка.
    func updateQuery(_ text: String)
    
    /// Разрешает выбранную подсказку из списка.
    /// Выполняет геокодирование и вызывает `onResolvedAddress`.
    /// - Parameter completion: Объект `MKLocalSearchCompletion`.
    func resolve(completion: MKLocalSearchCompletion)
    
    /// Выполняет геокодирование по произвольному тексту (без подсказки).
    /// - Parameter query: Произвольная строка адреса.
    func resolveFreeText(_ query: String)
}
