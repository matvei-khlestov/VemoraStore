//
//  String+ext.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

extension String {
    /// Форматирует e164 (+7XXXXXXXXXX) в вид "+7 (XXX) XXX-XX-XX"
    func e164ToRuDisplay() -> String {
        // оставить только цифры
        var digits = self.filter(\.isNumber)

        // нормализуем: принудительно на 7 и ограничим 11 цифрами
        if digits.first != "7" { digits = "7" + digits.drop(while: { $0 == "7" }) }
        digits = String(digits.prefix(11))

        // если пусто — вернём "+7"
        guard !digits.isEmpty else { return "+7" }

        let tail = String(digits.dropFirst())
        let a = String(tail.prefix(3))
        let b = String(tail.dropFirst(3).prefix(3))
        let c = String(tail.dropFirst(6).prefix(2))
        let d = String(tail.dropFirst(8).prefix(2))

        var display = "+7"
        if !a.isEmpty { display += " (\(a)" + (a.count == 3 ? ")" : "") }
        if !b.isEmpty { display += a.isEmpty ? " (\(b)" : " \(b)" }
        if !c.isEmpty { display += "-\(c)" }
        if !d.isEmpty { display += "-\(d)" }

        return display
    }
}
