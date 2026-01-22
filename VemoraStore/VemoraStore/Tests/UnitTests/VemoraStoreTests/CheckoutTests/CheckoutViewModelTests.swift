//
//  CheckoutViewModelTests.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import XCTest
import Combine
@testable import VemoraStore

final class CheckoutViewModelTests: XCTestCase {
    
    private var cart: CartRepositoryMock!
    private var orders: OrdersRepositorySpy_Checkout!
    private var phone: PhoneFormattingProtocol!
    private var price: PriceFormatterMock!
    private var storage: CheckoutStorageMock!
    private var notifier: NotifierMock!
    private var analyticsSpy: AnalyticsServiceSpy!
    
    private var vm: CheckoutViewModel!
    private var bag: Set<AnyCancellable>!
    private let uid = "uid-1"
    
    override func setUp() {
        super.setUp()
        cart = CartRepositoryMock()
        orders = OrdersRepositorySpy_Checkout()
        phone = PhoneFormatterStub()
        price = PriceFormatterMock()
        storage = CheckoutStorageMock()
        notifier = NotifierMock()
        analyticsSpy = AnalyticsServiceSpy()
        
        vm = CheckoutViewModel(
            cartRepository: cart,
            ordersRepository: orders,
            phoneFormatter: phone,
            priceFormatter: price,
            snapshotItems: [],
            storage: storage,
            currentUserId: uid,
            notifier: notifier,
            analytics: analyticsSpy
        )
        bag = []
    }
    
    override func tearDown() {
        bag = nil
        vm = nil
        analyticsSpy = nil
        notifier = nil
        storage = nil
        price = nil
        phone = nil
        orders = nil
        cart = nil
        super.tearDown()
    }
    
    private func item(_ id: String, _ qty: Int, price: Double = 10) -> CartItem {
        .init(
            userId: "u1",
            productId: id,
            brandName: "b",
            title: "t",
            price: price,
            imageURL: nil,
            quantity: qty,
            updatedAt: Date()
        )
    }
    
    func test_initial_state_from_storage() {
        storage.savedDeliveryMethod = .delivery
        storage.savedDeliveryAddressString = "A"
        storage.savedReceiverPhoneE164 = "+7000"
        
        vm = CheckoutViewModel(
            cartRepository: cart,
            ordersRepository: orders,
            phoneFormatter: phone,
            priceFormatter: price,
            snapshotItems: [],
            storage: storage,
            currentUserId: uid,
            notifier: notifier,
            analytics: analyticsSpy
        )
        
        XCTAssertEqual(vm.deliveryMethod, .delivery)
        XCTAssertEqual(vm.deliveryAddressString, "A")
        XCTAssertEqual(vm.receiverPhoneE164, "+7000")
    }
    
    func test_items_publisher_propagates_from_cart_repo() throws {
        let sent = [item("p1", 1), item("p2", 2)]
        let got = try awaitValue(
            vm.itemsPublisher,
            where: { !$0.isEmpty },
            after: { self.cart.itemsSubject.send(sent) }
        )
        XCTAssertEqual(got.map(\.productId), ["p1", "p2"])
        XCTAssertEqual(vm.itemsSnapshot.count, 2)
    }
    
    func test_isPlaceOrderEnabled_pickup_requires_only_items() throws {
        vm.setDeliveryMethod(.pickup)
        let v1 = try awaitValue(vm.isPlaceOrderEnabled.first())
        XCTAssertFalse(v1)
        let v2 = try awaitValue(
            vm.isPlaceOrderEnabled,
            where: { $0 == true },
            after: { self.cart.itemsSubject.send([self.item("p", 1)]) }
        )
        XCTAssertTrue(v2)
    }
    
    func test_isPlaceOrderEnabled_delivery_requires_items_address_phone() throws {
        vm.setDeliveryMethod(.delivery)
        let noItems = try awaitValue(vm.isPlaceOrderEnabled.first())
        XCTAssertFalse(noItems)
        cart.itemsSubject.send([item("p", 1)])
        let noAddr = try awaitValue(vm.isPlaceOrderEnabled.first())
        XCTAssertFalse(noAddr)
        vm.updateDeliveryAddress("City")
        let noPhone = try awaitValue(vm.isPlaceOrderEnabled.first())
        XCTAssertFalse(noPhone)
        let ok = try awaitValue(
            vm.isPlaceOrderEnabled,
            where: { $0 == true },
            after: { self.vm.updateReceiverPhone("+7999") }
        )
        XCTAssertTrue(ok)
    }
    
    func test_updateDeliveryAddress_switches_to_delivery_and_saves() {
        XCTAssertEqual(vm.deliveryMethod, .pickup)
        vm.updateDeliveryAddress("Addr")
        XCTAssertEqual(vm.deliveryMethod, .delivery)
        XCTAssertEqual(vm.deliveryAddressString, "Addr")
        XCTAssertEqual(storage.savedDeliveryAddressString, "Addr")
    }
    
    func test_updateReceiverPhone_sets_e164_and_display_and_saves() throws {
        let got = try awaitValue(
            vm.receiverPhoneDisplayPublisher,
            where: { $0 == "+7999" },
            after: { self.vm.updateReceiverPhone("+7999") }
        )
        XCTAssertEqual(got, "+7999")
        XCTAssertEqual(vm.receiverPhoneE164, "+7999")
        XCTAssertEqual(storage.savedReceiverPhoneE164, "+7999")
    }
    
    func test_updateOrderComment_sets_nil_when_empty() {
        vm.updateOrderComment("")
        XCTAssertNil(vm.orderCommentText)
        vm.updateOrderComment("Hi")
        XCTAssertEqual(vm.orderCommentText, "Hi")
    }
    
    func test_formatted_total_and_price_delegate() {
        price.stub = { "€\(Int($0))" }
        let items = [item("p1", 2, price: 10), item("p2", 1, price: 5)]
        XCTAssertEqual(vm.formattedTotalPrice(from: items), "€25")
        XCTAssertEqual(vm.formattedPrice(7), "€7")
    }
    
    func test_clearCart_calls_repo_clear() async {
        await vm.clearCart()
        XCTAssertEqual(cart.clearCalls, 1)
    }
    
    func test_placeOrder_success_pickup_creates_order_and_schedules() async throws {
        cart.itemsSubject.send([item("p1", 1)])
        _ = try awaitValue(vm.itemsPublisher, where: { !$0.isEmpty })
        vm.updateDeliveryAddress("")
        vm.setDeliveryMethod(.pickup)
        try await vm.placeOrder()
        XCTAssertEqual(orders.createCalls, 1)
        XCTAssertEqual(orders.parsed?.userId, uid)
        XCTAssertEqual(orders.parsed?.itemIds, ["p1"])
        XCTAssertEqual(orders.parsed?.isPickup, true)
        XCTAssertTrue(notifier.scheduleAfterCount >= 1)
        XCTAssertNotNil(notifier.lastScheduledId)
    }
    
    func test_placeOrder_success_delivery_creates_order_and_schedules() async throws {
        cart.itemsSubject.send([item("p2", 2)])

        _ = try awaitValue(vm.itemsPublisher, where: { !$0.isEmpty })

        vm.setDeliveryMethod(.delivery)

        // Дождались, что адрес реально применился
        let address = "City, St 2"
        vm.updateDeliveryAddress(address)
        XCTAssertEqual(vm.deliveryAddressString, address)

        // Дождались, что телефон реально применился (через publisher)
        let phone = "+79990002233"
        _ = try awaitValue(
            vm.receiverPhoneDisplayPublisher,
            where: { $0 == phone },
            after: { self.vm.updateReceiverPhone(phone) }
        )
        XCTAssertEqual(vm.receiverPhoneE164, phone)

        // Барьер: кнопка точно стала активной после всех апдейтов
        _ = try awaitValue(vm.isPlaceOrderEnabled, where: { $0 == true })

        try await vm.placeOrder()

        XCTAssertEqual(orders.createCalls, 1)
        XCTAssertEqual(orders.parsed?.userId, uid)
        XCTAssertEqual(orders.parsed?.itemIds, ["p2"])
        XCTAssertEqual(orders.parsed?.isPickup, false)
        XCTAssertEqual(orders.parsed?.address, address)
        XCTAssertEqual(orders.parsed?.phone, phone)
        XCTAssertTrue(notifier.scheduleAfterCount >= 1)
        XCTAssertNotNil(notifier.lastScheduledId)
    }
    
    func test_placeOrder_validates_empty_cart() async {
        do { try await vm.placeOrder(); XCTFail("expected error") }
        catch {}
    }
    
    func test_placeOrder_validates_delivery_required_fields() async {
        cart.itemsSubject.send([item("p", 1)])
        vm.setDeliveryMethod(.delivery)
        vm.updateDeliveryAddress("")
        vm.updateReceiverPhone(nil)
        do { try await vm.placeOrder(); XCTFail("expected error") }
        catch {}
    }
}
