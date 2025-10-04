//
//  ProfileUserViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Foundation
import Combine

final class ProfileUserViewModel: ProfileUserViewModelProtocol {
    
    // MARK: - Dependencies
    
    private let auth: AuthServiceProtocol
    private let avatarStorage: AvatarStorageServiceProtocol
    private let repos: RepositoryFactoryProtocol
    private let userId: String
    
    // Репозиторий теперь храним, чтобы не деинициализировался
    private let profileRepository: ProfileRepository
    
    // MARK: - State
    
    @Published private(set) var userName: String  = "—"
    @Published private(set) var userEmail: String = "—"
    
    var userNamePublisher: AnyPublisher<String, Never>  { $userName.eraseToAnyPublisher() }
    var userEmailPublisher: AnyPublisher<String, Never> { $userEmail.eraseToAnyPublisher() }
    
    // MARK: - Table
    
    let rows: [ProfileUserRow] = [.editProfile, .orders, .about, .contact, .privacy]
    var rowsCount: Int { rows.count }
    func row(at index: Int) -> ProfileUserRow? { rows.indices.contains(index) ? rows[index] : nil }
    
    // MARK: - Internals
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Init
    
    init(
        auth: AuthServiceProtocol,
        avatarStorage: AvatarStorageServiceProtocol,
        repos: RepositoryFactoryProtocol,
        userId: String
    ) {
        self.auth = auth
        self.avatarStorage = avatarStorage
        self.repos = repos
        self.userId = userId
        self.profileRepository = repos.profileRepository(for: userId)
        
        bindProfile()
    }
    
    // MARK: - Intents
    
    func logout() async throws {
        try await auth.signOut()
    }
    func deleteAccount() async throws {
        try await auth.deleteAccount()
    }
    
    // MARK: - Avatar
    
    func loadAvatarData() -> Data? {
        avatarStorage.loadAvatarData()
    }
    
    // MARK: - Private
    
    private func bindProfile() {
        // Подписка на локальные изменения профиля
        profileRepository.observeProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.userName  = profile?.name  ?? "—"
                self.userEmail = profile?.email ?? "—"
            }
            .store(in: &bag)
    }
}

