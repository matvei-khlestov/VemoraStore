//
//  PaddedField.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import UIKit

/// Компонент `PaddedField`.
///
/// Отвечает за:
/// - текстовое поле c внутренними отступами и закруглёнными углами;
/// - визуальные состояния: `.normal`, `.active`, `.error`;
/// - анимированное переключение рамки при смене состояния;
/// - подбор клавиатуры и контента по `PaddedFieldKind`.
///
/// Структура и поведение:
/// - наследуется от `UITextField`;
/// - внутренние отступы переопределены через `textRect(...)`,
///   `editingRect(...)`, `placeholderRect(...)`;
/// - при фокусе/потере фокуса обновляет состояние
///   (кроме режима `.error`, который фиксирует красную рамку).
///
/// Публичный API:
/// - `kind` — тип поля (`apt`, `entrance`, `floor`, `intercom`);
/// - `fieldState` — текущее состояние отображения;
/// - `setState(_:animated:)` — установить состояние с анимацией;
/// - `init(kind:placeholder:)` — удобный инициализатор.
///
/// Используется:
/// - формы адреса доставки (квартира, подъезд, этаж, домофон);
/// - любые короткие числовые/кодовые поля с подсветкой ошибок.

final class PaddedField: UITextField {
    
    // MARK: - Public API
    
    private(set) var kind: PaddedFieldKind
    private(set) var fieldState: PaddedFieldState = .normal
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Insets {
            static let text = UIEdgeInsets(
                top: 0,
                left: 12,
                bottom: 0,
                right: 12
            )
        }
        
        enum Corners {
            static let field: CGFloat = 16
        }
        
        enum Sizes {
            static let borderWidth: CGFloat = 1.5
        }
        
        enum Durations {
            static let stateTransition: TimeInterval = 0.18
        }
    }
    
    // MARK: - Colors
    
    private enum Colors {
        static let background: UIColor = .secondarySystemBackground
        static let borderNormal: CGColor = UIColor.quaternaryLabel.cgColor
        static let borderActive: CGColor = UIColor.brightPurple.cgColor
        static let borderError:  CGColor = UIColor.systemRed.cgColor
    }
    
    /// Программная установка состояния с короткой анимацией
    @discardableResult
    func setState(_ state: PaddedFieldState, animated: Bool = true) -> Self {
        fieldState = state
        let updates: () -> Void = { [weak self] in
            self?.applyCurrentState()
        }
        if animated {
            UIView.animate(
                withDuration: Metrics.Durations.stateTransition,
                animations: updates
            )
        } else {
            updates()
        }
        return self
    }
    
    /// Удобный инициализатор
    convenience init(kind: PaddedFieldKind, placeholder: String? = nil) {
        self.init(frame: .zero, kind: kind)
        self.placeholder = placeholder
    }
    
    // MARK: - Init
    
    init(frame: CGRect = .zero, kind: PaddedFieldKind) {
        self.kind = kind
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.kind = .apt
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Layout (padding)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: Metrics.Insets.text)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: Metrics.Insets.text)
    }
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        bounds.inset(by: Metrics.Insets.text)
    }
    
    // MARK: - First Responder
    
    override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        if fieldState != .error { setState(.active, animated: true) }
        return ok
    }
    
    override func resignFirstResponder() -> Bool {
        let ok = super.resignFirstResponder()
        if fieldState != .error { setState(.normal, animated: true) }
        return ok
    }
}

// MARK: - Setup

private extension PaddedField {
    func commonInit() {
        setupAppearance()
        setupBehavior()
        applyCurrentState()
        hookTargets()
    }
    
    func setupAppearance() {
        backgroundColor = Colors.background
        layer.cornerRadius = Metrics.Corners.field
        layer.cornerCurve = .continuous
        layer.borderWidth = Metrics.Sizes.borderWidth
    }
    
    func setupBehavior() {
        clearButtonMode = .whileEditing
        returnKeyType = .done
        autocorrectionType = .no
        spellCheckingType = .no
        
        switch kind {
        case .apt, .entrance, .floor:
            keyboardType = .numberPad
            textContentType = .oneTimeCode
            autocapitalizationType = .none
        case .intercom:
            keyboardType = .asciiCapable
            autocapitalizationType = .allCharacters
            textContentType = .oneTimeCode
        }
    }
    
    func hookTargets() {
        addTarget(self, action: #selector(onEditingChanged), for: .editingChanged)
        addTarget(self, action: #selector(onEditingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(onEditingDidEnd),   for: .editingDidEnd)
    }
    
    func applyCurrentState() {
        switch fieldState {
        case .normal: layer.borderColor = Colors.borderNormal
        case .active: layer.borderColor = Colors.borderActive
        case .error:  layer.borderColor = Colors.borderError
        }
    }
}

// MARK: - Events

private extension PaddedField {
    @objc func onEditingChanged() {
        if fieldState == .error {
            setState(.active, animated: true)
        }
    }
    
    @objc func onEditingDidBegin() {
        if fieldState != .error {
            setState(.active, animated: true)
        }
    }
    
    @objc func onEditingDidEnd() {
        if fieldState != .error {
            setState(.normal, animated: true)
        }
    }
}
