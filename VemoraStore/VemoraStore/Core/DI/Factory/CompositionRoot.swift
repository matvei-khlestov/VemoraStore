//
//  CompositionRoot.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import FactoryKit

enum CompositionRoot {
    static func makeCoordinatorFactory() -> CoordinatorBuildingProtocol {
        CoordinatorFactory(container: Container.shared)
    }
    
    static func makeAuthService() -> AuthServiceProtocol {
        Container.shared.authService()
    }
}
