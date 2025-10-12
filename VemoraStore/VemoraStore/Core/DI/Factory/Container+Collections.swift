//
//  Container+Collections.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation
import FactoryKit

extension Container {
    
    // MARK: - Profile Remote (Firestore)
    
    var profileCollection: Factory<ProfileCollectingProtocol> {
        self { ProfileCollection() }.singleton
    }
    
    var catalogCollection: Factory<CatalogCollectingProtocol> {
        self { CatalogCollections() }.singleton
    }
    
    var cartCollection: Factory<CartCollectingProtocol> {
        self { CartCollection() }.singleton
    }
}
