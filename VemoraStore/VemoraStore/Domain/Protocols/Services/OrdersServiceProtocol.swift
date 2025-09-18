//
//  OrdersServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import Foundation

protocol OrdersServiceProtocol {
    func fetchOrders() -> [OrderEntity]
}
