//
//  PaddedField.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import UIKit

/// Тип поля — управляет клавиатурой/капсом и др. настройками
public enum PaddedFieldKind {
    case apt        // квартира
    case entrance   // подъезд
    case floor      // этаж
    case intercom   // домофон (буквы+цифры, CAPS)
}

/// Состояние визуала поля
public enum PaddedFieldState {
    case normal
    case active
    case error
}

public final class PaddedField: UITextField {

    // MARK: - Public API

    public private(set) var kind: PaddedFieldKind
    public private(set) var fieldState: PaddedFieldState = .normal

    /// Программная установка состояния с короткой анимацией
    @discardableResult
    public func setState(_ state: PaddedFieldState, animated: Bool = true) -> Self {
        fieldState = state
        let changes: () -> Void = { [weak self] in
            guard let self = self else { return }
            self.applyCurrentState()
        }
        if animated {
            UIView.animate(withDuration: 0.18, animations: changes)
        } else {
            changes()
        }
        return self
    }

    /// Удобный инициализатор
    public convenience init(kind: PaddedFieldKind, placeholder: String? = nil) {
        self.init(frame: .zero, kind: kind)
        self.placeholder = placeholder
    }

    // MARK: - Init

    public init(frame: CGRect = .zero, kind: PaddedFieldKind) {
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

    private let insets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)

    public override func textRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
    public override func editingRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }
    public override func placeholderRect(forBounds bounds: CGRect) -> CGRect { bounds.inset(by: insets) }

    // MARK: - First responder -> визуальные состояния

    public override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        // Если явно не error — делаем active
        if fieldState != .error { setState(.active, animated: true) }
        return ok
    }

    public override func resignFirstResponder() -> Bool {
        let ok = super.resignFirstResponder()
        // Если явно не error — возвращаем normal
        if fieldState != .error { setState(.normal, animated: true) }
        return ok
    }
}

// MARK: - Private

private extension PaddedField {

    func commonInit() {
        // Базовые стили
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 16
        layer.borderWidth = 1.5

        clearButtonMode = .whileEditing
        returnKeyType = .done
        autocorrectionType = .no
        spellCheckingType = .no

        // Клавиатуры и капс по типу поля
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

        // Начальное состояние
        applyCurrentState()
        // Слушатели для вручную выставленного error → нормализация при вводе
        addTarget(self, action: #selector(onEditingChanged), for: .editingChanged)
        addTarget(self, action: #selector(onEditingDidBegin), for: .editingDidBegin)
        addTarget(self, action: #selector(onEditingDidEnd),   for: .editingDidEnd)
    }

    func applyCurrentState() {
        switch fieldState {
        case .normal:
            layer.borderColor = UIColor.quaternaryLabel.cgColor

        case .active:
            layer.borderColor = UIColor.brightPurple.cgColor

        case .error:
            layer.borderColor = UIColor.systemRed.cgColor
        }
    }

    @objc func onEditingChanged() {
        // Если было error и пользователь начал ввод — вернуть active
        if fieldState == .error {
            setState(.active, animated: true)
        }
    }

    @objc func onEditingDidBegin() {
        // Если не error — актив
        if fieldState != .error {
            setState(.active, animated: true)
        }
    }

    @objc func onEditingDidEnd() {
        // Если не error — нормал
        if fieldState != .error {
            setState(.normal, animated: true)
        }
    }
}
