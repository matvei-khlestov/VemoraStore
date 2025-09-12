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
}
