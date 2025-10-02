//
//  PhoneFormatter.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

struct PhoneFormatter: PhoneFormattingProtocol {
    func digits(from string: String) -> String {
        string.filter(\.isNumber)
    }
    
    func formatRussianPhone(_ rawDigits: String) -> (display: String, e164: String) {
        var digitsOnly = rawDigits
        if digitsOnly.first != "7" {
            digitsOnly = "7" + digitsOnly.drop(while: { $0 == "7" })
        }
        digitsOnly = String(digitsOnly.prefix(11))
        let e164 = "+" + digitsOnly
        
        let tail = String(digitsOnly.dropFirst())
        let a = String(tail.prefix(3))
        let b = String(tail.dropFirst(3).prefix(3))
        let c = String(tail.dropFirst(6).prefix(2))
        let d = String(tail.dropFirst(8).prefix(2))
        
        var display = "+7"
        if !a.isEmpty { display += " (\(a)" + (a.count == 3 ? ")" : "") }
        if !b.isEmpty { display += a.isEmpty ? " (\(b)" : " \(b)" }
        if !c.isEmpty { display += "-\(c)" }
        if !d.isEmpty { display += "-\(d)" }
        
        return (display, e164)
    }
    
    /// Для отображения телефона в UI (лейблы/ячейки).
    /// Если пусто → возвращаем nil, чтобы показывался плейсхолдер.
    func displayFromE164(_ e164: String?) -> String? {
        guard let e164, !e164.isEmpty else { return nil }
        let digits = digits(from: e164)
        return formatRussianPhone(digits).display
    }
    
    /// Для текстовых полей: даже если пусто, возвращаем "+7"
    func displayForTextField(_ e164: String?) -> String {
        let digits = digits(from: e164 ?? "")
        return formatRussianPhone(digits.isEmpty ? "7" : digits).display
    }
}
