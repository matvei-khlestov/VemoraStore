//
//  ProfileUserViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Foundation

final class ProfileUserViewModel: ProfileUserViewModelProtocol {
    
    // MARK: - Deps
    
    private let auth: AuthServiceProtocol
    private let avatarStorage: AvatarStorageServiceProtocol
    
    // MARK: - User data
    
    var userName = "Матвей"
    var userEmail = "khlestov.matvei@gmail.com"
    
    // MARK: - Table
    
    let rows: [ProfileUserRow] = [.editProfile, .orders, .about, .contact, .privacy]
    var rowsCount: Int { rows.count }
    func row(at index: Int) -> ProfileUserRow? {
        rows.indices.contains(index) ? rows[index] : nil
    }
    
    // MARK: - Init
    
    init(
        auth: AuthServiceProtocol,
        avatarStorage: AvatarStorageServiceProtocol
    ) {
        self.auth = auth
        self.avatarStorage = avatarStorage
    }
    
    // MARK: - Intents
    
    func logout() async throws {
        try await auth.signOut()
    }
    
    func deleteAccount() async throws {
        try await auth.deleteAccount()
    }
    
    // MARK: - Avatar
    
    func loadAvatarData() -> Data? { avatarStorage.loadAvatarData() }
}
