//
//  DebugImportViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import UIKit

#if DEBUG
final class DebugImportViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onFinish: (() -> Void)?
    
    // MARK: - Dependencies
    
    private let viewModel: DebugImportViewModelProtocol
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 20
            static let logContentTop: CGFloat = 10
            static let logContentLeft: CGFloat = 8
            static let logContentBottom: CGFloat = 10
            static let logContentRight: CGFloat = 8
        }
        enum Spacing {
            static let verticalStack: CGFloat = 16
            static let horizontalButtons: CGFloat = 12
            static let inlineElements: CGFloat = 8
        }
        enum Fonts {
            static let bodyLabel: UIFont = .systemFont(ofSize: 16, weight: .regular)
            static let monospacedValue: UIFont  = .monospacedDigitSystemFont(ofSize: 16, weight: .regular)
            static let logText: UIFont   = .systemFont(ofSize: 15)
        }
        enum Sizes {
            static let logViewHeight: CGFloat = 260
            static let logViewCornerRadius: CGFloat = 12
        }
        enum Stepper {
            static let stepValue: Double = 1
            static let minimumValue: Double = 1
        }
        enum Paragraph {
            static let logLineSpacing: CGFloat = 4
        }
    }
    
    // MARK: - Texts
    
    private enum Texts {
        static let navigationTitle = "Импорт данных (DEBUG)"
        static let enableImport = "Включить импорт"
        static let overwriteExisting = "Перезаписывать существующие"
        static let seedVersionTitle = "Версия сид-данных"
        static let runImport = "Импортировать"
        static let resetMarkers = "Сбросить маркеры"
    }
    
    // MARK: - UI
    
    private lazy var enabledLabel: UILabel = {
        let v = UILabel()
        v.text = Texts.enableImport
        v.font = Metrics.Fonts.bodyLabel
        return v
    }()
    
    private lazy var enabledSwitch: UISwitch = {
        let v = UISwitch()
        v.addTarget(
            self,
            action: #selector(enabledChanged(_:)),
            for: .valueChanged
        )
        return v
    }()
    
    private lazy var overwriteLabel: UILabel = {
        let v = UILabel()
        v.text = Texts.overwriteExisting
        v.font = Metrics.Fonts.bodyLabel
        return v
    }()
    
    private lazy var overwriteSwitch: UISwitch = {
        let v = UISwitch()
        v.addTarget(
            self,
            action: #selector(overwriteChanged(_:)),
            for: .valueChanged
        )
        return v
    }()
    
    private lazy var versionTitleLabel: UILabel = {
        let v = UILabel()
        v.text = Texts.seedVersionTitle
        v.font = Metrics.Fonts.bodyLabel
        return v
    }()
    
    private lazy var versionValueLabel: UILabel = {
        let v = UILabel()
        v.font = Metrics.Fonts.monospacedValue
        v.textAlignment = .right
        return v
    }()
    
    private lazy var versionStepper: UIStepper = {
        let v = UIStepper()
        v.minimumValue = Metrics.Stepper.minimumValue
        v.stepValue = Metrics.Stepper.stepValue
        v.addTarget(
            self,
            action: #selector(versionChanged(_:)),
            for: .valueChanged
        )
        return v
    }()
    
    private lazy var importButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle(Texts.runImport, for: .normal)
        v.onTap(self, action: #selector(runImport))
        return v
    }()
    
    private lazy var resetButton: UIButton = {
        let v = UIButton(type: .system)
        v.setTitle(Texts.resetMarkers, for: .normal)
        v.onTap(self, action: #selector(resetMarkers))
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
        v.layer.cornerRadius = Metrics.Sizes.logViewCornerRadius
        v.textContainerInset = .init(
            top: Metrics.Insets.logContentTop,
            left: Metrics.Insets.logContentLeft,
            bottom: Metrics.Insets.logContentBottom,
            right: Metrics.Insets.logContentRight
        )
        v.font = Metrics.Fonts.logText
        v.textColor = .label
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = Metrics.Paragraph.logLineSpacing
        v.typingAttributes[.paragraphStyle] = paragraph
        v.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return v
    }()
    
    // Горизонтальные ряды
    private lazy var toggleRow: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            enabledLabel,
            enabledSwitch
        ])
        v.axis = .horizontal
        v.alignment = .center
        v.distribution = .equalSpacing
        return v
    }()
    
    private lazy var overwriteRow: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            overwriteLabel,
            overwriteSwitch
        ])
        v.axis = .horizontal
        v.alignment = .center
        v.distribution = .equalSpacing
        return v
    }()
    
    private lazy var versionRowRight: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            versionValueLabel,
            versionStepper
        ])
        v.axis = .horizontal
        v.alignment = .center
        v.spacing = Metrics.Spacing.inlineElements
        return v
    }()
    
    private lazy var versionRow: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            versionTitleLabel,
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
        v.spacing = Metrics.Spacing.horizontalButtons
        v.distribution = .fillEqually
        return v
    }()
    
    private lazy var mainStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            toggleRow,
            overwriteRow,
            versionRow,
            buttonsRow,
            activity,
            logView
        ])
        v.axis = .vertical
        v.spacing = Metrics.Spacing.verticalStack
        v.isLayoutMarginsRelativeArrangement = true
        v.layoutMargins = .init(
            top: Metrics.Insets.verticalTop,
            left: Metrics.Insets.horizontal,
            bottom: Metrics.Insets.verticalTop,
            right: Metrics.Insets.horizontal
        )
        return v
    }()
    
    // MARK: - Init
    
    init(viewModel: DebugImportViewModelProtocol) {
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
        viewModel.onStateChange?(viewModel.state)
    }
}

// MARK: - Setup

private extension DebugImportViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupNavigationBar() {
        setupNavigationBar(
            title: Texts.navigationTitle,
            largeTitleDisplayMode: .never,
            prefersLargeTitles: false
        )
    }
    
    func setupHierarchy() {
        view.addSubview(mainStackView)
    }
    
    func setupLayout() {
        [mainStackView, logView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.topAnchor
            ),
            mainStackView.leadingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.leadingAnchor
            ),
            mainStackView.trailingAnchor.constraint(
                equalTo: view.safeAreaLayoutGuide.trailingAnchor
            ),
            mainStackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor
            ),
            
            logView.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.logViewHeight
            )
        ])
    }
}

// MARK: - Bindings

private extension DebugImportViewController {
    func bind() {
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
}

// MARK: - Actions

private extension DebugImportViewController {
    @objc func enabledChanged(_ sender: UISwitch) {
        viewModel.setImporterEnabled(sender.isOn)
    }
    
    @objc func overwriteChanged(_ sender: UISwitch) {
        viewModel.setOverwrite(sender.isOn)
    }
    
    @objc func versionChanged(_ sender: UIStepper) {
        viewModel.setSeedVersion(Int(sender.value))
    }
    
    @objc func runImport() {
        viewModel.runImport()
    }
    
    @objc func resetMarkers() {
        viewModel.resetMarkers()
    }
}
#endif
