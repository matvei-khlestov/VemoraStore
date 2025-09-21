//
//  UnderlinedButton.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 22.09.2025.
//

import UIKit

final class UnderlinedButton: UIButton {
    
    private var underlineColor: UIColor
    private var underlineFont: UIFont
    
    // MARK: - Init
    convenience init(
        text: String,
        color: UIColor = .brightPurple,
        font: UIFont = .systemFont(ofSize: 16),
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
        self.underlineColor = .brightPurple
        self.underlineFont = .systemFont(ofSize: 16)
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.underlineColor = .brightPurple
        self.underlineFont = .systemFont(ofSize: 16)
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
        if let color { underlineColor = color }
        if let font  { underlineFont = font }
        let text = (attributedTitle(for: .normal)?.string) ?? (title(for: .normal) ?? "")
        setText(text)
    }
    
    // MARK: - Private
    private func commonInit() {
        titleLabel?.numberOfLines = 0
        titleLabel?.lineBreakMode = .byWordWrapping
    }
}
