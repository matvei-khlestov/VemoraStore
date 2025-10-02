//
//  AddToCartButton.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import UIKit

/// Универсальная кнопка «добавить в корзину» с готовым стилем и анимацией.
/// Иконка переключается между плюс/минус через `setInCart(_:animated:)`.
final class AddToCartButton: UIButton {
    
    // MARK: - Constants
    
    private enum Metrics {
        enum Sizes {
            static let symbolPointSize: CGFloat = 23
        }
        
        enum Durations {
            static let iconTransition: TimeInterval = 0.18
        }
    }
    
    private enum Symbols {
        static let addToCart = "cart.badge.plus"
        static let removeFromCart = "cart.fill.badge.minus"
    }
    
    // MARK: - State
    
    private var symbolPointSize: CGFloat
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        symbolPointSize = Metrics.Sizes.symbolPointSize
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        symbolPointSize = Metrics.Sizes.symbolPointSize
        super.init(coder: coder)
        commonInit()
    }
    
    convenience init(symbolPointSize: CGFloat) {
        self.init(frame: .zero)
        self.symbolPointSize = symbolPointSize
        commonInit()
    }
    
    // MARK: - Public
    
    /// Обновляет иконку кнопки в зависимости от состояния.
    func setInCart(_ value: Bool, animated: Bool = true) {
        let img = UIImage(systemName: value ? Symbols.removeFromCart : Symbols.addToCart)
        let apply = { self.setImage(img, for: .normal) }
        if animated {
            UIView.transition(
                with: self,
                duration: Metrics.Durations.iconTransition,
                options: .transitionCrossDissolve,
                animations: apply
            )
        } else {
            apply()
        }
    }
    
    // MARK: - Private
    
    private func commonInit() {
        let cfg = UIImage.SymbolConfiguration(
            pointSize: symbolPointSize,
            weight: .light
        )
        setPreferredSymbolConfiguration(cfg, forImageIn: .normal)
        setImage(UIImage(systemName: Symbols.addToCart), for: .normal)
        tintColor = .brightPurple
        clipsToBounds = false
    }
}
