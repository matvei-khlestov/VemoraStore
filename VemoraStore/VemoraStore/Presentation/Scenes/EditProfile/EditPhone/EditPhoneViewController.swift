//
//  EditPhoneViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

/// Контроллер `EditPhoneViewController` для экрана изменения номера телефона.
///
/// Отвечает за:
/// - отображение поля ввода телефона с форматированием;
/// - взаимодействие с `EditPhoneViewModelProtocol` (валидация, сохранение изменений);
/// - настройку заголовка навигации и конфигурацию базового экрана редактирования;
/// - передачу форматтера телефона (`PhoneFormattingProtocol`) в базовый контроллер.
///
/// Контроллер не содержит бизнес-логики — за неё отвечает ViewModel.
/// Основан на `BaseEditFieldViewController`, что обеспечивает единый UX
/// для редактирования разных типов полей (имя, e-mail, телефон и т.д.).

final class EditPhoneViewController: BaseEditFieldViewController {
    
    init(
        viewModel: EditPhoneViewModelProtocol,
        phoneFormatter: PhoneFormattingProtocol
    ) {
        super.init(
            viewModel: viewModel,
            fieldKind: .phone,
            navTitle: "Изменить номер телефона",
            phoneFormatter: phoneFormatter 
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
