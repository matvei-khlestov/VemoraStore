//
//  UICollectionView+ext.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 28.09.2025.
//

import UIKit

extension UICollectionView {
    
    // MARK: - Registration
    
    func register<T: UICollectionViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
    }
    
    func register(_ cellClasses: [UICollectionViewCell.Type]) {
        cellClasses.forEach { cellClass in
            register(cellClass, forCellWithReuseIdentifier: String(describing: cellClass))
        }
    }
    
    func register<T: UICollectionReusableView>(
        _ viewClass: T.Type,
        forSupplementaryViewOfKind kind: String
    ) {
        register(
            viewClass,
            forSupplementaryViewOfKind: kind,
            withReuseIdentifier: String(describing: viewClass)
        )
    }
    
    // MARK: - Dequeuing
    
    func dequeueReusableCell<T: UICollectionViewCell>(
        _ cellClass: T.Type,
        for indexPath: IndexPath
    ) -> T {
        guard let cell = dequeueReusableCell(
            withReuseIdentifier: String(describing: cellClass),
            for: indexPath
        ) as? T else {
            fatalError(
                "Could not dequeue cell with identifier: \(String(describing: cellClass))"
            )
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(
        _ viewClass: T.Type,
        ofKind kind: String,
        for indexPath: IndexPath
    ) -> T {
        guard let view = dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: String(describing: viewClass),
            for: indexPath
        ) as? T else {
            fatalError(
                "Could not dequeue supplementary view with identifier: \(String(describing: viewClass))"
            )
        }
        return view
    }
}
