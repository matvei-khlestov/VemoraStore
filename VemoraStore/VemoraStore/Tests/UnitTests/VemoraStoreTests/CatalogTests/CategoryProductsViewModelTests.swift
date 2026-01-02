//
//  CategoryProductsViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class CategoryProductsViewModelTests: XCTestCase {
    
    private var repo: CatalogRepositoryMock!
    private var cart: CartRepositoryMock!
    private var favs: FavoritesRepositoryMock!
    private var formatter: PriceFormatterMock!
    private var vm: CategoryProductsViewModel!
    private var bag: Set<AnyCancellable>!
    
    private let categoryId = "c1"
    
    override func setUp() {
        super.setUp()
        repo = CatalogRepositoryMock()
        cart = CartRepositoryMock()
        favs = FavoritesRepositoryMock()
        formatter = PriceFormatterMock()
        vm = CategoryProductsViewModel(
            repository: repo,
            cartRepository: cart,
            favoritesRepository: favs,
            priceFormatter: formatter,
            categoryId: categoryId
        )
        bag = []
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        formatter = nil
        favs = nil
        cart = nil
        repo = nil
        super.tearDown()
    }
    
    // MARK: - Initial subscription
    
    func test_initial_subscription_sets_category_and_nil_query() {
        XCTAssertNil(repo.lastQuery)
        XCTAssertNil(repo.lastCategoryIds)
    }
    
    // MARK: - Query trimming + debounce + products propagation
    
    func test_query_trimming_debounce_and_products() throws {
        vm.query = "   bed   "
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.30))
        
        XCTAssertEqual(repo.lastQuery, "bed")
        XCTAssertEqual(repo.lastCategoryIds, Set([categoryId]))
        
        let items: [VemoraStore.Product] = [
            .init(
                id: "p1",
                name: "Bed 1",
                description: "",
                nameLower: "bed 1",
                categoryId: "c1",
                brandId: "b1",
                price: 1000,
                imageURL: "",
                isActive: true,
                createdAt: "",
                updatedAt: "",
                keywords: []
            ),
            .init(
                id: "p2",
                name: "Bed 2",
                description: "",
                nameLower: "bed 2",
                categoryId: "c1",
                brandId: "b2",
                price: 2000,
                imageURL: "",
                isActive: true,
                createdAt: "",
                updatedAt: "",
                keywords: []
            )
        ]
        
        let received = try awaitValue(
            vm.productsPublisher,
            where: { !$0.isEmpty },
            after: { self.repo.productsSubject.send(items) }
        )
        XCTAssertEqual(received, items)
        XCTAssertEqual(vm.products, items)
    }
    
    func test_empty_query_sends_nil_and_category_filter_only() {
        vm.query = ""
        RunLoop.main.run(until: Date().addingTimeInterval(0.30))
        
        XCTAssertNil(repo.lastQuery)
        XCTAssertEqual(repo.lastCategoryIds, Set([categoryId]))
    }
    
    // MARK: - Cart / Favorites publishers
    
    func test_inCart_and_favorite_ids_publishers() throws {
        let cartItems: [CartItem] = [
            .init(
                userId: "u1",
                productId: "p1",
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 1,
                updatedAt: Date()
            ),
            .init(
                userId: "u1",
                productId: "p3",
                brandName: "",
                title: "",
                price: 20,
                imageURL: nil,
                quantity: 2,
                updatedAt: Date()
            )
        ]
        
        let inCart = try awaitValue(
            vm.inCartIdsPublisher,
            where: { !$0.isEmpty },
            after: { self.cart.itemsSubject.send(cartItems) }
        )
        XCTAssertEqual(inCart, Set(["p1", "p3"]))
        
        let favItems: [FavoriteItem] = [
            .init(
                userId: "u1",
                productId: "p2",
                brandName: "",
                title: "",
                price: 0,
                imageURL: nil,
                updatedAt: Date()
            )
        ]
        
        let favSet = try awaitValue(
            vm.favoriteIdsPublisher,
            where: { !$0.isEmpty },
            after: { self.favs.itemsSubject.send(favItems) }
        )
        XCTAssertEqual(favSet, Set(["p2"]))
    }
    
    // MARK: - reload / realtime
    
    func test_reload_calls_refreshAll_and_starts_realtime_once() {
        vm.reload()
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        vm.reload()
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(repo.refreshAllCalls, 2)
        XCTAssertEqual(repo.startRealtimeCalls, 1)
    }
    
    // MARK: - Commands
    
    func test_cart_commands() {
        vm.addToCart(productId: "p1")
        vm.removeFromCart(productId: "p2")
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cart.addCalls.map(\.productId), ["p1"])
        XCTAssertEqual(cart.removeCalls, ["p2"])
    }
    
    func test_favorites_commands() {
        vm.addToFavorites(productId: "p1")
        vm.removeFromFavorites(productId: "p2")
        vm.toggleFavorite(productId: "p3")
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(favs.addCalls, ["p1"])
        XCTAssertEqual(favs.removeCalls, ["p2"])
        XCTAssertEqual(favs.toggleCalls, ["p3"])
    }
    
    // MARK: - Formatter
    
    func test_formattedPrice_delegates_to_formatter() {
        formatter.stub = { price in "€\(Int(price))" }
        XCTAssertEqual(vm.formattedPrice(1290), "€1290")
    }
}
