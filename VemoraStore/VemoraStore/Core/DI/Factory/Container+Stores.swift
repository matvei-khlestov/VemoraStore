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
        self { CoreDataStack.shared.container }.singleton
    }

    var localStore: Factory<LocalStore> {
        self {
            CoreDataLocalStore(container: self.persistentContainer())
        }.singleton
    }
}
