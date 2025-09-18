//
//  OrdersViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import Foundation

final class OrdersViewModel: OrdersViewModelProtocol {
    
    // MARK: - Deps
    private let service: OrdersServiceProtocol
    
    // MARK: - State
    private(set) var orders: [OrderEntity] = []
    
    // MARK: - Init
    init(service: OrdersServiceProtocol) {
        self.service = service
        self.orders = service.fetchOrders()
    }
    
    // MARK: - API
    var sectionsCount: Int { orders.count }
    func rows(in section: Int) -> Int {
        guard orders.indices.contains(section) else { return 0 }
        return orders[section].items.count
    }
    func order(at section: Int) -> OrderEntity? {
        guard orders.indices.contains(section) else { return nil }
        return orders[section]
    }
    func item(at indexPath: IndexPath) -> OrderItem? {
        guard orders.indices.contains(indexPath.section) else { return nil }
        let items = orders[indexPath.section].items
        guard items.indices.contains(indexPath.row) else { return nil }
        return items[indexPath.row]
    }
}
