//
//  Container+Factories.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import FactoryKit

extension Container {
    
    // MARK: - Factory
    
    var viewModelFactory: Factory<ViewModelBuildingProtocol> {
        self {
            ViewModelFactory(container: self)
        }.singleton
    }
    
    var coordinatorFactory: Factory<CoordinatorBuildingProtocol> {
        self {
            CoordinatorFactory(container: self) 
        }.singleton
    }
}
