//
//  DeliveryDetailsViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import Combine

/// Контракт `DeliveryDetailsViewModelProtocol`
///
/// Определяет публичный интерфейс ViewModel
/// для экрана деталей доставки.
///
/// Основные задачи:
/// - хранение и управление полями адреса (квартира, подъезд, этаж, домофон);
/// - обработка состояния «Без квартиры»;
/// - валидация данных и построение итоговой строки адреса.
///
/// Используется в:
/// - `DeliveryDetailsSheetViewController`
///   для связывания полей ввода с ViewModel и сохранения данных.

protocol DeliveryDetailsViewModelProtocol: AnyObject {
    
    /// Базовый адрес, полученный из поиска.
    var baseAddress: String { get }
    
    /// Флаг «Без квартиры».
    var noFlat: CurrentValueSubject<Bool, Never> { get }
    
    /// Значение квартиры.
    var apt: CurrentValueSubject<String, Never> { get }
    
    /// Значение подъезда.
    var entrance: CurrentValueSubject<String, Never> { get }
    
    /// Значение этажа.
    var floor: CurrentValueSubject<String, Never> { get }
    
    /// Значение домофона.
    var intercom: CurrentValueSubject<String, Never> { get }
    
    /// Переключает флаг «Без квартиры».
    func toggleNoFlat()
    
    /// Проверяет необходимость и корректность заполнения квартиры.
    func validateAptIfNeeded() -> Bool
    
    /// Формирует итоговую строку адреса на основе введённых данных.
    func buildFinalAddress() -> String
}
