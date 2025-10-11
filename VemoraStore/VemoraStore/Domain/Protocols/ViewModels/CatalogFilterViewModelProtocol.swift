//
//  CatalogFilterViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 07.10.2025.
//

import Foundation
import Combine

protocol CatalogFilterViewModelProtocol {
    // Inputs
    func toggleCategory(id: String)
    func toggleBrand(id: String)
    func setMinPrice(_ text: String?)
    func setMaxPrice(_ text: String?)
    func reset()
    
    // Outputs
    var categories: AnyPublisher<[Category], Never> { get }
    var brands: AnyPublisher<[Brand], Never> { get }
    var statePublisher: AnyPublisher<FilterState, Never> { get }
    var foundCountPublisher: AnyPublisher<Int, Never> { get }
    
    // Snapshot
    var currentState: FilterState { get }
    var currentFoundCount: Int { get }
}
