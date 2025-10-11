//
//  ProfileUserViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Foundation
import Combine

final class ProfileUserViewModel: ProfileUserViewModelProtocol {
    
    // MARK: - Deps
    private let auth: AuthServiceProtocol
    private let avatarStorage: AvatarStorageServiceProtocol
    private let profileRepository: ProfileRepository
    private let userId: String

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
        profileRepository: ProfileRepository,
        userId: String
    ) {
        self.auth = auth
        self.avatarStorage = avatarStorage
        self.profileRepository = profileRepository
        self.userId = userId
        bindProfile()
    }

    // MARK: - Intents
    func logout() async throws { try await auth.signOut() }
    func deleteAccount() async throws { try await auth.deleteAccount() }

    // MARK: - Avatar
    func loadAvatarData() -> Data? { avatarStorage.loadAvatarData() }

    // MARK: - Private
    private func bindProfile() {
        profileRepository.observeProfile()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                self?.userName  = profile?.name  ?? "—"
                self?.userEmail = profile?.email ?? "—"
            }
            .store(in: &bag)
    }
}

