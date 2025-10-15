//
//  Container+Stores.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import FactoryKit
import CoreData

extension Container {
    
    var persistentContainer: Factory<NSPersistentContainer> {
        self {
            CoreDataStack.shared.container
        }.singleton
    }
    
    var profileLocalStore: Factory<ProfileLocalStore> {
        self {
            CoreDataProfileStore(container: self.persistentContainer())
        }.singleton
    }
    
    var catalogLocalStore: Factory<CatalogLocalStore> {
        self {
            CoreDataCatalogStore(container: self.persistentContainer())
        }.singleton
    }
    
    var cartLocalStore: Factory<CartLocalStore> {
        self {
            CoreDataCartStore(container: self.persistentContainer())
        }.singleton
    }
    
    var favoritesLocalStore: Factory<FavoritesLocalStore> {
        self {
            CoreDataFavoritesStore(container: self.persistentContainer())
        }.singleton
    }
    
    var ordersLocalStore: Factory<OrdersLocalStore> {
        self {
            CoreDataOrdersStore(container: self.persistentContainer())
        }.singleton
    }
}
