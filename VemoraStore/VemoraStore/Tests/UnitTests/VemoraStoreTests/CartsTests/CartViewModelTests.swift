//
//  CartViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
import UserNotifications
@testable import VemoraStore

final class CartViewModelTests: XCTestCase {
    
    private var cartRepo: CartRepositoryMock!
    private var formatter: PriceFormatterMock!
    private var notifier: NotifierMock!
    private var vm: CartViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        cartRepo = CartRepositoryMock()
        formatter = PriceFormatterMock()
        notifier  = NotifierMock()
        vm = CartViewModel(
            cartRepository: cartRepo,
            priceFormatter: formatter,
            notifier: notifier
        )
        bag = []
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        notifier = nil
        formatter = nil
        cartRepo = nil
        super.tearDown()
    }
    
    // MARK: - Publishers / Propagation
    
    func test_cartItems_propagate_and_accessors() throws {
        let now = Date()
        let items: [CartItem] = [
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "B1",
                title: "T1",
                price: 100,
                imageURL: nil,
                quantity: 2,
                updatedAt: now
            ),
            .init(
                userId: "u1",
                productId: "p2",
                brandName: "B2",
                title: "T2",
                price: 50,
                imageURL: nil,
                quantity: 3,
                updatedAt: now
            )
        ]
        
        let received = try awaitValue(
            vm.cartItemsPublisher,
            where: { !$0.isEmpty },
            after: { self.cartRepo.itemsSubject.send(items) }
        )
        
        XCTAssertEqual(received.count, 2)
        XCTAssertEqual(vm.cartItems, items)
        XCTAssertEqual(vm.count, 2)
        XCTAssertEqual(vm.item(at: IndexPath(row: 0, section: 0)).productId, "p1")
        XCTAssertEqual(vm.totalItems, 5)
        XCTAssertEqual(vm.totalPrice, 350)
    }
    
    // MARK: - Quantity: set / increase / decrease
    
    func test_setQuantity_clamps_to_min1_and_updates_local_and_repo() {
        let now = Date()
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 4,
                updatedAt: now
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.setQuantity(for: "p1", quantity: 0)
        vm.setQuantity(for: "p1", quantity: 5)
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cartRepo.setQtyCalls.count, 2)
        XCTAssertEqual(cartRepo.setQtyCalls[0].productId, "p1")
        XCTAssertEqual(cartRepo.setQtyCalls[0].qty, 1)
        XCTAssertEqual(cartRepo.setQtyCalls[1].productId, "p1")
        XCTAssertEqual(cartRepo.setQtyCalls[1].qty, 5)
        
        XCTAssertEqual(vm.item(at: IndexPath(row: 0, section: 0)).quantity, 5)
    }
    
    func test_increaseQuantity_uses_current_plus_one() {
        let now = Date()
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p2",
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 2,
                updatedAt: now
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.increaseQuantity(for: "p2")
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cartRepo.setQtyCalls.count, 1)
        XCTAssertEqual(cartRepo.setQtyCalls[0].productId, "p2")
        XCTAssertEqual(cartRepo.setQtyCalls[0].qty, 3)
    }
    
    func test_decreaseQuantity_never_below_one() {
        let now = Date()
        
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p3",
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 1,
                updatedAt: now
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.decreaseQuantity(for: "p3")
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cartRepo.setQtyCalls.count, 1)
        XCTAssertEqual(cartRepo.setQtyCalls[0].productId, "p3")
        XCTAssertEqual(cartRepo.setQtyCalls[0].qty, 1)
        
        let prevCount = cartRepo.setQtyCalls.count
        
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p4",
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 3,
                updatedAt: now
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.decreaseQuantity(for: "p4")
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cartRepo.setQtyCalls.count, prevCount + 1)
        let last = cartRepo.setQtyCalls.last!
        XCTAssertEqual(last.productId, "p4")
        XCTAssertEqual(last.qty, 2)
    }
    
    // MARK: - Remove & Clear
    
    func test_removeItem_calls_repo_and_removes_locally() throws {
        let now = Date()
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 1,
                updatedAt: now
            ),
            .init(
                userId: "u1",
                productId: "p2",
                brandName: "",
                title: "",
                price: 20,
                imageURL: nil,
                quantity: 1,
                updatedAt: now
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        let received = try awaitValue(
            vm.cartItemsPublisher,
            where: { $0.map(\.productId) == ["p2"] },
            after: { self.vm.removeItem(with: "p1") }
        )
        
        XCTAssertEqual(received.map(\.productId), ["p2"])
        XCTAssertEqual(self.vm.cartItems.map(\.productId), ["p2"])
        XCTAssertEqual(self.vm.count, 1)
        
        let deadline = Date().addingTimeInterval(0.3)
        while self.cartRepo.removeCalls.isEmpty && Date() < deadline {
            RunLoop.main.run(until: Date().addingTimeInterval(0.01))
        }
        
        XCTAssertFalse(self.cartRepo.removeCalls.isEmpty, "Ожидали вызов repo.remove(productId:)")
        XCTAssertEqual(self.cartRepo.removeCalls.last, "p1")
    }
    
    func test_clearCart_calls_repo_cancels_notification_and_empties() {
        let now = Date()
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p7",
                brandName: "",
                title: "",
                price: 5,
                imageURL: nil,
                quantity: 2,
                updatedAt: now
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.clearCart()
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cartRepo.clearCalls, 1)
        XCTAssertTrue(vm.cartItems.isEmpty)
        XCTAssertFalse(notifier.lastCancelledIds.isEmpty)
    }
    
    // MARK: - Notifications
    
    func test_scheduleCartReminderForLeavingScreen_schedules_when_has_items() {
        let now = Date()
        cartRepo.itemsSubject.send([
            .init(userId: "u1",
                  productId: "p1",
                  brandName: "",
                  title: "",
                  price: 10,
                  imageURL: nil,
                  quantity: 2,
                  updatedAt: now)
        ])
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        XCTAssertEqual(
            vm.totalItems,
            2,
            "totalItems должен быть > 0 перед планированием"
        )
        
        let prevAfter = notifier.scheduleAfterCount
        let prevAt = notifier.scheduleAtCount
        let prevCancelsCount = notifier.lastCancelledIds.count
        
        vm.scheduleCartReminderForLeavingScreen()
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertTrue(
            notifier.scheduleAfterCount >= prevAfter + 1
            || notifier.scheduleAtCount >= prevAt + 1,
            "Ожидали, что будет запланировано уведомление"
        )
        
        XCTAssertEqual(notifier.lastCancelledIds.count, prevCancelsCount)
    }
    
    func test_scheduleCartReminderForLeavingScreen_cancels_when_empty() {
        cartRepo.itemsSubject.send([])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.scheduleCartReminderForLeavingScreen()
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertFalse(notifier.lastCancelledIds.isEmpty)
    }
    
    func test_auto_cancel_when_cart_becomes_empty_via_stream() {
        let now = Date()
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 1,
                updatedAt: now
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        cartRepo.itemsSubject.send([])
        RunLoop.main.run(until: Date().addingTimeInterval(0.05))
        
        XCTAssertFalse(notifier.lastCancelledIds.isEmpty)
    }
    
    // MARK: - Formatter
    
    func test_formattedPrice_delegates_to_formatter() {
        formatter.stub = { price in "€\(Int(price))" }
        XCTAssertEqual(vm.formattedPrice(1290), "€1290")
    }
}
