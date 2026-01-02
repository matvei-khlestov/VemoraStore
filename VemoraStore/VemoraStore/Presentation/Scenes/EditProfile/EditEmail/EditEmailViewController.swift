//
//  EditEmailViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

/// Контроллер `EditEmailViewController` для экрана изменения адреса электронной почты.
///
/// Отвечает за:
/// - отображение поля редактирования e-mail;
/// - взаимодействие с `EditEmailViewModelProtocol` (валидация, сохранение изменений);
/// - настройку заголовка навигации и конфигурацию базового контроллера редактирования.
///
/// Контроллер не содержит бизнес-логики — она реализована во ViewModel.
/// Основан на `BaseEditFieldViewController`, что обеспечивает единый UX
/// для редактирования различных пользовательских полей.

final class EditEmailViewController: BaseEditFieldViewController {
    
    init(viewModel: EditEmailViewModelProtocol) {
        super.init(
            viewModel: viewModel,
            fieldKind: .email,
            navTitle: "Изменить почту"
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
