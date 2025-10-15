//
//  CategoryCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 04.09.2025.
//

import UIKit
import Kingfisher

final class CategoryCell: UICollectionViewCell {
    
    // MARK: - Reuse Id
    
    static let reuseId = String(describing: CategoryCell.self)
    
    // MARK: - Metrics
    
    private enum Metrics {
        enum Sizes {
            static let imageSide: CGFloat = 64
        }
        enum Corners {
            static let imageCircle: CGFloat = 32
        }
        enum Spacing {
            static let imageToTitle: CGFloat = 6
            static let titleToSubtitle: CGFloat = 2
        }
        enum Insets {
            static let labelsHorizontal: CGFloat = 4
        }
        enum Fonts {
            static let title: UIFont = .systemFont(ofSize: 15, weight: .semibold)
            static let subtitle: UIFont = .systemFont(ofSize: 12, weight: .regular)
        }
        enum Colors {
            static let imageBackground: UIColor = .secondarySystemBackground
            static let subtitleText: UIColor = .secondaryLabel
        }
    }
    
    // MARK: - UI
    
    private let circleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = Metrics.Colors.imageBackground
        imageView.image = UIImage(resource: .divan) // заглушка
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = CategoryCell.makeLabel(
            font: Metrics.Fonts.title,
            alignment: .center
        )
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        CategoryCell.makeLabel(
            font: Metrics.Fonts.subtitle,
            textColor: Metrics.Colors.subtitleText,
            alignment: .center
        )
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
    
    func configure(category: Category, count: Int) {
        titleLabel.text = category.name
        subtitleLabel.text = "\(count) Products"
        circleImageView.loadImage(from: category.imageURL)
    }
}

// MARK: - Setup

private extension CategoryCell {
    func setupAppearance() {
        contentView.backgroundColor = .clear
        circleImageView.layer.cornerRadius = Metrics.Corners.imageCircle
    }
    
    func setupHierarchy() {
        contentView.addSubviews(
            circleImageView,
            titleLabel,
            subtitleLabel
        )
    }
}

// MARK: - Layout

private extension CategoryCell {
    func setupLayout() {
        prepareForAutoLayout()
        setupImageConstraints()
        setupLabelsConstraints()
    }
    
    func prepareForAutoLayout() {
        [circleImageView, titleLabel, subtitleLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func setupImageConstraints() {
        let cv = contentView
        NSLayoutConstraint.activate([
            circleImageView.topAnchor.constraint(
                equalTo: cv.topAnchor
            ),
            circleImageView.centerXAnchor.constraint(
                equalTo: cv.centerXAnchor
            ),
            circleImageView.widthAnchor.constraint(
                equalToConstant: Metrics.Sizes.imageSide
            ),
            circleImageView.heightAnchor.constraint(
                equalToConstant: Metrics.Sizes.imageSide
            )
        ])
    }
    
    func setupLabelsConstraints() {
        let cv = contentView
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(
                equalTo: circleImageView.bottomAnchor,
                constant: Metrics.Spacing.imageToTitle
            ),
            titleLabel.leadingAnchor.constraint(
                equalTo: cv.leadingAnchor,
                constant: Metrics.Insets.labelsHorizontal
            ),
            titleLabel.trailingAnchor.constraint(
                equalTo: cv.trailingAnchor,
                constant: -Metrics.Insets.labelsHorizontal
            ),
            
            subtitleLabel.topAnchor.constraint(
                equalTo: titleLabel.bottomAnchor,
                constant: Metrics.Spacing.titleToSubtitle
            ),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: titleLabel.leadingAnchor
            ),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: titleLabel.trailingAnchor
            ),
            subtitleLabel.bottomAnchor.constraint(
                lessThanOrEqualTo: cv.bottomAnchor
            )
        ])
    }
}

// MARK: - Helpers

private extension CategoryCell {
    static func makeLabel(
        font: UIFont,
        textColor: UIColor = .label,
        alignment: NSTextAlignment = .left,
        numberOfLines: Int = 1
    ) -> UILabel {
        let label = UILabel()
        label.font = font
        label.textColor = textColor
        label.textAlignment = alignment
        label.numberOfLines = numberOfLines
        return label
    }
}
