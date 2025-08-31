//
//  ProfileViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import UIKit
import Combine
import FactoryKit

final class ProfileViewController: UIViewController {
    
    // MARK: - Public
    var onLogout: (() -> Void)?
    
    // MARK: - Deps
    private let viewModel: ProfileViewModel
    
    // MARK: - UI
    private let scrollView = UIScrollView()
    private let content = UIStackView()
    
    private let avatarView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 48
        iv.clipsToBounds = true
        iv.widthAnchor.constraint(equalToConstant: 96).isActive = true
        iv.heightAnchor.constraint(equalToConstant: 96).isActive = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 22, weight: .semibold)
        l.numberOfLines = 1
        return l
    }()
    
    private let emailLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .regular)
        l.textColor = .secondaryLabel
        l.numberOfLines = 1
        return l
    }()
    
    private lazy var editButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Редактировать", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .systemBlue
        b.tintColor = .white
        b.layer.cornerRadius = 12
//        b.contentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16)
        b.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        return b
    }()
    
    private lazy var logoutButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Выйти", for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        b.backgroundColor = .systemRed
        b.tintColor = .white
        b.layer.cornerRadius = 12
//        b.contentEdgeInsets = .init(top: 10, left: 16, bottom: 10, right: 16)
        b.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        return b
    }()
    
    private let buttonsRow = UIStackView()
    
    // MARK: - State
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    init(viewModel: ProfileViewModel = Container.shared.profileViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        view.backgroundColor = .systemBackground
        setupLayout()
        bindViewModel()
        viewModel.loadProfile()
    }
}

// MARK: - Private
private extension ProfileViewController {
    func setupLayout() {
        // Контентный стек
        content.axis = .vertical
        content.alignment = .center
        content.spacing = 16
        content.layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)
        content.isLayoutMarginsRelativeArrangement = true
        
        // Ряд кнопок
        buttonsRow.axis = .horizontal
        buttonsRow.spacing = 12
        buttonsRow.distribution = .fillEqually
        buttonsRow.alignment = .fill
        buttonsRow.addArrangedSubview(editButton)
        buttonsRow.addArrangedSubview(logoutButton)
        
        // Добавляем сабвью
        [avatarView, nameLabel, emailLabel, buttonsRow].forEach { content.addArrangedSubview($0) }
        
        // Скролл
        scrollView.alwaysBounceVertical = true
        scrollView.addSubview(content)
        view.addSubview(scrollView)
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        content.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            content.topAnchor.constraint(equalTo: scrollView.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    func bindViewModel() {
        // Когда добавишь Combine-выходы в VM, можно подписаться.
        // Здесь VM уже публикует profile через @Published, так что:
        viewModel.$profile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self, let profile else { return }
                self.nameLabel.text = profile.displayName
                self.emailLabel.text = profile.email
                // Загрузка аватарки (если используешь Kingfisher):
                // if let url = profile.photoURL { self.avatarView.kf.setImage(with: url) }
            }
            .store(in: &bag)
    }
    
    @objc func editTapped() {
        // TODO: открыть экран редактирования профиля (по желанию через координатор)
        // Можно пробросить в координатор отдельный колбэк, если потребуется
    }
    
    @objc func logoutTapped() {
        viewModel.logout()
        onLogout?()
    }
}
