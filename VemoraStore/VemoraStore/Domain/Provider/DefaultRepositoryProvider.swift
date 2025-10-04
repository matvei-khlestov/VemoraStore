//
//  RepositoryFactory.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation
import FactoryKit

final class RepositoryFactory: RepositoryProvider {
    private let container: Container
    init(container: Container) { self.container = container }

    func profileRepository(for uid: String) -> ProfileRepository {
        DefaultProfileRepository(
            remote: container.profileCollection(),
            local: container.localStore(),
            userId: uid
        )
    }
}
