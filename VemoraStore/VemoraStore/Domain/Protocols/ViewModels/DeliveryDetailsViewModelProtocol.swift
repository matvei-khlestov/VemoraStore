//
//  DeliveryDetailsViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 15.09.2025.
//

import Foundation
import Combine

protocol DeliveryDetailsViewModelProtocol: AnyObject {
    // Inputs (state)
    var baseAddress: String { get }
    var noFlat: CurrentValueSubject<Bool, Never> { get }
    var apt: CurrentValueSubject<String, Never> { get }
    var entrance: CurrentValueSubject<String, Never> { get }
    var floor: CurrentValueSubject<String, Never> { get }
    var intercom: CurrentValueSubject<String, Never> { get }
    
    // Actions
    func toggleNoFlat()
    func validateAptIfNeeded() -> Bool
    func buildFinalAddress() -> String
}
