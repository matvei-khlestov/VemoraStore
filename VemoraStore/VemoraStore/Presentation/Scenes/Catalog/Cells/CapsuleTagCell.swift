//
//  CapsuleTagCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 09.10.2025.
//

import UIKit
import Kingfisher

final class CapsuleTagCell: UICollectionViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: CapsuleTagCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let imageSide: CGFloat = 30
            static let capsuleMinHeight: CGFloat = 40
            static let borderWidth: CGFloat = 0.8
        }
        enum Corners {
            static let image: CGFloat = Sizes.imageSide / 2
            static let capsule: CGFloat = 20
        }
        enum Spacing {
            static let horizontal: CGFloat = 12
            static let imageToTitle: CGFloat = 8
            static let vertical: CGFloat = 6
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 16, weight: .medium)
        }
        enum Colors {
            static let capsuleBg: UIColor = .systemBackground
            static let capsuleBorder: UIColor = .separator
            static let title: UIColor = .label
            
            // Selected
            static let capsuleBgSelected: UIColor = .label.withAlphaComponent(0.08)
            static let capsuleBorderSelected: UIColor = .label
            static let titleSelected: UIColor = .label
        }
    }
    
    // MARK: - UI
    
    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = Metrics.Colors.capsuleBg
        v.layer.cornerRadius = Metrics.Corners.capsule
        v.layer.borderWidth = Metrics.Sizes.borderWidth
        v.layer.borderColor = Metrics.Colors.capsuleBorder.cgColor
        return v
    }()
    
    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = Metrics.Corners.image
        iv.backgroundColor = .secondarySystemBackground
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = Metrics.Fonts.title
        l.textColor = Metrics.Colors.title
        l.numberOfLines = 1
        return l
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
        setupHierarchy()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Configure API
    
    func configure(title: String, imageURL: String?, isSelected: Bool) {
        titleLabel.text = title
        
        if let urlString = imageURL, let url = URL(string: urlString) {
            iconView.kf.setImage(with: url, placeholder: nil)
        } else {
            iconView.image = nil
        }
        
        setSelected(isSelected)
        // A11y
        isAccessibilityElement = true
        accessibilityLabel = title
        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
    }
    
    // MARK: - Selection
    
    override var isSelected: Bool {
        didSet {
            setSelected(isSelected)
        }
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            containerView.backgroundColor = Metrics.Colors.capsuleBgSelected
            containerView.layer.borderColor = Metrics.Colors.capsuleBorderSelected.cgColor
            titleLabel.textColor = Metrics.Colors.titleSelected
        } else {
            containerView.backgroundColor = Metrics.Colors.capsuleBg
            containerView.layer.borderColor = Metrics.Colors.capsuleBorder.cgColor
            titleLabel.textColor = Metrics.Colors.title
        }
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconView.kf.cancelDownloadTask()
        iconView.image = nil
        titleLabel.text = nil
        setSelected(false)
    }
    
    // MARK: - Self sizing
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes
    ) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let targetSize = CGSize(
            width: layoutAttributes.size.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let size = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .fittingSizeLevel
        )

        layoutAttributes.size = CGSize(
            width: ceil(size.width),
            height: max(Metrics.Sizes.capsuleMinHeight, ceil(size.height))
        )
        return layoutAttributes
    }
}

// MARK: - Setup

private extension CapsuleTagCell {
    func setupAppearance() {
        contentView.backgroundColor = .clear
    }
    
    func setupHierarchy() {
        contentView.addSubview(containerView)
        containerView.addSubviews(iconView, titleLabel)
    }
}

// MARK: - Layout

private extension CapsuleTagCell {
    func setupLayout() {
        prepareForAutoLayout()
        setupContainerConstraints()
        setupIconConstraints()
        setupTitleConstraints()
    }
    
    func prepareForAutoLayout() {
        [containerView, iconView, titleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupContainerConstraints() {
        let cv = contentView
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(
                equalTo: cv.topAnchor
            ),
            containerView.leadingAnchor.constraint(
                equalTo: cv.leadingAnchor
            ),
            containerView.trailingAnchor.constraint(
                equalTo: cv.trailingAnchor
            ),
            containerView.bottomAnchor.constraint(
                equalTo: cv.bottomAnchor
            ),
            containerView.heightAnchor.constraint(
                greaterThanOrEqualToConstant: Metrics.Sizes.capsuleMinHeight
            )
        ])
    }
    
    func setupIconConstraints() {
        NSLayoutConstraint.activate([
            iconView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Metrics.Spacing.horizontal
            ),
            iconView.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            ),
            iconView.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.imageSide
            ),
            iconView.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.imageSide
            )
        ])
    }
    
    func setupTitleConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(
                equalTo: iconView.trailingAnchor,
                constant: Metrics.Spacing.imageToTitle
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: containerView.trailingAnchor,
                constant: -Metrics.Spacing.horizontal
            ),
            titleLabel.centerYAnchor.constraint(
                equalTo: containerView.centerYAnchor
            )
        ])

        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
}
