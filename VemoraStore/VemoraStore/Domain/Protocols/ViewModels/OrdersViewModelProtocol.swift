//
//  OrdersViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 18.09.2025.
//

import Foundation
import Combine

/// Протокол `OrdersViewModelProtocol` определяет интерфейс ViewModel
/// для экрана со списком заказов, предоставляя реактивные данные и методы
/// для управления отображением заказов в таблице.

protocol OrdersViewModelProtocol: AnyObject {
    /// Паблишер, отправляющий обновления массива заказов.
    var ordersPublisher: AnyPublisher<[OrderEntity], Never> { get }
    
    /// Количество секций (заказов) в таблице.
    var sectionsCount: Int { get }
    
    /// Возвращает количество строк (товаров) в указанной секции.
    func rows(in section: Int) -> Int
    
    /// Возвращает заказ по индексу секции.
    func order(at section: Int) -> OrderEntity?
    
    /// Возвращает элемент заказа (OrderItem) по индексу ячейки.
    func item(at indexPath: IndexPath) -> OrderItem?
    
    /// Форматирует цену для отображения в UI.
    func formattedPrice(_ price: Double) -> String
}
