//
//  DefaultProfileRepository.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 03.10.2025.
//

import Foundation
import Combine

/// Класс `DefaultProfileRepository` — реализация репозитория профиля
///
/// Назначение:
/// - объединяет работу удалённого источника (`ProfileCollectingProtocol`) и локального (`ProfileLocalStore`);
/// - обеспечивает реактивное наблюдение и синхронизацию профиля пользователя между Firestore и Core Data.
///
/// Состав:
/// - `remote`: Firestore-хранилище профилей пользователей;
/// - `local`: локальное Core Data-хранилище профиля;
/// - `userId`: идентификатор текущего пользователя;
/// - `subject`: Combine-паблишер, транслирующий текущее состояние профиля пользователя.
///
/// Основные функции:
/// - `observeProfile()` — реактивное наблюдение за профилем в реальном времени;
/// - `refresh(uid:)` — одноразовое обновление локальных данных из Firestore;
/// - `ensureInitialProfile(uid:name:email:)` — создание или обновление базового профиля при регистрации;
/// - `updateName(uid:name:)`, `updateEmail(uid:email:)`, `updatePhone(uid:phone:)` — обновление отдельных полей профиля.
///
/// Особенности реализации:
/// - данные из Firestore автоматически обновляют локальное хранилище при изменении (`listenProfile`);
/// - локальный стор транслирует изменения через Combine (`CurrentValueSubject`);
/// - реализовано устранение лишних апдейтов с помощью `removeDuplicates(by:)` по ключевым полям и `updatedAt`;
/// - полностью реактивная архитектура — обновления профиля немедленно отражаются в UI без ручного запроса.

final class DefaultProfileRepository: ProfileRepository {
    
    // MARK: - Deps
    
    private let remote: ProfileCollectingProtocol
    private let local: ProfileLocalStore
    private let userId: String
    
    // MARK: - State
    
    private var bag = Set<AnyCancellable>()
    private let subject = CurrentValueSubject<UserProfile?, Never>(nil)
    
    // MARK: - Init
    
    init(
        remote: ProfileCollectingProtocol,
        local: ProfileLocalStore,
        userId: String
    ) {
        self.remote = remote
        self.local = local
        self.userId = userId
        
        bindProfileStreams()
    }
    
    // MARK: - Public API
    
    func observeProfile() -> AnyPublisher<UserProfile?, Never> {
        subject.eraseToAnyPublisher()
    }
    
    func refresh(uid: String) async throws {
        if let dto = try await remote.fetchProfile(uid: uid) {
            local.upsertProfile(dto)
        }
    }
    
    func ensureInitialProfile(uid: String, name: String, email: String) async throws {
        try await remote.ensureInitialUserProfile(uid: uid, name: name, email: email)
    }
    
    func updateName(uid: String, name: String) async throws {
        try await remote.updateName(uid: uid, name: name)
    }
    
    func updateEmail(uid: String, email: String) async throws {
        try await remote.updateEmail(uid: uid, email: email)
    }
    
    func updatePhone(uid: String, phone: String) async throws {
        try await remote.updatePhone(uid: uid, phone: phone)
    }
}

// MARK: - Private

private extension DefaultProfileRepository {
    func bindProfileStreams() {
        // Локальное хранилище -> паблишер профиля
        local.observeProfile(userId: userId)
            .subscribe(subject)
            .store(in: &bag)
        
        // Ремоут-слушатель -> локальное хранилище (с фильтром по updatedAt)
        remote.listenProfile(uid: userId)
            .compactMap { $0 }
            .removeDuplicates(by: { old, new in
                // сравниваем содержимое, а не только дату
                old.name == new.name &&
                old.email == new.email &&
                old.phone == new.phone &&
                old.updatedAt == new.updatedAt
            })
            .sink { [weak self] dto in
                self?.local.upsertProfile(dto)
            }
            .store(in: &bag)
    }
}
