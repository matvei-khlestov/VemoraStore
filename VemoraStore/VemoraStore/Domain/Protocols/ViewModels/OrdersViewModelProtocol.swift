//
//  OrdersViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import Foundation

protocol OrdersViewModelProtocol: AnyObject {
    var orders: [OrderEntity] { get }
    var sectionsCount: Int { get }
    func rows(in section: Int) -> Int
    func order(at section: Int) -> OrderEntity?
    func item(at indexPath: IndexPath) -> OrderItem?
}
