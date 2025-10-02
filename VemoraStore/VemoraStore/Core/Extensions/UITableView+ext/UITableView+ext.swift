//
//  UITableView+ext.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 28.09.2025.
//

import UIKit

// MARK: - UITableView + Register

extension UITableView {
    func register<T: UITableViewCell>(_ cellClass: T.Type) {
        register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
    }
    
    func register(_ cellClasses: [UITableViewCell.Type]) {
        cellClasses.forEach { cellClass in
            register(cellClass, forCellReuseIdentifier: String(describing: cellClass))
        }
    }
    
    func dequeueReusableCell<T: UITableViewCell>(
        for indexPath: IndexPath,
        as type: T.Type = T.self
    ) -> T {
        guard let cell = dequeueReusableCell(
            withIdentifier: String(describing: T.self),
            for: indexPath
        ) as? T else {
            fatalError("Could not dequeue cell with type \(T.self)")
        }
        return cell
    }
    
    /// Удобный доступ к видимой ячейке нужного типа
    func visibleCell<T: UITableViewCell>(at indexPath: IndexPath) -> T? {
        cellForRow(at: indexPath) as? T
    }
}
