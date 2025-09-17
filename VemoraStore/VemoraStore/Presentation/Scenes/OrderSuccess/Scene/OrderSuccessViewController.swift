//
//  OrderSuccessViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 12.09.2025.
//

import UIKit

final class OrderSuccessViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onViewOrder: (() -> Void)?
    
    // MARK: - UI
    private let iconView: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 96, weight: .semibold)
        let iv = UIImageView(image: UIImage(systemName: "checkmark.circle.fill", withConfiguration: config))
        iv.tintColor = .white
        iv.contentMode = .scaleAspectFit
        iv.setContentHuggingPriority(.required, for: .vertical)
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.text = "Заказ успешно оформлен"
        l.font = .systemFont(ofSize: 28, weight: .bold)
        l.textAlignment = .center
        l.textColor = .white
        l.numberOfLines = 0
        return l
    }()
    
    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.text = "Перейдите к деталям заказа и отслеживанию."
        l.font = .systemFont(ofSize: 16, weight: .regular)
        l.textAlignment = .center
        l.textColor = UIColor.white.withAlphaComponent(0.8)
        l.numberOfLines = 0
        return l
    }()
    
    private let viewOrderButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Открыть заказ"
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.9)
        config.baseForegroundColor = .brightPurple
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = .systemFont(ofSize: 17, weight: .semibold)
            return outgoing
        }
        config.cornerStyle = .capsule
        let b = UIButton(configuration: config)
        b.setContentHuggingPriority(.required, for: .vertical)
        return b
    }()
    
    private let stack = UIStackView()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupLayout()
        viewOrderButton.addTarget(self, action: #selector(viewOrderTapped), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Setup
    private func setupAppearance() {
        view.backgroundColor = .brightPurple
    }
    
    private func setupLayout() {
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 24
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        // Вложенный стек для текстов — ширина по лайаут-гайду
        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 8
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(textStack)
        stack.addArrangedSubview(viewOrderButton)
        
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.leadingAnchor, constant: 0),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: view.layoutMarginsGuide.trailingAnchor, constant: 0),
            
            textStack.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 1.0),
            viewOrderButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func viewOrderTapped() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        onViewOrder?()
    }
}
