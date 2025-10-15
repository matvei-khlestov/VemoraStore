//
//  EditProfileViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import Combine

protocol EditProfileViewModelProtocol {
    // Текущие значения (для первичного заполнения ячеек)
    var name:  String { get }
    var email: String { get }
    var phone: String { get }

    // Реактивные обновления (чтобы ячейки обновлялись без перезапуска)
    var namePublisher:  AnyPublisher<String, Never>  { get }
    var emailPublisher: AnyPublisher<String, Never>  { get }
    var phonePublisher: AnyPublisher<String, Never>  { get }

    // Аватар
    var avatarDataPublisher: AnyPublisher<Data?, Never> { get }

    func loadAvatarData()
    
    func saveAvatarData(_ data: Data) async throws
}
