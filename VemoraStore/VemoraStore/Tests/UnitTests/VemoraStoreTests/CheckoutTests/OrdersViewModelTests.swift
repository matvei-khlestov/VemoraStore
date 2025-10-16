//
//  OrdersViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class OrdersViewModelTests: XCTestCase {
    private var repo: OrdersRepositorySpy_Orders!
    private var formatter: PriceFormatterMock!
    private var vm: OrdersViewModel!
    private var bag: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        repo = OrdersRepositorySpy_Orders()
        formatter = PriceFormatterMock()
        vm = OrdersViewModel(
            repository: repo,
            priceFormatter: formatter
        )
        bag = []
    }

    override func tearDown() {
        bag = nil
        vm = nil
        formatter = nil
        repo = nil
        super.tearDown()
    }

    private func item(
        _ id: String,
        _ title: String,
        _ price: Double,
        _ qty: Int
    ) -> OrderItem {
        let p = Product(
            id: id,
            name: title,
            description: "",
            nameLower: title.lowercased(),
            categoryId: "c",
            brandId: "b",
            price: price,
            imageURL: "",
            isActive: true,
            createdAt: "",
            updatedAt: "",
            keywords: []
        )
        return OrderItem(product: p, quantity: qty)
    }

    private func order(
        _ id: String,
        items: [OrderItem]
    ) -> OrderEntity {
        OrderEntity(
            id: id,
            userId: "u1",
            createdAt: Date(),
            updatedAt: Date(),
            status: .assembling,
            receiveAddress: "addr",
            paymentMethod: "pm",
            comment: "",
            phoneE164: nil,
            items: items
        )
    }

    func test_ordersPublisher_propagates_and_counts() throws {
        let o1 = order("o1", items: [
            item("p1", "A", 10, 1),
            item("p2", "B", 20, 2)
        ])
        let o2 = order("o2", items: [
            item("p3", "C", 30, 3)
        ])

        let received = try awaitValue(
            vm.ordersPublisher,
            where: { $0.count == 2 },
            after: { self.repo.send([o1, o2]) }
        )
        XCTAssertEqual(received.map(\.id), ["o1", "o2"])
        XCTAssertEqual(vm.sectionsCount, 2)
        XCTAssertEqual(vm.rows(in: 0), 2)
        XCTAssertEqual(vm.rows(in: 1), 1)
        XCTAssertEqual(vm.rows(in: 99), 0)
    }

    func test_order_and_item_accessors() throws {
        let a = item("p1", "A", 10, 1)
        let b = item("p2", "B", 20, 2)
        let o = order("oX", items: [a, b])

        _ = try awaitValue(
            vm.ordersPublisher,
            where: { !$0.isEmpty },
            after: { self.repo.send([o]) }
        )

        XCTAssertEqual(vm.order(at: 0)?.id, "oX")
        XCTAssertNil(vm.order(at: -1))
        XCTAssertNil(vm.order(at: 2))

        let ip0 = IndexPath(row: 0, section: 0)
        let ip1 = IndexPath(row: 1, section: 0)
        let ipBad = IndexPath(row: 9, section: 9)

        XCTAssertEqual(vm.item(at: ip0)?.product.id, "p1")
        XCTAssertEqual(vm.item(at: ip1)?.product.id, "p2")
        XCTAssertNil(vm.item(at: ipBad))
    }

    func test_formattedPrice_delegates_to_formatter() {
        formatter.stub = { "€\(Int($0))" }
        XCTAssertEqual(vm.formattedPrice(1234), "€1234")
    }
}
