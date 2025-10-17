//
//  AddressConfirmSheetViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import MapKit

/// ViewModel `AddressConfirmSheetViewModel`
/// для экрана подтверждения адреса.
///
/// Основные задачи:
/// - управление поиском адресов через `AddressSearchServiceProtocol`;
/// - форматирование отображаемых адресов с помощью `AddressFormattingProtocol`;
/// - реактивное обновление списка подсказок и разрешение выбранных адресов.
///
/// Обеспечивает обратные вызовы:
/// - `onResultsChanged` — обновление списка подсказок;
/// - `onResolvedAddress` — возврат выбранного адреса и координат.
///
/// Используется в:
/// - `AddressConfirmSheetViewController`
///   для ввода и выбора адреса доставки/самовывоза.

final class AddressConfirmSheetViewModel: NSObject, AddressConfirmSheetViewModelProtocol {
    
    // MARK: - Deps
    
    private let search: AddressSearchServiceProtocol
    private let formatter: AddressFormattingProtocol
    
    // MARK: - State (проксируем из сервиса)
    
    private(set) var completions: [MKLocalSearchCompletion] = []
    
    var region: MKCoordinateRegion? {
        didSet {
            search.setRegion(region)
        }
    }
    
    // MARK: - Outputs
    
    var onResultsChanged: (([MKLocalSearchCompletion]) -> Void)?
    var onResolvedAddress: ((String, CLLocationCoordinate2D) -> Void)?
    
    // MARK: - Init
    
    init(
        search: AddressSearchServiceProtocol,
        formatter: AddressFormattingProtocol
    ) {
        self.search = search
        self.formatter = formatter
        super.init()
        
        search.onResultsChanged = { [weak self] results in
            self?.completions = results
            self?.onResultsChanged?(results)
        }
    }
    
    // MARK: - Intent
    
    func updateQuery(_ text: String) {
        search.updateQuery(text)
    }
    
    func resolve(completion: MKLocalSearchCompletion) {
        search.resolve(completion: completion, fallback: completion.title) { [weak self] pm, coord, fallback in
            guard let self else { return }
            let display = self.formatter.displayString(from: pm, fallback: fallback)
            self.onResolvedAddress?(display, coord)
        }
    }
    
    func resolveFreeText(_ query: String) {
        search.resolveFreeText(query) { [weak self] pm, coord, fallback in
            guard let self else { return }
            let display = self.formatter.displayString(from: pm, fallback: fallback)
            self.onResolvedAddress?(display, coord)
        }
    }
}
