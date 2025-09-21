//
//  UITextField+ext.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 19.09.2025.
//

import UIKit

extension UITextField {
    func onReturn(_ target: Any?, action: Selector) {
        self.addTarget(target, action: action, for: .editingDidEndOnExit)
    }
}
