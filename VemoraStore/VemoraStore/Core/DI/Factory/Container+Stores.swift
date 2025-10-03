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
        self { AppPersistent.shared }.singleton
    }

    var localStore: Factory<LocalStore> {
        self {
            LocalStoreCoreData(container: self.persistentContainer())
        }.singleton
    }
}
