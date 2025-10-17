//
//  ContactUsCoordinator.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.09.2025.
//

import UIKit

/// Координатор `ContactUsCoordinator` управляет сценарием отображения экрана "Связаться с нами".
///
/// Отвечает за:
/// - инициализацию и показ `ContactUsViewController`;
/// - навигацию при возврате назад;
/// - завершение сценария через колбэк `onFinish`.
///
/// Особенности:
/// - скрывает нижний таббар при переходе на экран контактов;
/// - реализует чистую навигацию без логики отображения;
/// - соответствует принципам архитектуры Coordinator, разделяя ответственность между навигацией и UI.

final class ContactUsCoordinator: ContactUsCoordinatingProtocol {
    
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
        let vc = ContactUsViewController()
        vc.hidesBottomBarWhenPushed = true
        vc.onBack = { [weak self] in
            self?.navigation.popViewController(animated: true)
            self?.onFinish?()
        }
        navigation.pushViewController(vc, animated: true)
    }
}
