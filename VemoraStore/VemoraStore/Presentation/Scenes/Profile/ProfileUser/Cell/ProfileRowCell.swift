//
//  ProfileRowCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 28.09.2025.
//

import UIKit

/// Ячейка профиля со строкой меню.
///
/// Используется для отображения пунктов профиля с текстом и иконкой.
/// Содержит системное изображение и стрелку перехода (`.disclosureIndicator`).

final class ProfileRowCell: UITableViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: ProfileRowCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 17)
        }
        enum Colors {
            static let iconTint: UIColor = .secondaryLabel
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
    
    func configure(title: String, systemImage: String) {
        var conf = defaultContentConfiguration()
        conf.text = title
        conf.textProperties.font = Metrics.Fonts.title
        conf.image = UIImage(systemName: systemImage)
        conf.imageProperties.tintColor = Metrics.Colors.iconTint
        contentConfiguration = conf
    }
}
