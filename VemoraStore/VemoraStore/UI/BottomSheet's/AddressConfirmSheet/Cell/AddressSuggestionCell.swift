//
//  AddressSuggestionCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 30.09.2025.
//

import UIKit
import MapKit

/// Ячейка `AddressSuggestionCell`
/// для отображения поисковых подсказок адресов.
///
/// Основные задачи:
/// - вывод заголовка и подзаголовка подсказки (`MKLocalSearchCompletion`);
/// - аккуратное оформление текста с использованием системной конфигурации;
/// - стандартный аксессуар `disclosureIndicator` для обозначения выбора.
///
/// Используется в `AddressConfirmSheetViewController`
/// внутри таблицы подсказок при вводе адреса.

final class AddressSuggestionCell: UITableViewCell {
    
    // MARK: - Reuse
    
    static let reuseId = String(describing: AddressSuggestionCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        static let titleFont: UIFont = .systemFont(ofSize: 16, weight: .semibold)
        static let subtitleColor: UIColor = .secondaryLabel
    }
    
    // MARK: - UI (using default content configuration)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Configure

extension AddressSuggestionCell {
    func configure(with completion: MKLocalSearchCompletion) {
        var conf = defaultContentConfiguration()
        conf.text = completion.title
        conf.textProperties.font = Metrics.titleFont
        conf.secondaryText = completion.subtitle
        conf.secondaryTextProperties.color = Metrics.subtitleColor
        contentConfiguration = conf
    }
}
