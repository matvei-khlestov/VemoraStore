//
//  PhoneFormatterStub.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
@testable import VemoraStore

struct PhoneFormatterStub: PhoneFormattingProtocol {
    func digits(from s: String) -> String { s.filter(\.isNumber) }
    func formatRussianPhone(
        _ raw: String
    ) -> (display: String, e164: String) {
        ("+7 (\(raw))", "+7\(raw)")
    }
    func displayFromE164(_ e: String?) -> String? { e }
    func displayForTextField(_ e: String?) -> String { e ?? "+7" }
}
