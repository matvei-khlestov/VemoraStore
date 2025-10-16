//
//  AvatarStorageMock.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 16.10.2025.
//

import Foundation
@testable import VemoraStore

final class AvatarStorageMock: AvatarStorageServiceProtocol {
    var stubData: Data? = nil
    func loadAvatarData() -> Data? { stubData }
    func saveAvatarData(_ data: Data) throws { stubData = data }
    func removeAvatar() throws { stubData = nil }
}
