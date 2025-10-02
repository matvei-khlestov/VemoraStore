//
//  FavoriteButton.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import UIKit

/// Универсальная кнопка «избранное» с готовым стилем и анимацией.
/// Иконка переключается между пустым и заполненным сердцем через `setFavorite(_:animated:)`.
final class FavoriteButton: UIButton {
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let defaultPointSize: CGFloat = 22
            static let intrinsicMultiplier: CGFloat = 1.5
        }
        
        enum Durations {
            static let iconTransition: TimeInterval = 0.18
        }
    }
    
    // MARK: - Symbols
    
    private enum Symbols {
        static let heart = "heart"
        static let heartFill = "heart.fill"
    }
    
    // MARK: - Props
    
    private let pointSize: CGFloat
    
    // MARK: - Init
    
    init(pointSize: CGFloat = Metrics.Sizes.defaultPointSize) {
        self.pointSize = pointSize
        super.init(frame: .zero)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        self.pointSize = Metrics.Sizes.defaultPointSize
        super.init(coder: coder)
        commonInit()
    }
    
    // MARK: - Public
    
    /// Обновляет иконку кнопки в зависимости от состояния.
    func setFavorite(_ value: Bool, animated: Bool = true) {
        let name = value ? Symbols.heartFill : Symbols.heart
        let newImage = UIImage(
            systemName: name,
            withConfiguration: UIImage.SymbolConfiguration(
                pointSize: pointSize,
                weight: .regular
            )
        )
        
        let apply: () -> Void = { self.configuration?.image = newImage }
        
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
        configuration = buildConfiguration()
        
        setContentHuggingPriority(.required, for: .horizontal)
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    private func buildConfiguration() -> UIButton.Configuration {
        var cfg = UIButton.Configuration.plain()
        cfg.baseBackgroundColor = .systemBackground
        cfg.baseForegroundColor = .brightPurple
        
        let symbolConfig = UIImage.SymbolConfiguration(
            pointSize: pointSize,
            weight: .regular
        )
        cfg.image = UIImage(systemName: Symbols.heart, withConfiguration: symbolConfig)
        cfg.imagePlacement = .all
        return cfg
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(
            width: pointSize * Metrics.Sizes.intrinsicMultiplier,
            height: pointSize * Metrics.Sizes.intrinsicMultiplier
        )
    }
}
