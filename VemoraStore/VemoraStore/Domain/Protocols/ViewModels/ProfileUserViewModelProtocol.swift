//
//  ProfileUserViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Foundation

protocol ProfileUserViewModelProtocol: AnyObject {
    var userName: String { get }
    var userEmail: String { get }

    var rows: [ProfileUserRow] { get }
    var rowsCount: Int { get }
    func row(at index: Int) -> ProfileUserRow?

    // Интенты с результатом
    func logout() async throws
    func deleteAccount() async throws
}
