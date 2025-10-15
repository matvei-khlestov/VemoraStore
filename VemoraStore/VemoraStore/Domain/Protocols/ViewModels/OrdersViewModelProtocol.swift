//
//  OrdersViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import Foundation
import Combine

protocol OrdersViewModelProtocol: AnyObject {
    var ordersPublisher: AnyPublisher<[OrderEntity], Never> { get }
    var sectionsCount: Int { get }
    func rows(in section: Int) -> Int
    func order(at section: Int) -> OrderEntity?
    func item(at indexPath: IndexPath) -> OrderItem?
    func formattedPrice(_ price: Double) -> String
}
