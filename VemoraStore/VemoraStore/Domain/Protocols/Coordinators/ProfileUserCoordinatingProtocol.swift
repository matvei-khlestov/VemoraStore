//
//  ProfileUserCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

protocol ProfileUserCoordinatingProtocol: Coordinator {
    func start()
    var onLogout: (() -> Void)? { get set }
    var onDeleteAccount: (() -> Void)? { get set }
}
