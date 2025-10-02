//
//  PhoneFormattingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

protocol PhoneFormattingProtocol {
    /// Оставляет только цифры
    func digits(from string: String) -> String
    
    /// Форматирует номер в вид +7 (XXX) XXX-XX-XX
    /// Возвращает кортеж: display (для UI) и e164 (+7XXXXXXXXXX)
    func formatRussianPhone(_ rawDigits: String) -> (display: String, e164: String)
    
    /// Для отображения телефона в UI (лейблы/ячейки).
    /// Если пусто → возвращает nil, чтобы показывался плейсхолдер.
    func displayFromE164(_ e164: String?) -> String?
    
    /// Для текстовых полей: даже если пусто, возвращает "+7".
    func displayForTextField(_ e164: String?) -> String
}
