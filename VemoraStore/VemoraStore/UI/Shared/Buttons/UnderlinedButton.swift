//
//  UnderlinedButton.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import UIKit

/// Компонент `UnderlinedButton`.
///
/// Отвечает за:
/// - отображение текста в виде ссылки с подчёркиванием;
/// - возможность настройки цвета и шрифта;
/// - адаптацию под разное горизонтальное выравнивание.
///
/// Структура и поведение:
/// - наследуется от `UIButton` (`.system`);
/// - использует `NSAttributedString` с атрибутами:
///   `.underlineStyle`, `.foregroundColor`, `.font`;
/// - поддерживает перенос текста по словам.
///
/// Публичный API:
/// - `init(text:color:font:alignment:)` — инициализация с параметрами;
/// - `setText(_:)` — установка текста с подчёркиванием;
/// - `applyStyle(color:font:)` — изменение стиля (цвет и шрифт).
///
/// Используется:
/// - для отображения интерактивных ссылок (например, "Забыли пароль?");
/// - в нижних строках форм авторизации или регистрации.

final class UnderlinedButton: UIButton {
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Fonts {
            static let underline: UIFont = .systemFont(ofSize: 16)
        }
    }
    
    // MARK: - Colors
    
    private enum Colors {
        static let underline: UIColor = .brightPurple
    }
    
    // MARK: - State
    
    private var underlineColor: UIColor
    private var underlineFont: UIFont
    
    // MARK: - Init
    
    convenience init(
        text: String,
        color: UIColor = Colors.underline,
        font: UIFont = Metrics.Fonts.underline,
        alignment: UIControl.ContentHorizontalAlignment = .leading
    ) {
        self.init(type: .system)
        self.underlineColor = color
        self.underlineFont = font
        commonInit()
        contentHorizontalAlignment = alignment
        setText(text)
    }
    
    override init(frame: CGRect) {
        self.underlineColor = Colors.underline
        self.underlineFont = Metrics.Fonts.underline
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.underlineColor = Colors.underline
        self.underlineFont = Metrics.Fonts.underline
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Public
    
    func setText(_ text: String) {
        let attrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: underlineColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: underlineFont
        ]
        setAttributedTitle(NSAttributedString(string: text, attributes: attrs), for: .normal)
    }
    
    func applyStyle(color: UIColor? = nil, font: UIFont? = nil) {
        if let color {
            underlineColor = color
        }
        if let font {
            underlineFont = font
        }
        let text = (attributedTitle(for: .normal)?.string) ?? (title(for: .normal) ?? "")
        setText(text)
    }
    
    // MARK: - Private
    
    private func commonInit() {
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
    }
}
