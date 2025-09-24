//
//  FirebaseProfileService.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation

final class FirebaseProfileService: ProfileServiceProtocol {

    private var storedName: String = "Матвей"
    private var storedEmail: String = "khlestov.matvei@gmail.com"

    // MARK: - Name

    var currentName: String { storedName }

    func updateName(_ value: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        storedName = value
    }

    // MARK: - Email

    var currentEmail: String { storedEmail }

    func updateEmail(_ value: String) async throws {
        try await Task.sleep(nanoseconds: 300_000_000)
        storedEmail = value
    }
}
