//
//  FormTextView.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 01.10.2025.
//

import UIKit

/// Компонент `FormTextView`.
///
/// Отвечает за:
/// - многострочное поле с заголовком и плейсхолдером;
/// - показ ошибки под полем;
/// - ограничение длины текста (`maxLength`);
/// - фиксированную высоту контейнера (`fixedHeight`);
/// - обратный вызов при изменении текста.
///
/// Структура UI:
/// - `UILabel` — заголовок поля;
/// - `UIView` — контейнер с рамкой и скруглением;
/// - `UITextView` — ввод многострочного текста;
/// - `UILabel` — плейсхолдер внутри контейнера;
/// - `UILabel` — строка ошибки под контейнером;
/// - `UIStackView` — вертикальная компоновка.
///
/// Поведение:
/// - плейсхолдер скрывается при наличии текста;
/// - ошибка показывается после первого взаимодействия,
///   либо сразу при `force = true`;
/// - рамка контейнера меняет цвет/толщину при ошибке;
/// - поддерживается скролл внутри `UITextView`.
///
/// Публичный API:
/// - `onTextChanged: (String) -> Void` — колбэк ввода;
/// - `maxLength: Int?` — лимит символов;
/// - `fixedHeight: CGFloat` — высота контейнера;
/// - `text: String` — значение поля;
/// - `title: String?` — заголовок;
/// - `setText(_:)` — установить текст;
/// - `showError(_:force:)` — показать/скрыть ошибку.
///
/// Использование:
/// - комментарии к заказу на чекауте;

final class FormTextView: UIView {
    
    // MARK: - Public Callbacks
    
    var onTextChanged: ((String) -> Void)?
    
    // MARK: - Public API
    
    /// Опциональный лимит символов
    var maxLength: Int?
    
    /// Фиксированная высота контейнера (по умолчанию 120)
    var fixedHeight: CGFloat = Metrics.Sizes.fixedHeight {
        didSet {
            fixedHeightConstraint?.constant = fixedHeight
        }
    }
    
    var text: String {
        get { textView.text ?? "" }
        set {
            textView.text = newValue
            let isEmpty = newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            placeholderLabel.isHidden = !isEmpty
            updateBorder(isError: pendingError != nil)
        }
    }
    
    var title: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue }
    }
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let content: UIEdgeInsets = .init(
                top: 10,
                left: 12,
                bottom: 10,
                right: 12
            )
        }
        
        enum Spacing {
            static let verticalStack: CGFloat = 6
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 16, weight: .semibold)
            static let placeholder: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let text: UIFont  = .systemFont(ofSize: 15, weight: .regular)
            static let error: UIFont = .systemFont(ofSize: 13, weight: .regular)
        }
        enum Sizes {
            static let fixedHeight: CGFloat = 120
            static let errorHeight: CGFloat = 16
            static let borderErrorWidth: CGFloat = 1.0
            static let borderNormalWidth: CGFloat = 0.5
        }
        enum Corners {
            static let container: CGFloat = 10
        }
        enum Colors {
            static let bg: UIColor = .secondarySystemBackground
            static let text: UIColor = .label
            static let placeholder: UIColor = .secondaryLabel
            static let error: UIColor = .systemRed
            static let borderNormal: CGColor = UIColor.secondarySystemFill.cgColor
            static let borderError: CGColor  = UIColor.systemRed.withAlphaComponent(0.6).cgColor
        }
    }
    
    // MARK: - State
    
    private var hasInteracted = false
    private var pendingError: String?
    private var fixedHeightConstraint: NSLayoutConstraint?
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let v = UILabel()
        v.font = Metrics.Fonts.title
        v.numberOfLines = 1
        return v
    }()
    
    private lazy var container: UIView = {
        let v = UIView()
        v.backgroundColor = Metrics.Colors.bg
        v.layer.cornerRadius = Metrics.Corners.container
        v.layer.borderWidth = Metrics.Sizes.borderNormalWidth
        v.layer.borderColor = Metrics.Colors.borderNormal
        return v
    }()
    
    private lazy var textView: UITextView = {
        let v = UITextView()
        v.font = Metrics.Fonts.text
        v.textColor = Metrics.Colors.text
        v.backgroundColor = .clear
        v.textContainerInset = Metrics.Insets.content
        v.isScrollEnabled = true
        v.alwaysBounceVertical = true
        v.showsVerticalScrollIndicator = true
        v.delegate = self
        return v
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let v = UILabel()
        v.textColor = Metrics.Colors.placeholder
        v.font = Metrics.Fonts.placeholder
        v.numberOfLines = 1
        return v
    }()
    
    private lazy var errorLabel: UILabel = {
        let v = UILabel()
        v.textColor = Metrics.Colors.error
        v.font = Metrics.Fonts.error
        v.numberOfLines = 1
        v.lineBreakMode = .byTruncatingTail
        v.alpha = 0
        return v
    }()
    
    private lazy var contentStack: UIStackView = {
        let v = UIStackView()
        v.axis = .vertical
        v.alignment = .fill
        v.spacing = Metrics.Spacing.verticalStack
        return v
    }()
    
    // MARK: - Initialization
    
    init(
        title: String? = nil,
        placeholder: String? = nil,
        initial: String? = nil
    ) {
        super.init(frame: .zero)
        setupAppearance()
        setupHierarchy()
        setupLayout()
        
        self.title = title
        placeholderLabel.text = placeholder
        text = initial ?? ""
        placeholderLabel.isHidden = !(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup

private extension FormTextView {
    func setupAppearance() {
        backgroundColor = .clear
    }
    
    func setupHierarchy() {
        contentStack.addArrangedSubviews(
            titleLabel,
            container,
            errorLabel
        )
        
        addSubview(contentStack)
        
        container.addSubviews(
            textView,
            placeholderLabel
        )
    }
    
    func setupLayout() {
        prepareForAutoLayout()
        setupContentConstraints()
        setupContainerConstraints()
        setupTextViewConstraints()
        setupPlaceholderConstraints()
        setupErrorConstraints()
        setupFixedHeightConstraint()
    }
}

// MARK: - Layout

private extension FormTextView {
    func prepareForAutoLayout() {
        [contentStack,
         container,
         textView,
         placeholderLabel,
         errorLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupContentConstraints() {
        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(
                equalTo: topAnchor
            ),
            contentStack.leadingAnchor.constraint(
                equalTo: leadingAnchor
            ),
            contentStack.trailingAnchor.constraint(
                equalTo: trailingAnchor
            ),
            contentStack.bottomAnchor.constraint(
                equalTo: bottomAnchor
            )
        ])
        
    }
    
    func setupContainerConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(
                equalTo: contentStack.leadingAnchor
            ),
            container.trailingAnchor.constraint(
                equalTo: contentStack.trailingAnchor
            )
        ])
    }
    
    func setupTextViewConstraints() {
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(
                equalTo: container.topAnchor
            ),
            textView.leadingAnchor.constraint(
                equalTo: container.leadingAnchor
            ),
            textView.trailingAnchor.constraint(
                equalTo: container.trailingAnchor
            ),
            textView.bottomAnchor.constraint(
                equalTo: container.bottomAnchor
            )
        ])
    }
    
    func setupPlaceholderConstraints() {
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(
                equalTo: textView.topAnchor,
                constant: Metrics.Insets.content.top
            ),
            placeholderLabel.leadingAnchor.constraint(
                equalTo: textView.leadingAnchor,
                constant: Metrics.Insets.content.left
            ),
            placeholderLabel.trailingAnchor.constraint(
                lessThanOrEqualTo: textView.trailingAnchor,
                constant: -Metrics.Insets.content.right
            )
        ])
    }
    
    func setupErrorConstraints() {
        NSLayoutConstraint.activate([
            errorLabel.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.errorHeight
            )
        ])
    }
    
    func setupFixedHeightConstraint() {
        let c = container.heightAnchor.constraint(
            equalToConstant: fixedHeight
        )
        c.priority = .required
        c.isActive = true
        fixedHeightConstraint = c
    }
}

// MARK: - Public API

extension FormTextView {
    func setText(_ value: String?) { self.text = value ?? "" }
}

// MARK: - Error API

extension FormTextView {
    /// Обновляет текст ошибки. По умолчанию не форсит показ до первого взаимодействия.
    func showError(_ message: String?, force: Bool = false) {
        pendingError = message
        updateErrorVisibility(force: force)
    }
}

// MARK: - Error Rendering

private extension FormTextView {
    func updateErrorVisibility(force: Bool) {
        let shouldShow = force
        ? (pendingError?.isEmpty == false)
        : (hasInteracted && (pendingError?.isEmpty == false))
        
        errorLabel.text  = shouldShow ? pendingError : ""
        errorLabel.alpha = shouldShow ? 1 : 0
        
        updateBorder(isError: shouldShow)
    }
    
    func updateBorder(isError: Bool) {
        container.layer.borderWidth = isError
        ? Metrics.Sizes.borderErrorWidth
        : Metrics.Sizes.borderNormalWidth
        
        container.layer.borderColor = isError
        ? Metrics.Colors.borderError
        : Metrics.Colors.borderNormal
    }
}

// MARK: - UITextViewDelegate

extension FormTextView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if !hasInteracted { hasInteracted = true }
        updateErrorVisibility(force: false)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let max = maxLength, textView.text.count > max {
            textView.text = String(textView.text.prefix(max))
        }
        let isEmpty = textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        placeholderLabel.isHidden = !isEmpty
        onTextChanged?(textView.text)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateErrorVisibility(force: false)
    }
}
