//
//  BlurredIconBackground.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 28.09.2025.
//

import UIKit

/// Универсальный контейнер с блюром и скруглёнными углами.
/// Внутрь можно положить любую кнопку или иконку.
final class BlurredIconBackground: UIVisualEffectView {
    
    init(
        cornerRadius: CGFloat,
        blurStyle: UIBlurEffect.Style = .systemChromeMaterial
    ) {
        super.init(effect: UIBlurEffect(style: blurStyle))
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    /// Добавляет кнопку внутрь и центрирует её
    func embed(_ view: UIView) {
        contentView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            view.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
