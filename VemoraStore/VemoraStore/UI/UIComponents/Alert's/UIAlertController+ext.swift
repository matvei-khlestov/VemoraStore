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
    
    /// Упрощённый оверлоад без onCancel
    static func makeConfirmation(
        _ type: ConfirmationAlertType,
        onConfirm: (() -> Void)?
    ) -> UIAlertController {
        makeConfirmation(type, onConfirm: onConfirm, onCancel: nil)
    }
    
    /// Информационный alert c одной кнопкой «Ок»
    static func makeInfo(
        title: String,
        message: String,
        okTitle: String = "Ок",
        onOk: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: okTitle,
            style: .default,
            handler: { _ in onOk?() })
        )
        return alert
    }
    
    /// Alert для ошибок (берёт message из error.localizedDescription)
    static func makeError(
        _ error: Error,
        title: String = "Ошибка",
        okTitle: String = "Ок"
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: okTitle,
            style: .default)
        )
        return alert
    }
    
    /// Alert для успешных действий
    static func makeSuccess(
        title: String = "Готово",
        message: String,
        okTitle: String = "Ок",
        onOk: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(
            title: okTitle,
            style: .default,
            handler: { _ in onOk?() })
        )
        return alert
    }
}
