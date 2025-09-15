//
//  DeliveryDetailsViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import Combine
import FactoryKit

final class DeliveryDetailsViewModel: DeliveryDetailsViewModelProtocol {
    
    // MARK: - Deps
    
    private let formatter: DeliveryAddressFormattingProtocol
    
    // MARK: - Inputs (state)
    
    let baseAddress: String
    let noFlat = CurrentValueSubject<Bool, Never>(false)
    let apt = CurrentValueSubject<String, Never>("")
    let entrance = CurrentValueSubject<String, Never>("")
    let floor = CurrentValueSubject<String, Never>("")
    let intercom = CurrentValueSubject<String, Never>("")
    
    // MARK: - Init
    
    init(baseAddress: String, container: Container = .shared) {
        self.baseAddress = baseAddress
        self.formatter = container.deliveryAddressFormatter()
    }
    
    // MARK: - Actions
    
    func toggleNoFlat() {
        noFlat.value.toggle()
    }
    
    func validateAptIfNeeded() -> Bool {
        if noFlat.value { return true }
        return !apt.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func buildFinalAddress() -> String {
        var chunks = formatter.formatBaseAddress(baseAddress)
        
        if !noFlat.value {
            if let apt = clean(apt.value) { chunks.append("кв. \(apt)") }
        }
        if let ent = clean(entrance.value) { chunks.append("под. \(ent)") }
        if let code = clean(intercom.value) { chunks.append("дмф. \(code)") }
        if let fl = clean(floor.value) { chunks.append("этаж \(fl)") }
        
        return chunks.joined(separator: ", ")
    }
    
    private func clean(_ text: String) -> String? {
        let t = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return t.isEmpty ? nil : t
    }
}
