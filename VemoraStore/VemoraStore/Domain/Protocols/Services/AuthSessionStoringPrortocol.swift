//
//  AuthSessionStoringPrortocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import Foundation

protocol AuthSessionStoringPrortocol: AnyObject {
    var userId: String? { get }
    var authProvider: String? { get }
    
    func saveSession(userId: String, provider: String)
    func clearSession()
}
