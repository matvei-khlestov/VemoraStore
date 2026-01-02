//
//  RepositoryFactoryProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation

protocol RepositoryFactoryProtocol {
    func profileRepository(for uid: String) -> ProfileRepository
}
