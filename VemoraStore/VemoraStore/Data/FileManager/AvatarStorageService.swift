//
//  AvatarStorageService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

/// Сервис `AvatarStorageService`
///
/// Отвечает за локальное хранение и управление аватаром пользователя.
/// Реализует протокол `AvatarStorageServiceProtocol` и использует `FileManager`
/// для сохранения, загрузки и удаления изображения из директории `Documents`.
///
/// Основные задачи:
/// - сохранение изображения пользователя локально;
/// - безопасное чтение данных аватара (если файл существует);
/// - удаление сохранённого изображения при необходимости.
///
/// Используется в:
/// - `ProfileUserViewModel` для отображения и обновления аватара;
/// - `EditProfileViewController` при изменении изображения.
///
/// Все операции выполняются синхронно, что упрощает работу с UI.

final class AvatarStorageService: AvatarStorageServiceProtocol {
    
    // MARK: - Dependencies
    
    /// Менеджер файловой системы.
    private let fm = FileManager.default
    
    // MARK: - Configuration
    
    /// Имя файла, под которым сохраняется аватар.
    private let fileName = "avatar.jpg"
    
    /// URL для сохранения файла аватара в директории Documents.
    private var url: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    // MARK: - Public Methods
    
    /// Загружает сохранённые данные аватара (если файл существует).
    func loadAvatarData() -> Data? {
        try? Data(contentsOf: url)
    }
    
    /// Сохраняет изображение пользователя локально.
    /// - Parameter data: Данные изображения.
    /// - Throws: Ошибка записи файла при невозможности сохранения.
    func saveAvatarData(_ data: Data) throws {
        try data.write(to: url, options: .atomic)
    }
    
    /// Удаляет сохранённый аватар, если он существует.
    /// - Throws: Ошибка удаления файла, если операция не удалась.
    func removeAvatar() throws {
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
    }
}
