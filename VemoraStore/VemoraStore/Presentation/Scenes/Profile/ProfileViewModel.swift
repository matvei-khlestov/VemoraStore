//
//  ProfileViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine
import FactoryKit

final class ProfileViewModel {
    
    // MARK: - Services
    private let profileService: ProfileServiceProtocol
    private let authService: AuthServiceProtocol
    
    // MARK: - State
    @Published private(set) var profile: Profile?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(
        profileService: ProfileServiceProtocol = Container.shared.profileService(),
        authService: AuthServiceProtocol = Container.shared.authService()
    ) {
        self.profileService = profileService
        self.authService = authService
    }
    
    // MARK: - Actions
    func loadProfile() {
        guard let uid = authService.currentUserId else { return }
        profileService.loadProfile(uid: uid)
            .replaceError(with: Profile(uid: uid, displayName: "Гость", email: "", photoURL: URL(string: "https://example.com/avatar.png")))
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in self?.profile = $0 }
            .store(in: &cancellables)
    }
    
    func updateProfile(_ profile: Profile, avatar: Data?) {
        Task {
            do {
                try await profileService.updateProfile(profile, avatar: avatar)
                await MainActor.run { [weak self] in
                    self?.profile = profile
                }
            } catch {
                print("Ошибка обновления профиля: \(error)")
            }
        }
    }
    
    func logout() {
        try? authService.signOut()
    }
}
