//
//  UIAlertController+ext.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import UIKit

extension UIAlertController {
    /// Универсальный конструктор confirm-алерта по типу
    static func makeConfirmation(
        _ type: ConfirmationAlertType,
        onConfirm: (() -> Void)?,
        onCancel: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: type.title,
            message: type.message,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(
            title: type.confirmTitle,
            style: type.confirmStyle,
            handler: { _ in onConfirm?() }
        ))
        
        alert.addAction(UIAlertAction(
            title: "Отмена",
            style: .cancel,
            handler: { _ in onCancel?() }
        ))
        
        return alert
    }
}

extension UIAlertController {
    static func makeConfirmation(
        _ type: ConfirmationAlertType,
        onConfirm: (() -> Void)?
    ) -> UIAlertController {
        makeConfirmation(type, onConfirm: onConfirm, onCancel: nil)
    }
}
