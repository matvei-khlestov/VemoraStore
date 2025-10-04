//
//  ProfileUserViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 17.09.2025.
//

import Foundation
import Combine

protocol ProfileUserViewModelProtocol: AnyObject {
    var userNamePublisher: AnyPublisher<String, Never> { get }
    var userEmailPublisher: AnyPublisher<String, Never> { get }
    
    var rows: [ProfileUserRow] { get }
    var rowsCount: Int { get }
    func row(at index: Int) -> ProfileUserRow?
    
    func logout() async throws
    func deleteAccount() async throws
    
    func loadAvatarData() -> Data?
}
