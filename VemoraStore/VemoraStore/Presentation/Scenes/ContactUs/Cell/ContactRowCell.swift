//
//  ContactRowCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.09.2025.
//

import UIKit

/// Ячейка `ContactRowCell` для отображения контактной информации в списке.
///
/// Отвечает за:
/// - базовую строку таблицы с заголовком, дополнительным текстом и иконкой;
/// - использование системной конфигурации `UIListContentConfiguration`;
/// - отображение стрелки перехода (`.disclosureIndicator`);
/// - настройку внешнего вида и вторичного текста.
///
/// Использование:
/// - Применяется в экранах с контактами или настройками.
/// - Конфигурация выполняется методом `configure(title:detail:systemImage:)`.
///
/// Особенности:
/// - Вторичный текст имеет шрифт `.systemFont(ofSize: 15, weight: .regular)`;
/// - Иконка окрашивается в `secondaryLabel` по умолчанию.

final class ContactRowCell: UITableViewCell {
    
    static let reuseId = String(describing: ContactRowCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Fonts {
            static let secondary: UIFont = .systemFont(ofSize: 15, weight: .regular)
        }
    }
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        selectionStyle = .default
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure
    
    func configure(
        title: String,
        detail: String?,
        systemImage: String,
        secondaryFont: UIFont = Metrics.Fonts.secondary,
        iconTint: UIColor = .secondaryLabel
    ) {
        var conf = defaultContentConfiguration()
        conf.text = title
        conf.secondaryText = detail
        conf.secondaryTextProperties.font = secondaryFont
        conf.image = UIImage(systemName: systemImage)
        conf.imageProperties.tintColor = iconTint
        contentConfiguration = conf
    }
}
