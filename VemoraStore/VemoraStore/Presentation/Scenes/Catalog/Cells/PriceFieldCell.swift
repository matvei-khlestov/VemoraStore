//
//  PriceFieldCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 10.10.2025.
//

import UIKit

/// Ячейка `PriceFieldCell` для ввода диапазона цены.
///
/// Основные задачи:
/// - Показывает два поля: «Мин. цена» и «Макс. цена»;
/// - Отправляет изменения через колбэки `onMinChange`/`onMaxChange`;
/// - Имеет тулбар клавиатуры с кнопкой «Готово».
////
/// Особенности:
/// - Капсулы с бордером, фиксированная высота поля;
/// - Нормализует ввод: запятая → точка;
/// - Разрешает только цифры и один разделитель;
/// - Программный апдейт без колбэков (`suppressCallbacksDuring`);
/// - Сброс значений и скрытие клавиатуры в `clearFields()`;
/// - Аккуратная верстка на Auto Layout.

final class PriceFieldCell: UICollectionViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: PriceFieldCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let fieldHeight: CGFloat = 44
            static let containerCorner: CGFloat = 12
            static let borderWidth: CGFloat = 1
        }
        enum Spacing {
            static let horizontal: CGFloat = 12
            static let vertical: CGFloat = 8
            static let fieldsGap: CGFloat = 12
            static let leftPadding: CGFloat = 12
            static let rightPadding: CGFloat = 12
        }
        enum Fonts {
            static let placeholder: UIFont = .systemFont(ofSize: 15, weight: .regular)
            static let text: UIFont = .systemFont(ofSize: 16, weight: .semibold)
        }
        enum Colors {
            static let background: UIColor = .secondarySystemBackground
            static let border: UIColor = .separator
            static let text: UIColor = .label
            static let placeholder: UIColor = .secondaryLabel
        }
    }
    
    // MARK: - Callbacks
    
    var onMinChange: ((String) -> Void)?
    var onMaxChange: ((String) -> Void)?
    
    // MARK: - UI
    
    private let minContainer = UIView()
    private let maxContainer = UIView()
    
    private lazy var minField: UITextField = {
        let tf = makeField(placeholder: Texts.minPrice)
        tf.addTarget(self, action: #selector(minEditingChanged), for: .editingChanged)
        return tf
    }()
    
    private lazy var maxField: UITextField = {
        let tf = makeField(placeholder: Texts.maxPrice)
        tf.addTarget(self, action: #selector(maxEditingChanged), for: .editingChanged)
        return tf
    }()
    
    // MARK: - Texts
    
    private enum Texts {
        static let minPrice = "Мин. цена"
        static let maxPrice = "Макс. цена"
        static let done = "Готово"
    }
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupHierarchy()
        setupLayout()
        setupInputAccessory()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure API
    
    /// Обновить значения без триггера колбэков.
    func configure(min: String?, max: String?) {
        suppressCallbacksDuring {
            minField.text = min
            maxField.text = max
        }
    }
    
    /// Сбросить значения.
    private func reset() {
        configure(min: nil, max: nil)
        contentView.endEditing(true)
    }
    
    /// Очистить значения полей и скрыть клавиатуру.
    func clearFields() {
        reset()
    }
    
    // MARK: - Actions
    
    @objc private func minEditingChanged() {
        onMinChange?(normalizedText(from: minField.text))
    }
    
    @objc private func maxEditingChanged() {
        onMaxChange?(normalizedText(from: maxField.text))
    }
}

// MARK: - Setup

private extension PriceFieldCell {
    func setupAppearance() {
        contentView.backgroundColor = .clear
        [minContainer, maxContainer].forEach {
            $0.backgroundColor = Metrics.Colors.background
            $0.layer.cornerRadius = Metrics.Sizes.containerCorner
            $0.layer.borderWidth = Metrics.Sizes.borderWidth
            $0.layer.borderColor = Metrics.Colors.border.cgColor
        }
    }
    
    func setupHierarchy() {
        minContainer.addSubview(minField)
        maxContainer.addSubview(maxField)
        contentView.addSubviews(minContainer, maxContainer)
    }
    
    private func setupLayout() {
        [minContainer, maxContainer, minField, maxField].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        setupContainerConstraints()
        setupFieldConstraints()
    }
    
    func setupInputAccessory() {
        let bar = UIToolbar(frame: CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: 44
        ))
        let flex = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let done = UIBarButtonItem(
            title: Texts.done,
            style: .done,
            target: self,
            action: #selector(dismissKeyboard)
        )
        bar.items = [flex, done]
        minField.inputAccessoryView = bar
        maxField.inputAccessoryView = bar
    }
    
    @objc func dismissKeyboard() {
        contentView.endEditing(true)
    }
}

// MARK: - Constraints Setup

private extension PriceFieldCell {
    func setupContainerConstraints() {
        NSLayoutConstraint.activate([
            minContainer.topAnchor.constraint(
                equalTo: contentView.topAnchor,
                constant: Metrics.Spacing.vertical
            ),
            minContainer.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor,
                constant: Metrics.Spacing.horizontal
            ),
            minContainer.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Metrics.Sizes.fieldHeight
            ),
            
            maxContainer.topAnchor.constraint(
                equalTo: minContainer.topAnchor
            ),
            maxContainer.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor,
                constant: -Metrics.Spacing.horizontal
            ),
            maxContainer.heightAnchor.constraint(
                equalTo: minContainer.heightAnchor
            ),
            
            maxContainer.leadingAnchor.constraint(
                equalTo: minContainer.trailingAnchor,
                constant: Metrics.Spacing.fieldsGap
            ),
            minContainer.widthAnchor.constraint(
                equalTo: maxContainer.widthAnchor
            ),
            
            maxContainer.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Metrics.Spacing.vertical
            ),
            minContainer.bottomAnchor.constraint(
                equalTo: contentView.bottomAnchor,
                constant: -Metrics.Spacing.vertical
            )
        ])
    }
    
    func setupFieldConstraints() {
        NSLayoutConstraint.activate([
            minField.leadingAnchor.constraint(
                equalTo: minContainer.leadingAnchor,
                constant: Metrics.Spacing.leftPadding
            ),
            minField.trailingAnchor.constraint(
                equalTo: minContainer.trailingAnchor,
                constant: -Metrics.Spacing.rightPadding
            ),
            minField.centerYAnchor.constraint(
                equalTo: minContainer.centerYAnchor
            ),
            
            maxField.leadingAnchor.constraint(
                equalTo: maxContainer.leadingAnchor,
                constant: Metrics.Spacing.leftPadding
            ),
            maxField.trailingAnchor.constraint(
                equalTo: maxContainer.trailingAnchor,
                constant: -Metrics.Spacing.rightPadding
            ),
            maxField.centerYAnchor.constraint(
                equalTo: maxContainer.centerYAnchor
            )
        ])
    }
}

// MARK: - Helpers

private extension PriceFieldCell {
    func makeField(placeholder: String) -> UITextField {
        let tf = UITextField()
        tf.font = Metrics.Fonts.text
        tf.textColor = Metrics.Colors.text
        tf.tintColor = .systemOrange
        tf.keyboardType = .decimalPad
        tf.clearButtonMode = .whileEditing
        
        tf.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: Metrics.Colors.placeholder,
                .font: Metrics.Fonts.placeholder
            ]
        )
        
        tf.delegate = self
        return tf
    }
    
    /// Разрешаем пользователю вводить как `,` так и `.`, наружу отдаём как есть — ViewModel нормализует.
    func normalizedText(from text: String?) -> String {
        guard let t = text?.trimmingCharacters(in: .whitespacesAndNewlines) else { return "" }
        return t.replacingOccurrences(of: ",", with: ".")
    }
    
    /// Удобный helper, чтобы не вызывать колбэки при программной установке текста.
    func suppressCallbacksDuring(_ work: () -> Void) {
        let oldMin = onMinChange
        let oldMax = onMaxChange
        onMinChange = nil
        onMaxChange = nil
        work()
        onMinChange = oldMin
        onMaxChange = oldMax
    }
}

// MARK: - UITextFieldDelegate

extension PriceFieldCell: UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.isEmpty { return true }
        
        let allowed = CharacterSet(charactersIn: "0123456789.,")
        if string.rangeOfCharacter(from: allowed.inverted) != nil { return false }
        
        let current = textField.text ?? ""
        let newText = (current as NSString).replacingCharacters(in: range, with: string)
        let separatorsCount = newText.filter { $0 == "." || $0 == "," }.count
        return separatorsCount <= 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard(); return true
    }
}
