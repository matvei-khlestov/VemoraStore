//
//  CatalogViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class CatalogViewModelTests: XCTestCase {
    
    private var repo: CatalogRepositoryMock!
    private var cart: CartRepositoryMock!
    private var favs: FavoritesRepositoryMock!
    private var formatter: PriceFormatterMock!
    private var vm: CatalogViewModel!
    private var bag: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        repo = CatalogRepositoryMock()
        cart = CartRepositoryMock()
        favs = FavoritesRepositoryMock()
        formatter = PriceFormatterMock()
        vm = CatalogViewModel(
            repository: repo,
            cartRepository: cart,
            favoritesRepository: favs,
            priceFormatter: formatter
        )
        bag = []
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
    
    // MARK: - Categories
    
    func test_categories_propagate() throws {
        let expected: [VemoraStore.Category] = [
            .init(
                id: "c1",
                name: "Beds",
                imageURL: "",
                brandIds: [],
                isActive: true,
                createdAt: "",
                updatedAt: ""
            ),
            .init(
                id: "c2",
                name: "Sofas",
                imageURL: "",
                brandIds: [],
                isActive: true,
                createdAt: "",
                updatedAt: ""
            )
        ]
        
        let received = try awaitValue(
            vm.categoriesPublisher,
            where: { !$0.isEmpty },
            after: { self.repo.categoriesSubject.send(expected) }
        )
        
        XCTAssertEqual(received, expected)
        XCTAssertEqual(vm.categories, expected)
    }
    
    // MARK: - Products + counts
    
    func test_products_and_countsByCategory() throws {
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
            ),
            .init(
                id: "p3",
                name: "Sofa",
                description: "",
                nameLower: "sofa",
                categoryId: "c2",
                brandId: "b1",
                price: 3000,
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
        XCTAssertEqual(vm.productCount(in: "c1"), 2)
        XCTAssertEqual(vm.productCount(in: "c2"), 1)
        XCTAssertEqual(vm.productCount(in: "none"), 0)
    }
    
    // MARK: - Filters
    
    func test_applyFilters_updates_activeCount_and_passesParams() throws {
        let state = FilterState(
            selectedCategoryIds: ["c1", "c2"],
            selectedBrandIds: ["b1"],
            minPrice: 100,
            maxPrice: 999
        )
        
        vm.applyFilters(state)
        
        XCTAssertEqual(vm.activeFiltersCount, 5)
        XCTAssertNil(repo.lastQuery)
        XCTAssertEqual(repo.lastCategoryIds, Set(["c1","c2"]))
        XCTAssertEqual(repo.lastBrandIds, Set(["b1"]))
        XCTAssertEqual(repo.lastMinPrice, 100)
        XCTAssertEqual(repo.lastMaxPrice, 999)
        
        let filtered: [VemoraStore.Product] = [
            .init(
                id: "p10",
                name: "Bed X",
                description: "",
                nameLower: "bed x",
                
                categoryId: "c1",
                brandId: "b1",
                price: 120,
                imageURL: "",
                
                isActive: true,
                createdAt: "",
                updatedAt: "",
                keywords: []
            )
        ]
        
        let received = try awaitValue(
            vm.productsPublisher,
            where: { $0 == filtered },
            after: { self.repo.productsSubject.send(filtered) }
        )
        XCTAssertEqual(received, filtered)
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
            after: {
                self.favs.itemsSubject.send(favItems)
            }
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
