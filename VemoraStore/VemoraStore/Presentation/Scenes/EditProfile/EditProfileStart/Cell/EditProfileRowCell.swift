//
//  EditProfileRowCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.09.2025.
//

import UIKit

/// Ячейка `EditProfileRowCell` отображает строку редактирования профиля пользователя.
///
/// Отвечает за:
/// - отображение заголовка и текущего значения поля профиля;
/// - отображение иконки поля с системным символом;
/// - визуальное оформление строки по дизайн-гайду проекта.
///
/// Используется в `EditProfileViewController` для отображения списка редактируемых полей.

final class EditProfileRowCell: UITableViewCell {
    
    static let reuseId = String(describing: EditProfileRowCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 17, weight: .regular)
            static let detail: UIFont = .systemFont(ofSize: 16, weight: .regular)
        }
        enum Icon {
            static let size: CGSize = .init(width: 24, height: 24)
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
    
    func configure(title: String, detail: String, systemImage: String) {
        var conf = defaultContentConfiguration()
        conf.text = title
        conf.textProperties.font = Metrics.Fonts.title
        
        conf.secondaryText = detail
        conf.secondaryTextProperties.font = Metrics.Fonts.detail
        conf.secondaryTextProperties.color = .secondaryLabel
        
        conf.image = UIImage(systemName: systemImage)
        conf.imageProperties.tintColor = .brightPurple
        conf.imageProperties.reservedLayoutSize = Metrics.Icon.size
        conf.imageProperties.maximumSize = Metrics.Icon.size
        
        contentConfiguration = conf
    }
}
