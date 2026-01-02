//
//  UIBarButtonItem+ext.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

extension UIBarButtonItem {
    static func backItem(
        target: Any?,
        action: Selector,
        tintColor: UIColor = .label
    ) -> UIBarButtonItem {
        let config = UIImage.SymbolConfiguration(weight: .semibold)
        let image = UIImage(systemName: "chevron.backward", withConfiguration: config)
        
        let button = UIButton(type: .system)
        button.setImage(image, for: .normal)
        button.tintColor = tintColor
        button.addTarget(target, action: action, for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }
    
    /// Фирменная текстовая кнопка в навбаре (фиолетовый текст, medium 17).
    static func brandedText(
        title: String,
        target: Any?,
        action: Selector
    ) -> UIBarButtonItem {
        let item = UIBarButtonItem(title: title, style: .plain, target: target, action: action)
        
        let normalAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor.brightPurple
        ]
        let disabledAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 17, weight: .medium),
            .foregroundColor: UIColor.brightPurple.withAlphaComponent(0.5)
        ]
        
        item.setTitleTextAttributes(normalAttrs, for: .normal)
        item.setTitleTextAttributes(normalAttrs, for: .highlighted)
        item.setTitleTextAttributes(disabledAttrs, for: .disabled)
        
        return item
    }
    
    /// Специализация под «Очистить».
    static func brandedClear(
        title: String = "Очистить",
        target: Any?,
        action: Selector
    ) -> UIBarButtonItem {
        brandedText(title: title, target: target, action: action)
    }
}
