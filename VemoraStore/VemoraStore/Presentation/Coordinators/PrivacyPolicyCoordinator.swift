//
//  PrivacyPolicyCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import UIKit

/// Координатор `PrivacyPolicyCoordinator` управляет сценарием отображения
/// экрана политики конфиденциальности.
///
/// Отвечает за:
/// - инициализацию и показ `PrivacyPolicyViewController`;
/// - навигацию при возврате с экрана политики;
/// - завершение сценария через колбэк `onFinish`.
///
/// Особенности:
/// - скрывает нижний таббар при переходе на экран политики конфиденциальности;
/// - полностью изолирует навигацию от UI- и бизнес-логики, следуя архитектуре Coordinator;
/// - использует слабую ссылку на `navigation`, предотвращая утечки памяти.

final class PrivacyPolicyCoordinator: PrivacyPolicyCoordinatingProtocol {
    
    // MARK: - Props
    
    let navigation: UINavigationController
    var childCoordinators: [Coordinator] = []
    
    var onFinish: (() -> Void)?
    
    // MARK: - Init
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }
    
    // MARK: - Start
    
    func start() {
        let vc = PrivacyPolicyViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
            self?.onFinish?()
        }
        navigation.pushViewController(vc, animated: true)
    }
}
