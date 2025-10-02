//
//  BaseInputSheetViewController.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import UIKit

class BaseInputSheetViewController: UIViewController {
    
    // MARK: - Callbacks
    
    var onSave:  (() -> Void)?
    var onClose: (() -> Void)?
    
    // MARK: - Config
    
    private let config: Config
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let horizontal: CGFloat = 16
            static let verticalTop: CGFloat = 20
            static let verticalBottom: CGFloat = 8
        }
        enum Spacing {
            static let verticalStack: CGFloat = 25
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 17, weight: .semibold)
        }
        enum Sizes {
            static let closeButtonSide: CGFloat = 20
        }
        enum Corners {
            static let sheet: CGFloat = 16
        }
        enum Layout {
            static let closeTop: CGFloat = 15
            static let closeTrailing: CGFloat = -15
        }
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let close = "xmark"
    }
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.text = config.title
        v.font = Metrics.Fonts.title
        v.textAlignment = config.titleAlignment
        v.numberOfLines = 0
        return v
    }()
    
    private lazy var saveButton: BrandedButton = {
        BrandedButton(style: .primary, title: config.saveTitle)
    }()
    
    private lazy var stack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = Metrics.Spacing.verticalStack
        v.isLayoutMarginsRelativeArrangement = true
        v.directionalLayoutMargins = .init(
            top: Metrics.Insets.verticalTop,
            leading: Metrics.Insets.horizontal,
            bottom: Metrics.Insets.verticalTop,
            trailing: Metrics.Insets.horizontal
        )
        return v
    }()
    
    private lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        let cfg = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        b.setImage(UIImage(systemName: Symbols.close, withConfiguration: cfg), for: .normal)
        b.tintColor = .secondaryLabel
        return b
    }()
    
    // Контейнер для пользовательского контента (текстовое поле, текст-вью и т.д.)
    let contentContainer = UIView()
    
    // MARK: - Init
    
    init(config: Config) {
        self.config = config
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .pageSheet
    }
    
    required init?(coder: NSCoder) {
        fatalError("Use init(config:)")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupSheet()
        setupHierarchy()
        setupLayout()
        setupActions()
    }
}

// MARK: - Public API

extension BaseInputSheetViewController {
    /// Вставить контент во встроенный контейнер с пин-констрейнтами
    func attachContentView(_ view: UIView) {
        clearContentContainer()
        addContentView(view)
        constrainContentView(view)
    }
}

// MARK: - Private helpers

private extension BaseInputSheetViewController {
    
    func clearContentContainer() {
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func addContentView(_ view: UIView) {
        contentContainer.addSubview(view)
    }
    
    func constrainContentView(_ view: UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(
                equalTo: contentContainer.topAnchor
            ),
            view.leadingAnchor.constraint(
                equalTo: contentContainer.leadingAnchor
            ),
            view.trailingAnchor.constraint(
                equalTo: contentContainer.trailingAnchor
            ),
            view.bottomAnchor.constraint(
                equalTo: contentContainer.bottomAnchor
            )
        ])
    }
}

// MARK: - Setup

private extension BaseInputSheetViewController {
    func setupAppearance() {
        view.backgroundColor = .systemBackground
    }
    
    func setupSheet() {
        if let sheet = presentationController as? UISheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [.custom { _ in
                    self.config.customDetentHeight
                }]
                sheet.prefersScrollingExpandsWhenScrolledToEdge = true
            } else {
                sheet.detents = [.medium()]
            }
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = Metrics.Corners.sheet
            sheet.largestUndimmedDetentIdentifier = nil
        }
    }
    
    func setupHierarchy() {
        stack.addArrangedSubviews(
            titleLabel,
            contentContainer,
            saveButton
        )
        view.addSubviews(stack, closeButton)
    }
    
    func setupLayout() {
        [stack, closeButton, contentContainer].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(
                equalTo: view.topAnchor
            ),
            stack.leadingAnchor.constraint(
                equalTo: view.leadingAnchor
            ),
            stack.trailingAnchor.constraint(
                equalTo: view.trailingAnchor
            ),
            stack.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor,
                constant: -Metrics.Insets.verticalBottom
            ),
            
            closeButton.topAnchor.constraint(
                equalTo: view.topAnchor,
                constant: Metrics.Layout.closeTop
            ),
            closeButton.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: Metrics.Layout.closeTrailing
            ),
            closeButton.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.closeButtonSide
            ),
            closeButton.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.closeButtonSide
            )
        ])
        view.bringSubviewToFront(closeButton)
    }
    
    func setupActions() {
        saveButton.onTap(self, action: #selector(saveTapped))
        closeButton.onTap(self, action: #selector(closeTapped))
    }
}

// MARK: - Actions

@objc private extension BaseInputSheetViewController {
    func saveTapped()  { onSave?() }
    func closeTapped() { onClose?() }
}
