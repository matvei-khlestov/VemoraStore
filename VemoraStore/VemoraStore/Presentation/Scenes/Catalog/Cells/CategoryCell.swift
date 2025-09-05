//
//  CategoryCell.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 04.09.2025.
//

import UIKit

final class CategoryCell: UICollectionViewCell {
    static let reuseId = "CategoryCell"

    private let circleImage: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = .red
        return iv
    }()

    private let titleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 15, weight: .semibold)
        l.textAlignment = .center
        l.numberOfLines = 1
        return l
    }()

    private let subtitleLabel: UILabel = {
        let l = UILabel()
        l.font = .systemFont(ofSize: 12)
        l.textColor = .secondaryLabel
        l.textAlignment = .center
        return l
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(circleImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        circleImage.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            circleImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            circleImage.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            circleImage.widthAnchor.constraint(equalToConstant: 64),
            circleImage.heightAnchor.constraint(equalToConstant: 64),

            titleLabel.topAnchor.constraint(equalTo: circleImage.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            subtitleLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])

        circleImage.layer.cornerRadius = 32
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(title: String, count: Int, imageURL: URL?) {
        titleLabel.text = title
        subtitleLabel.text = "\(count) Products"
        // circleImage.kf.setImage(with: imageURL)
    }
}

