//
//  EditProfileViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import Combine

final class EditProfileViewModel: EditProfileViewModelProtocol {
    
    private let avatarStorage: AvatarStorageServiceProtocol

    private(set) var name: String = "Matvei"
    private(set) var email: String = "example@example.com"
    private(set) var phone: String = "+79123456789"

    @Published private var avatarData: Data?

    init(avatarStorage: AvatarStorageServiceProtocol) {
        self.avatarStorage = avatarStorage
    }

    var avatarDataPublisher: AnyPublisher<Data?, Never> { $avatarData.eraseToAnyPublisher() }

    func load() { avatarData = avatarStorage.loadAvatarData() }

    func saveAvatarData(_ data: Data) async throws {
        try avatarStorage.saveAvatarData(data)
        await MainActor.run { [weak self] in self?.avatarData = data }
    }
}
