//
//  ProfileServiceProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 29.08.2025.
//

import Foundation
import Combine

protocol ProfileServiceProtocol: AnyObject {
    var currentName: String { get }
    func updateName(_ value: String) async throws
    
    var currentEmail: String { get }
    func updateEmail(_ value: String) async throws
}
