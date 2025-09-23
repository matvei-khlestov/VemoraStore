//
//  AvatarStorageServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation

protocol AvatarStorageServiceProtocol {
    func loadAvatarData() -> Data?
    func saveAvatarData(_ data: Data) throws
    func removeAvatar() throws
}
