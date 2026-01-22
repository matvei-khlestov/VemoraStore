//
//  UIAlertController+ext.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import UIKit

/// Расширение `UIAlertController`.
///
/// Отвечает за:
/// - создание стандартных алертов (инфо, ошибка, успех);
/// - конфигурацию подтверждений действий (`ConfirmationAlertType`);
/// - сокращение шаблонного кода при показе алертов.
///
/// Включает методы:
/// - `makeConfirmation(_:onConfirm:onCancel:)` — алерт с подтверждением и отменой;
/// - `makeConfirmation(_:onConfirm:)` — упрощённая версия без отмены;
/// - `makeInfo(title:message:okTitle:onOk:)` — информационный алерт с одной кнопкой;
/// - `makeError(_:)` — универсальный алерт для отображения ошибок;
/// - `makeSuccess(title:message:okTitle:onOk:)` — алерт успешного действия.
///
/// Использование:
/// - показ подтверждения перед удалением или выходом;
/// - уведомления об успехе или ошибке действий (например, сохранение профиля);
/// - стандартные системные уведомления без дублирования кода.

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

extension UIAlertController {

    static func makeSecureInput(
        title: String,
        message: String,
        placeholder: String,
        cancelTitle: String = "Отмена",
        confirmTitle: String = "Продолжить",
        onConfirm: @escaping (_ text: String) -> Void,
        onCancel: (() -> Void)? = nil
    ) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addTextField { tf in
            tf.placeholder = placeholder
            tf.isSecureTextEntry = true
        }

        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel) { _ in
            onCancel?()
        })

        alert.addAction(UIAlertAction(title: confirmTitle, style: .default) { _ in
            let text = alert.textFields?.first?.text ?? ""
            onConfirm(text)
        })

        return alert
    }
}
