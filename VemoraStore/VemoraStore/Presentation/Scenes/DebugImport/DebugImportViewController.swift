//
//  DebugImportViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import UIKit

#if DEBUG
final class DebugImportViewController: UIViewController {
    
    // MARK: - Properties
    
    private let viewModel: DebugImportViewModelProtocol
    
    // MARK: - UI Elements
    
    private lazy var enabledLabel: UILabel = {
        let v = UILabel()
        v.text = "Включить импорт"
        v.font = .systemFont(ofSize: 16)
        return v
    }()
    
    private lazy var enabledSwitch: UISwitch = {
        let v = UISwitch()
        v.addTarget(self, action: #selector(enabledChanged(_:)), for: .valueChanged)
        return v
    }()
    
    private lazy var overwriteLabel: UILabel = {
        let v = UILabel()
        v.text = "Перезаписывать существующие"
        v.font = .systemFont(ofSize: 16)
        return v
    }()
    
    private lazy var overwriteSwitch: UISwitch = {
        let v = UISwitch()
        v.addTarget(self, action: #selector(overwriteChanged(_:)), for: .valueChanged)
        return v
    }()
    
    private lazy var versionTitleLabel: UILabel = {
        let v = UILabel()
        v.text = "Версия сид-данных"
        v.font = .systemFont(ofSize: 16)
        return v
    }()
    
    private lazy var versionValueLabel: UILabel = {
        let v = UILabel()
        v.font = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
        v.textAlignment = .right
        return v
    }()
    
    private lazy var versionStepper: UIStepper = {
        let v = UIStepper()
        v.minimumValue = 1
        v.stepValue = 1
        v.addTarget(self, action: #selector(versionChanged(_:)), for: .valueChanged)
        return v
    }()
    
    private lazy var importButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Импортировать", for: .normal)
        v.addTarget(self, action: #selector(runImport), for: .touchUpInside)
        return v
    }()
    
    private lazy var resetButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle("Сбросить маркеры", for: .normal)
        v.addTarget(self, action: #selector(resetMarkers), for: .touchUpInside)
        return v
    }()
    
    private lazy var activity: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.hidesWhenStopped = true
        return v
    }()
    
    private lazy var logView: UITextView = {
        let v = UITextView()
        v.isEditable = false
        v.backgroundColor = .secondarySystemBackground
        v.layer.cornerRadius = 12
        v.textContainerInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 8)
        v.font = .systemFont(ofSize: 15)
        v.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        v.typingAttributes[.paragraphStyle] = paragraphStyle
        return v
    }()
    
    private lazy var toggleRow: UIStackView = {
        let v = UIStackView(arrangedSubviews: [enabledLabel, enabledSwitch])
        v.axis = .horizontal
        v.alignment = .center
        v.distribution = .equalSpacing
        return v
    }()
    
    private lazy var overwriteRow: UIStackView = {
        let v = UIStackView(arrangedSubviews: [overwriteLabel, overwriteSwitch])
        v.axis = .horizontal
        v.alignment = .center
        v.distribution = .equalSpacing
        return v
    }()
    
    private lazy var versionRowLeft: UIStackView = {
        let v = UIStackView(arrangedSubviews: [versionTitleLabel])
        v.axis = .horizontal
        v.alignment = .center
        v.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return v
    }()
    
    private lazy var versionRowRight: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            versionValueLabel,
            versionStepper
        ])
        v.axis = .horizontal
        v.alignment = .center
        v.spacing = 8
        return v
    }()
    
    private lazy var versionRow: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            versionRowLeft,
            versionRowRight
        ])
        v.axis = .horizontal
        v.alignment = .center
        v.distribution = .equalSpacing
        return v
    }()
    
    private lazy var buttonsRow: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            importButton,
            resetButton
        ])
        v.axis = .horizontal
        v.spacing = 12
        v.distribution = .fillEqually
        return v
    }()
    
    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            toggleRow,
            overwriteRow,
            versionRow,
            buttonsRow,
            activity, logView
        ])
        v.axis = .vertical
        v.spacing = 16
        return v
    }()
    
    var onFinish: (() -> Void)?
    
    // MARK: - Init
    
    init(viewModel: DebugImportViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavbar()
        setupUI()
        bind()
        // первичное обновление UI текущим стейтом
        viewModel.onStateChange?(viewModel.state)
    }
    
    // MARK: - Binding
    
    private func bind() {
        viewModel.onStateChange = { [weak self] state in
            guard let self else { return }
            self.enabledSwitch.isOn = state.isEnabledFlag
            self.overwriteSwitch.isOn = state.overwrite
            self.versionValueLabel.text = "\(state.seedVersion)"
            self.versionStepper.value = Double(state.seedVersion)
            self.importButton.isEnabled = !state.isRunning
            self.resetButton.isEnabled = !state.isRunning
            state.isRunning ? self.activity.startAnimating() : self.activity.stopAnimating()
            self.logView.text = state.log
        }
    }
    
    // MARK: - Setup UI
    
    private func setupNavbar() {
        setupNavigationBar(
            title: "Импорт данных (DEBUG)",
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        setupConstraints()
    }
    
    // MARK: - Constraints
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            logView.heightAnchor.constraint(equalToConstant: 260)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func enabledChanged(_ sender: UISwitch) {
        viewModel.setImporterEnabled(sender.isOn)
    }
    
    @objc private func overwriteChanged(_ sender: UISwitch) {
        viewModel.setOverwrite(sender.isOn)
    }
    
    @objc private func versionChanged(_ sender: UIStepper) {
        viewModel.setSeedVersion(Int(sender.value))
    }
    
    @objc private func runImport() {
        viewModel.runImport()
    }
    
    @objc private func resetMarkers() {
        viewModel.resetMarkers()
    }
}
#endif
