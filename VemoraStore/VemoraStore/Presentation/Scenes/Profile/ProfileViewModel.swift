//
//  ProfileViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import FactoryKit

final class ProfileViewModel {
    
    private let profileService: ProfileServiceProtocol
    private let authService: AuthServiceProtocol
    
    init(
        profileService: ProfileServiceProtocol = Container.shared.profileService(),
        authService: AuthServiceProtocol = Container.shared.authService()
    ) {
        self.profileService = profileService
        self.authService = authService
    }
}
