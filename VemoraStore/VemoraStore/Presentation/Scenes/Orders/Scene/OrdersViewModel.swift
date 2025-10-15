//
//  OrdersViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import Foundation
import Combine

final class OrdersViewModel: OrdersViewModelProtocol {

    // MARK: - Deps
    
    private let repository: OrdersRepository
    private let priceFormatter: PriceFormattingProtocol

    // MARK: - State
    
    @Published private(set) var orders: [OrderEntity] = []
    
    var ordersPublisher: AnyPublisher<[OrderEntity], Never> {
        $orders.eraseToAnyPublisher()
    }
    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    
    init(
        repository: OrdersRepository,
        priceFormatter: PriceFormattingProtocol
    ) {
        self.repository = repository
        self.priceFormatter = priceFormatter
        bind()
    }

    private func bind() {
        repository.observeOrders()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.orders = $0 }
            .store(in: &bag)
    }

    // MARK: - API (для VC)
    
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
    
    func formattedPrice(_ price: Double) -> String {
        priceFormatter.format(price: price)
    }
}
