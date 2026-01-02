//
//  CartCollectingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 11.10.2025.
//

import Foundation
import Combine

/// Протокол `CartCollectingProtocol`
///
/// Определяет интерфейс взаимодействия с удалённой коллекцией **корзины товаров** пользователя.
///
/// Основные задачи:
/// - загрузка содержимого корзины (`fetchCart`);
/// - изменение количества товаров (`setQuantity`, `addOrAccumulate`);
/// - удаление отдельных позиций (`remove`) и полной очистки (`clear`);
/// - реактивное получение обновлений корзины (`listenCart`).
///
/// Используется в:
/// - `CartRepository` для синхронизации корзины между сервером и локальным хранилищем;
/// - `CartViewModel` и `CheckoutViewModel` для реактивного отображения содержимого корзины.

protocol CartCollectingProtocol: AnyObject {
    
    /// Загружает текущее содержимое корзины пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Список товаров в корзине в формате `CartDTO`.
    func fetchCart(uid: String) async throws -> [CartDTO]
    
    /// Устанавливает новое количество товара в корзине.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - dto: DTO товара.
    ///   - quantity: Новое количество.
    func setQuantity(uid: String, dto: CartDTO, quantity: Int) async throws
    
    /// Добавляет товар или увеличивает его количество в корзине.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - dto: DTO добавляемого товара.
    ///   - delta: Изменение количества (может быть отрицательным).
    func addOrAccumulate(uid: String, dto: CartDTO, by delta: Int) async throws
    
    /// Удаляет товар из корзины по его идентификатору.
    /// - Parameters:
    ///   - uid: Идентификатор пользователя.
    ///   - productId: Идентификатор удаляемого товара.
    func remove(uid: String, productId: String) async throws
    
    /// Полностью очищает корзину пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    func clear(uid: String) async throws
    
    /// Реактивно слушает изменения содержимого корзины пользователя.
    /// - Parameter uid: Идентификатор пользователя.
    /// - Returns: Паблишер, эмитирующий актуальный список `CartDTO`.
    func listenCart(uid: String) -> AnyPublisher<[CartDTO], Never>
}
