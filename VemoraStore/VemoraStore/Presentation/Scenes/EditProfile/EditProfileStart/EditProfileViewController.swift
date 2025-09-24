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

    var onEditName: (() -> Void)?
    var onEditEmail: (() -> Void)?
    var onEditPhone: (() -> Void)?
    var onBack: (() -> Void)?

    // MARK: - Deps

    private let viewModel: EditProfileViewModelProtocol
    private var bag = Set<AnyCancellable>()

    // MARK: - UI

    private static let cellId = "EditProfileCell"

    private lazy var scroll: UIScrollView = {
        let v = UIScrollView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.contentInsetAdjustmentBehavior = .automatic
        v.alwaysBounceVertical = true
        return v
    }()

    private lazy var content: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .center
        v.spacing = 16
        v.isLayoutMarginsRelativeArrangement = true
        v.layoutMargins = .init(top: 24, left: 16, bottom: 24, right: 16)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var avatarImageView: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.layer.cornerRadius = 56
        v.clipsToBounds = true
        v.tintColor = .tertiaryLabel
        v.image = UIImage(systemName: "person.crop.circle.fill")
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 112).isActive = true
        v.heightAnchor.constraint(equalToConstant: 112).isActive = true
        return v
    }()

    private lazy var changePhotoButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("Изменить фото", for: .normal)
        b.addTarget(self, action: #selector(changePhotoTapped), for: .touchUpInside)
        b.translatesAutoresizingMaskIntoConstraints = false
        return b
    }()

    private lazy var tableContainer: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.isScrollEnabled = false
        tv.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tv.rowHeight = 60
        tv.estimatedRowHeight = 60
        tv.tableFooterView = UIView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.dataSource = self
        tv.delegate = self
        tv.register(UITableViewCell.self, forCellReuseIdentifier: Self.cellId)
        return tv
    }()

    private enum Row: Int, CaseIterable { case name, email, phone }

    // MARK: - Init

    init(viewModel: EditProfileViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupNav()
        buildLayout()
        setupConstraints()
        bind()
        viewModel.load()
    }

    // MARK: - Navigation

    private func setupNav() {
        setupNavigationBarWithNavLeftItem(
            title: "Редактирование профиля",
            action: #selector(backTapped),
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }

    // MARK: - Layout

    private func buildLayout() {
        view.addSubview(scroll)
        scroll.addSubview(content)

        content.addArrangedSubview(avatarImageView)
        content.addArrangedSubview(changePhotoButton)

        content.addArrangedSubview(tableContainer)
        tableContainer.addSubview(tableView)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
        ])

        // tableContainer шириной как content margins
        tableContainer.widthAnchor.constraint(equalTo: content.layoutMarginsGuide.widthAnchor).isActive = true

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor)
        ])

        // Высота таблицы = кол-во строк * rowHeight + верхний паддинг 8
        tableView.heightAnchor.constraint(
            equalToConstant: CGFloat(Row.allCases.count) * tableView.rowHeight + 8
        ).isActive = true
    }

    // MARK: - Bindings

    private func bind() {
        viewModel.avatarDataPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.avatarImageView.image = data.flatMap(UIImage.init(data:)) ?? UIImage(systemName: "person.crop.circle.fill")
            }
            .store(in: &bag)
    }

    // MARK: - Helpers

    private func configureCell(_ cell: UITableViewCell, for row: Row) {
        cell.accessoryType = .disclosureIndicator
        var conf = cell.defaultContentConfiguration()
        switch row {
        case .name:
            conf.text = "Имя"
            conf.secondaryText = viewModel.name
            conf.image = UIImage(systemName: "person.fill")
        case .email:
            conf.text = "Почта"
            conf.secondaryText = viewModel.email
            conf.image = UIImage(systemName: "envelope.fill")
        case .phone:
            conf.text = "Телефон"
            conf.secondaryText = viewModel.phone
            conf.image = UIImage(systemName: "phone.fill")
        }
        conf.secondaryTextProperties.font = .systemFont(ofSize: 16, weight: .regular)
        conf.secondaryTextProperties.color = .secondaryLabel
        conf.imageProperties.tintColor = .brightPurple
        conf.imageProperties.reservedLayoutSize = CGSize(width: 24, height: 24)
        conf.imageProperties.maximumSize = CGSize(width: 24, height: 24)
        cell.contentConfiguration = conf
        cell.selectionStyle = .default
    }

    // MARK: - Actions

    @objc private func backTapped() { onBack?() }

    @objc private func changePhotoTapped() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    private func presentError(_ error: Error) {
        let alert = UIAlertController.makeError(error)
        present(alert, animated: true)
    }
}

// MARK: - PHPickerViewControllerDelegate

extension EditProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let itemProvider = results.first?.itemProvider,
              itemProvider.canLoadObject(ofClass: UIImage.self) else { return }

        itemProvider.loadObject(ofClass: UIImage.self) { [weak self] reading, error in
            guard let self else { return }
            if let error { DispatchQueue.main.async { self.presentError(error) }; return }
            if let image = reading as? UIImage,
               let data = image.jpegData(compressionQuality: 0.9) {
                Task {
                    do {
                        try await self.viewModel.saveAvatarData(data)
                    } catch {
                        await MainActor.run { self.presentError(error) }
                    }
                }
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension EditProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { Row.allCases.count }

    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = Row(rawValue: indexPath.row)!
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellId, for: indexPath)
        configureCell(cell, for: row)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension EditProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let row = Row(rawValue: indexPath.row) else { return }
        switch row {
        case .name:  onEditName?()
        case .email: onEditEmail?()
        case .phone: onEditPhone?()
        }
    }
}
