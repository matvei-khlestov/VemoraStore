//
//  MainCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation

protocol MainCoordinatingProtocol: Coordinator {
    var onDeleteAccount: (() -> Void)? { get set }
    var onLogout: (() -> Void)? { get set }
    var onOrderSuccess: (() -> Void)? { get set }
}
