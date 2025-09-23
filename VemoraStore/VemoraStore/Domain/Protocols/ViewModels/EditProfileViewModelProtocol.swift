//
//  EditProfileViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation
import Combine

protocol EditProfileViewModelProtocol {
    var avatarDataPublisher: AnyPublisher<Data?, Never> { get }
    var name: String { get }
    var email: String { get }
    var phone: String { get }

    func load()
    func saveAvatarData(_ data: Data) async throws
}
