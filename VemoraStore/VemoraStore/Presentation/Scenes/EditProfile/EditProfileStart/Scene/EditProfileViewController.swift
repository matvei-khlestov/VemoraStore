//
//  EditProfileViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit
import Combine
import PhotosUI

final class EditProfileViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onEditName:  (() -> Void)?
    var onEditEmail: (() -> Void)?
    var onEditPhone: (() -> Void)?
    var onBack:      (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: EditProfileViewModelProtocol
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalContent: CGFloat = 24
        }
        enum Spacing {
            static let verticalStack: CGFloat = 16
            static let tableTopPadding: CGFloat = 8
        }
        enum Avatar {
            static let size: CGFloat = 112
            static let cornerRadius: CGFloat = 56
        }
        enum Table {
            static let rowHeight: CGFloat = 65
            static let separatorInsets: UIEdgeInsets = .init(
                top: 0,
                left: 16,
                bottom: 0,
                right: 16
            )
        }
        enum ImageProcessing {
            static let jpegQuality: Double = 0.9
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Редактирование профиля"
        static let changePhotoButtonTitle = "Изменить фото"
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let avatarPlaceholder = "person.crop.circle.fill"
    }
    
    // MARK: - UI
    
    private lazy var scrollView: UIScrollView = {
        let v = UIScrollView()
        v.alwaysBounceVertical = true
        v.contentInsetAdjustmentBehavior = .automatic
        return v
    }()
    
    private lazy var contentStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.spacing = Metrics.Spacing.verticalStack
        v.isLayoutMarginsRelativeArrangement = true
        v.layoutMargins = .init(
            top: Metrics.Insets.verticalContent,
            left: Metrics.Insets.horizontal,
            bottom: Metrics.Insets.verticalContent,
            right: Metrics.Insets.horizontal
        )
        return v
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = Metrics.Avatar.cornerRadius
        v.clipsToBounds = true
        v.tintColor = .tertiaryLabel
        v.image = UIImage(systemName: Symbols.avatarPlaceholder)
        v.widthAnchor.constraint(equalToConstant: Metrics.Avatar.size).isActive = true
        v.heightAnchor.constraint(equalToConstant: Metrics.Avatar.size).isActive = true
        return v
    }()
    
    private lazy var changePhotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle(Texts.changePhotoButtonTitle, for: .normal)
        b.onTap(self, action: #selector(changePhotoTapped))
        return b
    }()
    
    private lazy var tableContainer = UIView()
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.separatorInset = Metrics.Table.separatorInsets
        tv.rowHeight = Metrics.Table.rowHeight
        tv.estimatedRowHeight = Metrics.Table.rowHeight
        tv.tableFooterView = UIView()
        tv.dataSource = self
        tv.delegate   = self
        tv.register(EditProfileRowCell.self)
        return tv
    }()
    
    // MARK: - Init
    
    init(viewModel: EditProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNavigationBar()
        setupHierarchy()
        setupLayout()
        bind()
        viewModel.load()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableHeightIfNeeded()
    }
}

// MARK: - Setup

private extension EditProfileViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigationBar() {
        setupNavigationBarWithNavLeftItem(
            title: Texts.navigationTitle,
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    func setupHierarchy() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)
        
        contentStack.addArrangedSubviews(
            avatarImageView,
            changePhotoButton,
            tableContainer
        )
        
        tableContainer.addSubview(tableView)
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupScrollConstraints()
        setupContentConstraints()
        setupWidthConstraints()
        setupTableConstraints()
    }
    
    func prepareForAutoLayout() {
        [scrollView, contentStack, tableContainer, tableView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupScrollConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            scrollView.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            scrollView.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            scrollView.bottomAnchor.constraint(
                equalTo: view.bottomAnchor
            )
        ])
    }
    
    func setupContentConstraints() {
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.topAnchor
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.leadingAnchor
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: scrollView.frameLayoutGuide.trailingAnchor
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: scrollView.contentLayoutGuide.bottomAnchor
            )
        ])
    }
    
    func setupWidthConstraints() {
        tableContainer.widthAnchor
            .constraint(
                equalTo: contentStack.layoutMarginsGuide.widthAnchor
            )
            .isActive = true
    }
    
    func setupTableConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(
                equalTo: tableContainer.topAnchor,
                constant: Metrics.Spacing.tableTopPadding
            ),
            tableView.leadingAnchor.constraint(
                equalTo: tableContainer.leadingAnchor
            ),
            tableView.trailingAnchor.constraint(
                equalTo: tableContainer.trailingAnchor
            ),
            tableView.bottomAnchor.constraint(
                equalTo: tableContainer.bottomAnchor
            )
        ])
    }
}

// MARK: - Bindings

private extension EditProfileViewController {
    func bind() {
        viewModel.avatarDataPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.avatarImageView.image = data
                    .flatMap(UIImage.init(data:))
                ?? UIImage(systemName: Symbols.avatarPlaceholder)
            }
            .store(in: &bag)
        
        bindRowPublisher(
            viewModel.namePublisher,
            for: .name
        )
        bindRowPublisher(
            viewModel.emailPublisher,
            for: .email
        )
        bindRowPublisher(
            viewModel.phonePublisher,
            for: .phone
        )
    }
    
    func bindRowPublisher(
        _ publisher: AnyPublisher<String, Never>,
        for row: EditProfileRow
    ) {
        publisher
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.reloadRow(row)
            }
            .store(in: &bag)
    }
    
    func reloadRow(_ row: EditProfileRow) {
        let indexPath = IndexPath(row: row.rawValue, section: 0)
        guard tableView.indexPathsForVisibleRows?.contains(indexPath) == true else { return }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - UITableViewDataSource

extension EditProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        EditProfileRow.allCases.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = EditProfileRow(rawValue: indexPath.row)!
        let cell: EditProfileRowCell = tableView.dequeueReusableCell(for: indexPath)
        cell.configure(
            title: row.title,
            detail: row.detail(from: viewModel),
            systemImage: row.icon
        )
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EditProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = EditProfileRow(rawValue: indexPath.row) else { return }
        switch row {
        case .name:
            onEditName?()
        case .email:
            onEditEmail?()
        case .phone:
            onEditPhone?()
        }
    }
}

// MARK: - PHPicker

extension EditProfileViewController: PHPickerViewControllerDelegate {
    @objc func changePhotoTapped() {
        var cfg = PHPickerConfiguration(photoLibrary: .shared())
        cfg.selectionLimit = 1
        cfg.filter = .images
        
        let picker = PHPickerViewController(configuration: cfg)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController,
                didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider else { return }
        
        Task {
            do {
                let image = try await provider.loadUIImage()
                if let data = image.jpegData(compressionQuality: Metrics.ImageProcessing.jpegQuality) {
                    try await viewModel.saveAvatarData(data)
                }
            } catch {
                await MainActor.run {
                    self.present(UIAlertController.makeError(error), animated: true)
                }
            }
        }
    }
}

// MARK: - Height

private extension EditProfileViewController {
    func updateTableHeightIfNeeded() {
        // Высота = количество строк * rowHeight + верхний паддинг
        let desired = CGFloat(EditProfileRow.allCases.count) * Metrics.Table.rowHeight
        + Metrics.Spacing.tableTopPadding
        
        tableView.constraints
            .filter { $0.firstAttribute == .height }
            .forEach { $0.isActive = false }
        
        tableView.heightAnchor.constraint(equalToConstant: desired).isActive = true
    }
}

// MARK: - Actions

private extension EditProfileViewController {
    @objc func backTapped() {
        onBack?()
    }
}

// MARK: - NSItemProvider helper

private extension NSItemProvider {
    func loadUIImage() async throws -> UIImage {
        try await withCheckedThrowingContinuation { continuation in
            guard canLoadObject(ofClass: UIImage.self) else {
                continuation.resume(
                    throwing: NSError(
                        domain: "ImagePicker",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Невозможно загрузить изображение."
                        ]
                    )
                )
                return
            }
            
            loadObject(ofClass: UIImage.self) { object, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let image = object as? UIImage {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(
                        throwing: NSError(
                            domain: "ImagePicker",
                            code: -2,
                            userInfo: [
                                NSLocalizedDescriptionKey: "Получен некорректный объект изображения."
                            ]
                        )
                    )
                }
            }
        }
    }
}
