//
//  Container+Repositories.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import FactoryKit

extension Container {
    var profileRepository: ParameterFactory<String, ProfileRepository> {
        self { uid in
            DefaultProfileRepository(
                remote: self.profileCollection(),
                local: self.profileLocalStore(),
                userId: uid
            )
        }
    }
    
    var catalogRepository: Factory<CatalogRepository> {
        self {
            DefaultCatalogRepository(
                remote: self.catalogCollection(),
                local: self.catalogLocalStore()
            )
        }.singleton
    }
    
    var cartRepository: ParameterFactory<String, CartRepository> {
        self { uid in
            DefaultCartRepository(
                remote: self.cartCollection(),
                local: self.cartLocalStore(),
                catalog: self.catalogLocalStore(),
                userId: uid
            )
        }
    }
}
