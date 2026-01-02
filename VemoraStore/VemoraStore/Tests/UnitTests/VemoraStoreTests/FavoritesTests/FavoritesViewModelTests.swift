//
//  FavoritesViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
import UserNotifications
@testable import VemoraStore

final class FavoritesViewModelTests: XCTestCase {
    
    private var favsRepo: FavoritesRepositoryMock!
    private var cartRepo: CartRepositoryMock!
    private var formatter: PriceFormatterMock!
    private var notifier: NotifierMock!
    private var vm: FavoritesViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        favsRepo = FavoritesRepositoryMock()
        cartRepo = CartRepositoryMock()
        formatter = PriceFormatterMock()
        notifier = NotifierMock()
        vm = FavoritesViewModel(
            favoritesRepository: favsRepo,
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
        favsRepo = nil
        super.tearDown()
    }
    
    // MARK: - Publishers
    
    func test_favoriteItems_propagate() throws {
        let items: [FavoriteItem] = [
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "b",
                title: "t1",
                price: 10,
                imageURL: nil,
                updatedAt: Date()
            ),
            .init(
                userId: "u1",
                productId: "p2",
                brandName: "b",
                title: "t2",
                price: 20,
                imageURL: nil,
                updatedAt: Date()
            )
        ]
        
        let received = try awaitValue(
            vm.favoriteItemsPublisher,
            where: { !$0.isEmpty },
            after: { self.favsRepo.itemsSubject.send(items) }
        )
        XCTAssertEqual(received, items)
        XCTAssertEqual(vm.count, 2)
        XCTAssertEqual(vm.item(at: IndexPath(row: 0, section: 0)).productId, "p1")
    }
    
    func test_inCartIds_propagate() throws {
        let cartItems: [CartItem] = [
            .init(
                userId: "u1",
                productId: "p3",
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 1,
                updatedAt: Date()
            ),
            
                .init(
                    userId: "u1",
                    productId: "p1",
                    brandName: "",
                    title: "",
                    price: 10,
                    imageURL: nil,
                    quantity: 2,
                    updatedAt: Date()
                    
                )
        ]
        
        let set = try awaitValue(
            vm.inCartIdsPublisher,
            where: { !$0.isEmpty },
            after: { self.cartRepo.itemsSubject.send(cartItems) }
        )
        XCTAssertEqual(set, Set(["p1", "p3"]))
        XCTAssertTrue(vm.isInCart("p1"))
        XCTAssertFalse(vm.isInCart("p2"))
    }
    
    // MARK: - Commands: Cart
    
    func test_toggleCart_adds_when_not_in_cart() {
        vm.toggleCart(for: "p9")
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cartRepo.addCalls.count, 1)
        XCTAssertEqual(cartRepo.addCalls[0].productId, "p9")
        XCTAssertEqual(cartRepo.addCalls[0].by, 1)
        XCTAssertTrue(cartRepo.removeCalls.isEmpty)
    }
    
    func test_toggleCart_removes_when_in_cart() {
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p7",
                brandName: "",
                title: "",
                price: 1,
                imageURL: nil,
                quantity: 1,
                updatedAt: Date()
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.toggleCart(for: "p7")
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertTrue(cartRepo.addCalls.isEmpty)
        XCTAssertEqual(cartRepo.removeCalls, ["p7"])
    }
    
    // MARK: - Commands: Favorites mutate locally
    
    func test_removeItem_removes_locally_and_calls_toggle() throws {
        let now = Date()
        favsRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "",
                title: "A",
                price: 10,
                imageURL: nil,
                updatedAt: now
            ),
            .init(
                userId: "u1",
                productId: "p2",
                brandName: "",
                title: "B",
                price: 20,
                imageURL: nil,
                updatedAt: now
            )
        ])
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "",
                title: "",
                price: 1,
                imageURL: nil,
                quantity: 1,
                updatedAt: now
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.removeItem(with: "p1")
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(favsRepo.toggleCalls, ["p1"])
        XCTAssertEqual(vm.count, 1)
        XCTAssertFalse(vm.isInCart("p1"))
        
        let received = try awaitValue(
            vm.favoriteItemsPublisher,
            where: { $0.allSatisfy { $0.productId != "p1" } }
        )
        XCTAssertEqual(received.map(\.productId), ["p2"])
    }
    
    func test_clearFavorites_calls_repo_and_clears_local() throws {
        favsRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "",
                title: "A",
                price: 10,
                imageURL: nil,
                updatedAt: Date()
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.clearFavorites()
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(favsRepo.clearCalls, 1)
        
        let received = try awaitValue(
            vm.favoriteItemsPublisher,
            where: { $0.isEmpty }
        )
        XCTAssertTrue(received.isEmpty)
        XCTAssertEqual(vm.count, 0)
    }
    
    // MARK: - Formatter
    
    func test_formattedPrice_delegates_to_formatter() {
        formatter.stub = {
            price in "€\(Int(price))"
        }
        XCTAssertEqual(vm.formattedPrice(1290), "€1290")
    }
    
    // MARK: - Local Notifications behavior
    
    func test_notifications_schedule_when_has_favorites_and_none_in_cart() {
        favsRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "",
                title: "A",
                price: 1,
                imageURL: nil,
                updatedAt: Date()
            )
        ])
        cartRepo.itemsSubject.send([])
        RunLoop.main.run(until: Date().addingTimeInterval(0.25))
        
        XCTAssertTrue(notifier.scheduleAfterCount == 1 || notifier.scheduleAtCount == 1)
        XCTAssertTrue(notifier.lastCancelledIds.isEmpty)
    }
    
    func test_notifications_cancel_when_any_favorite_in_cart() {
        favsRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p2",
                brandName: "",
                title: "B",
                price: 2,
                imageURL: nil,
                updatedAt: Date()
            )
        ])
        cartRepo.itemsSubject.send([
            .init(
                userId: "u1",
                productId: "p2",
                brandName: "",
                title: "",
                price: 2,
                imageURL: nil,
                quantity: 1,
                updatedAt: Date()
            )
        ])
        RunLoop.main.run(until: Date().addingTimeInterval(0.25))
        
        XCTAssertFalse(notifier.lastCancelledIds.isEmpty)
    }
    
    func test_notifications_cancel_when_no_favorites() {
        favsRepo.itemsSubject.send([])
        cartRepo.itemsSubject.send([])
        RunLoop.main.run(until: Date().addingTimeInterval(0.25))
        
        XCTAssertFalse(notifier.lastCancelledIds.isEmpty)
    }
}
