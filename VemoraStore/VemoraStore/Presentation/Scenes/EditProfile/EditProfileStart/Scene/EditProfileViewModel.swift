//
//  EditProfileViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import Combine

final class EditProfileViewModel: EditProfileViewModelProtocol {
    
    // MARK: - Deps
    
    private let avatarStorage: AvatarStorageServiceProtocol
    private let repos: RepositoryFactoryProtocol
    private let userId: String
   
    private let profileRepository: ProfileRepository
    
    // MARK: - State
    
    @Published private(set) var name:  String = "—"
    @Published private(set) var email: String = "—"
    @Published private(set) var phone: String = "—"
    @Published private var avatarData: Data?
    
    private var bag = Set<AnyCancellable>()
    
    // MARK: - Outputs
    
    var namePublisher:  AnyPublisher<String, Never>  {
        $name.removeDuplicates().eraseToAnyPublisher()
    }
    
    var emailPublisher: AnyPublisher<String, Never>  {
        $email.removeDuplicates().eraseToAnyPublisher()
    }
    
    var phonePublisher: AnyPublisher<String, Never>  {
        $phone.removeDuplicates().eraseToAnyPublisher()
    }
    
    var avatarDataPublisher: AnyPublisher<Data?, Never> {
        $avatarData.eraseToAnyPublisher()
    }
    
    // MARK: - Init
    
    init(
        avatarStorage: AvatarStorageServiceProtocol,
        repos: RepositoryFactoryProtocol,
        userId: String
    ) {
        self.avatarStorage = avatarStorage
        self.repos = repos
        self.userId = userId
        self.profileRepository = repos.profileRepository(for: userId)
        
        bindProfile()
    }
    
    // MARK: - Intents
    
    func load() {
        avatarData = avatarStorage.loadAvatarData()
    }
    
    func saveAvatarData(_ data: Data) async throws {
        try avatarStorage.saveAvatarData(data)
        await MainActor.run { [weak self] in self?.avatarData = data }
    }
    
    // MARK: - Private
    
    private func bindProfile() {
        profileRepository
            .observeProfile()
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] profile in
                guard let self else { return }
                self.name  = profile?.name  ?? "—"
                self.email = profile?.email ?? "—"
                self.phone = profile?.phone ?? "—"
            }
            .store(in: &bag)
    }
}
