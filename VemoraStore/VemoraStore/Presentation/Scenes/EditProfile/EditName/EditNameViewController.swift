//
//  EditNameViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import UIKit

/// Контроллер `EditNameViewController` для экрана изменения имени пользователя.
///
/// Отвечает за:
/// - отображение поля ввода имени;
/// - взаимодействие с `EditNameViewModelProtocol` (валидация и сохранение изменений);
/// - настройку заголовка навигации и конфигурацию базового экрана редактирования.
///
/// Контроллер не содержит бизнес-логики — она реализована во ViewModel.
/// Основан на `BaseEditFieldViewController`, что обеспечивает единый UX
/// для редактирования различных полей профиля пользователя.

final class EditNameViewController: BaseEditFieldViewController {
    
    init(viewModel: EditNameViewModelProtocol) {
        super.init(
            viewModel: viewModel,
            fieldKind: .name,
            navTitle: "Изменить имя"
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
