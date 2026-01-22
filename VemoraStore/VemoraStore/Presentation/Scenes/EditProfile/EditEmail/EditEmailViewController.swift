//
//  EditEmailViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

/// Экран изменения e-mail пользователя (`EditEmailViewController`).
///
/// Назначение:
/// - предоставляет UI для редактирования e-mail через базовый экран `BaseEditFieldViewController`;
/// - обрабатывает сценарий смены e-mail, требующий подтверждения текущим паролем (reauth);
/// - показывает `UIAlertController` с secure-вводом пароля и повторяет сабмит с введённым значением.
///
/// Зависимости:
/// - `EditEmailViewModel` — конкретная ViewModel с логикой смены e-mail и сигналом `onPasswordRequired`.
///
/// Навигация:
/// - `onFinish` (унаследовано) вызывается после успешного обновления e-mail, чтобы закрыть экран.
///
/// Особенности UX:
/// - password prompt показывается только если нет другого `presentedViewController`,
///   чтобы избежать повторной презентации и конфликтов переходов;
/// - перед показом prompt выполняется `view.endEditing(true)` для корректного закрытия клавиатуры;
/// - при ошибке ввода/обновления показывается стандартный error-alert через `UIAlertController.makeError`.
final class EditEmailViewController: BaseEditFieldViewController {
    
    // MARK: - Deps
    
    private let typedViewModel: EditEmailViewModel
    
    // MARK: - Init
    
    init(viewModel: EditEmailViewModelProtocol) {
        guard let vm = viewModel as? EditEmailViewModel else {
            fatalError("EditEmailViewController expects EditEmailViewModel")
        }
        self.typedViewModel = vm
        
        super.init(
            viewModel: viewModel,
            fieldKind: .email,
            navTitle: "Изменить почту"
        )
        
        self.typedViewModel.onPasswordRequired = { [weak self] in
            Task { @MainActor in
                self?.presentPasswordPromptIfPossible()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Password Prompt

private extension EditEmailViewController {
    
    /// Показывает password prompt, если в данный момент не отображается другой модальный контроллер.
    ///
    /// Используется для сценариев, где смена e-mail требует подтверждения текущим паролем.
    /// Метод выполняется на `MainActor`, так как затрагивает UI.
    @MainActor
    func presentPasswordPromptIfPossible() {
        guard presentedViewController == nil else { return }
        
        view.endEditing(true)
        
        let alert = UIAlertController.makeSecureInput(
            title: "Подтвердите пароль",
            message: "Для изменения почты требуется подтверждение текущим паролем.",
            placeholder: "Текущий пароль",
            onConfirm: { [weak self] password in
                guard let self else { return }
                
                Task {
                    do {
                        try await self.typedViewModel.submit(withPassword: password)
                        await MainActor.run {
                            self.onFinish?()
                        }
                    } catch {
                        await MainActor.run {
                            if let presented = self.presentedViewController {
                                presented.dismiss(animated: true)
                            }
                            self.present(UIAlertController.makeError(error), animated: true)
                        }
                    }
                }
            }
        )
        
        present(alert, animated: true)
    }
}
