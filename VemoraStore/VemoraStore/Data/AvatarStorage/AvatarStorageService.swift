//
//  AvatarStorageService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

final class AvatarStorageService: AvatarStorageServiceProtocol {
    
    private let fm = FileManager.default
    private let fileName = "avatar.jpg"
    private var url: URL { fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName) }

    func loadAvatarData() -> Data? {
        try? Data(contentsOf: url)
    }
    func saveAvatarData(_ data: Data) throws {
        try data.write(to: url, options: .atomic)
    }
    func removeAvatar() throws {
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
    }
}
