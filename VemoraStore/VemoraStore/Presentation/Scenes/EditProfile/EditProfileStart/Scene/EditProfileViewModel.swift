//
//  EditProfileViewModel.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import Combine

/// ViewModel `EditProfileViewModel` для экрана редактирования профиля.
///
/// Основные задачи:
/// - Наблюдение за изменениями данных профиля через `ProfileRepository`;
/// - Отображение имени, почты, телефона и аватара пользователя;
/// - Загрузка и сохранение аватара через `AvatarStorageServiceProtocol`;
/// - Синхронизация номера телефона с `CheckoutStoringProtocol`
///   для корректного оформления заказов.
///
/// Обеспечивает реактивное обновление состояния через Combine
/// и поддерживает актуальность пользовательских данных в профиле.

final class EditProfileViewModel: EditProfileViewModelProtocol {
    
    // MARK: - Deps
    
    private let avatarStorage: AvatarStorageServiceProtocol
    private let userId: String
    private let profileRepository: ProfileRepository
    private var checkoutStorage: CheckoutStoringProtocol
    
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
        profileRepository: ProfileRepository,
        userId: String,
        checkoutStorage: CheckoutStoringProtocol
    ) {
        self.avatarStorage = avatarStorage
        self.profileRepository = profileRepository
        self.userId = userId
        self.checkoutStorage = checkoutStorage
        
        bindProfile()
    }
    
    // MARK: - Intents
    
    func loadAvatarData() {
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
                if let phone = profile?.phone, !phone.isEmpty, phone != "—" {
                    self.checkoutStorage.savedReceiverPhoneE164 = phone
                }
            }
            .store(in: &bag)
    }
}
