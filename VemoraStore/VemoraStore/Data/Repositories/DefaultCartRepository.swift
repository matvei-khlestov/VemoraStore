//
//  DefaultCartRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Foundation
import Combine

final class DefaultCartRepository: CartRepository {

    // MARK: - Deps

    private let remote: CartCollectingProtocol
    private let local: CartLocalStore
    private let catalog: CatalogLocalStore
    private let userId: String

    // MARK: - State

    private var bag = Set<AnyCancellable>()
    private let itemsSubject = CurrentValueSubject<[CartItem], Never>([])

    // MARK: - Init

    init(remote: CartCollectingProtocol,
         local: CartLocalStore,
         catalog: CatalogLocalStore,
         userId: String) {
        self.remote = remote
        self.local = local
        self.catalog = catalog
        self.userId = userId

        bindStreams()
    }

    // MARK: - Streams

    func observeItems() -> AnyPublisher<[CartItem], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    func observeTotals() -> AnyPublisher<(count: Int, price: Double), Never> {
        observeItems()
            .map { items in
                let count = items.reduce(0) { $0 + $1.quantity }
                let price = items.reduce(0.0) { $0 + $1.lineTotal }
                return (count, price)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Commands

    func refresh(uid: String) async throws {
        let dtos = try await remote.fetchCart(uid: uid)
        local.replaceAll(userId: userId, with: dtos)
    }

    func add(productId: String, by delta: Int) async throws {
        guard delta != 0 else { return }
        guard let meta = catalog.meta(for: productId) else { return }
        let dto = CartDTO(
            userId: userId,
            productId: productId,
            brandName: meta.brandName,
            title: meta.title,
            price: meta.price,
            imageURL: meta.imageURL?.absoluteString,
            quantity: max(1, delta),
            updatedAt: Date()
        )
        try await remote.addOrAccumulate(uid: userId, dto: dto, by: delta)
    }

    func setQuantity(productId: String, quantity: Int) async throws {
        guard let meta = catalog.meta(for: productId) else {
            // Если нет метаданных, всё равно сможем обнулить/удалить
            let dto = CartDTO(
                userId: userId,
                productId: productId,
                brandName: "",
                title: "",
                price: .zero,
                imageURL: nil,
                quantity: quantity,
                updatedAt: Date()
            )
            try await remote.setQuantity(uid: userId, dto: dto, quantity: quantity)
            return
        }
        let dto = CartDTO(
            userId: userId,
            productId: productId,
            brandName: meta.brandName,
            title: meta.title,
            price: meta.price,
            imageURL: meta.imageURL?.absoluteString,
            quantity: quantity,
            updatedAt: Date()
        )
        try await remote.setQuantity(uid: userId, dto: dto, quantity: quantity)
    }

    func remove(productId: String) async throws {
        try await remote.remove(uid: userId, productId: productId)
    }

    func clear() async throws {
        try await remote.clear(uid: userId)
    }
}

// MARK: - Private

private extension DefaultCartRepository {
    func bindStreams() {
        // Локальная корзина -> внешний паблишер
        local.observeItems(userId: userId)
            .subscribe(itemsSubject)
            .store(in: &bag)

        // Ремоут → локаль (весь снэпшот)
        remote.listenCart(uid: userId)
            .sink { [weak self] dtos in
                guard let self else { return }
                self.local.replaceAll(userId: self.userId, with: dtos)
            }
            .store(in: &bag)
    }
}
