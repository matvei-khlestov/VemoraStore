//
//  ProductDetailsViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class ProductDetailsViewModelTests: XCTestCase {
    
    private var repo: CatalogRepositoryMock!
    private var cart: CartRepositoryMock!
    private var favs: FavoritesRepositoryMock!
    private var formatter: PriceFormatterMock!
    private var vm: ProductDetailsViewModel!
    private var bag: Set<AnyCancellable>!
    
    private let productId = "p1"
    
    override func setUp() {
        super.setUp()
        repo = CatalogRepositoryMock()
        cart = CartRepositoryMock()
        favs = FavoritesRepositoryMock()
        formatter = PriceFormatterMock()
        vm = ProductDetailsViewModel(
            productId: productId,
            favoritesRepository: favs,
            cartRepository: cart,
            catalogRepository: repo,
            priceFormatter: formatter
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
    
    // MARK: - Initial state
    
    func test_initial_outputs_defaults() {
        XCTAssertEqual(vm.title, "Загрузка...")
        XCTAssertEqual(vm.description, "")
        XCTAssertEqual(vm.priceText, "")
        XCTAssertNil(vm.imageURL)
        XCTAssertFalse(vm.isFavorite)
        XCTAssertFalse(vm.currentIsInCart)
    }
    
    // MARK: - Product propagation
    
    func test_product_publisher_updates_outputs() throws {
        let product = VemoraStore.Product(
            id: productId,
            name: "Premium Sofa",
            description: "Soft and comfy",
            nameLower: "premium sofa",
            categoryId: "c2",
            brandId: "b1",
            price: 2599,
            imageURL: "https://example.com/sofa.jpg",
            isActive: true,
            createdAt: "",
            updatedAt: "",
            keywords: []
        )
        
        formatter.stub = { price in "€\(Int(price))" }
        
        let received = try awaitValue(
            vm.productPublisher,
            where: { $0?.id == self.productId },
            after: { self.repo.productsSubject.send([product]) }
        )
        
        XCTAssertEqual(received, product)
        XCTAssertEqual(vm.title, "Premium Sofa")
        XCTAssertEqual(vm.description, "Soft and comfy")
        XCTAssertEqual(vm.priceText, "€2599")
        XCTAssertEqual(vm.imageURL, "https://example.com/sofa.jpg")
    }
    
    // MARK: - Cart state
    
    func test_isInCart_publisher_and_currentIsInCart() throws {
        // изначально нет в корзине
        XCTAssertFalse(vm.currentIsInCart)
        
        let cartItems: [CartItem] = [
            .init(
                userId: "u1",
                productId: productId,
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 2,
                updatedAt: Date()
            )
        ]
        
        let inCart = try awaitValue(
            vm.isInCartPublisher,
            where: { $0 == true },
            after: { self.cart.itemsSubject.send(cartItems) }
        )
        XCTAssertTrue(inCart)
        XCTAssertTrue(vm.currentIsInCart)
        
        let emptied: [CartItem] = [
            .init(
                userId: "u1",
                productId: productId,
                brandName: "",
                title: "",
                price: 10,
                imageURL: nil,
                quantity: 0,
                updatedAt: Date()
            )
        ]
        let notInCart = try awaitValue(
            vm.isInCartPublisher,
            where: { $0 == false },
            after: { self.cart.itemsSubject.send(emptied) }
        )
        XCTAssertFalse(notInCart)
        XCTAssertFalse(vm.currentIsInCart)
    }
    
    // MARK: - Favorite state
    
    func test_isFavorite_publisher_and_flag() throws {
        XCTAssertFalse(vm.isFavorite)
        
        let favItems: [FavoriteItem] = [
            .init(
                userId: "u1",
                productId: productId,
                brandName: "",
                title: "",
                price: 0,
                imageURL: nil,
                updatedAt: Date()
            )
        ]
        let isFav = try awaitValue(
            vm.isFavoritePublisher,
            where: { $0 == true },
            after: { self.favs.itemsSubject.send(favItems) }
        )
        XCTAssertTrue(isFav)
        XCTAssertTrue(vm.isFavorite)
        
        let emptyFavs: [FavoriteItem] = []
        let notFav = try awaitValue(
            vm.isFavoritePublisher,
            where: { $0 == false },
            after: { self.favs.itemsSubject.send(emptyFavs) }
        )
        XCTAssertFalse(notFav)
        XCTAssertFalse(vm.isFavorite)
    }
    
    // MARK: - Favorites commands
    
    func test_favorites_commands_delegate() {
        vm.toggleFavorite()
        vm.addToFavorites()
        vm.removeFromFavorites()
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(favs.toggleCalls, [productId])
        XCTAssertEqual(favs.addCalls, [productId])
        XCTAssertEqual(favs.removeCalls, [productId])
    }
    
    // MARK: - Cart commands
    
    func test_cart_commands_delegate() {
        vm.addToCart()
        vm.removeFromCart()
        vm.updateQuantity(5)
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cart.addCalls.count, 1)
        XCTAssertEqual(cart.addCalls[0].productId, productId)
        XCTAssertEqual(cart.addCalls[0].by, 1)
        
        XCTAssertEqual(cart.removeCalls, [productId])
        
        XCTAssertEqual(cart.setQtyCalls.count, 1)
        XCTAssertEqual(cart.setQtyCalls[0].productId, productId)
        XCTAssertEqual(cart.setQtyCalls[0].qty, 5)
    }
    
    func test_addToCart_with_quantity_guard() {
        vm.addToCart(quantity: 0)
        vm.addToCart(quantity: -3)
        vm.addToCart(quantity: 2)
        
        RunLoop.main.run(until: Date().addingTimeInterval(0.02))
        
        XCTAssertEqual(cart.addCalls.count, 1)
        XCTAssertEqual(cart.addCalls[0].productId, productId)
        XCTAssertEqual(cart.addCalls[0].by, 2)
    }
    
    // MARK: - PriceText formatting
    
    func test_priceText_uses_formatter() throws {
        formatter.stub = { price in "₽\(Int(price))" }
        let p = VemoraStore.Product(
            id: productId,
            name: "Chair",
            description: "Wooden",
            nameLower: "chair",
            categoryId: "c1",
            brandId: "b1",
            price: 1499,
            imageURL: "",
            isActive: true,
            createdAt: "",
            updatedAt: "",
            keywords: []
        )
        
        _ = try awaitValue(
            vm.productPublisher,
            where: { $0?.id == self.productId },
            after: { self.repo.productsSubject.send([p]) }
        )
        XCTAssertEqual(vm.priceText, "₽1499")
    }
}
