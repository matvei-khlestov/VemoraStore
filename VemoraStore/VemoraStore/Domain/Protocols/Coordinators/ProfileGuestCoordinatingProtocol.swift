//
//  ProfileGuestCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

protocol ProfileGuestCoordinatingProtocol: Coordinator {
    func start()
    var onAuthCompleted: (() -> Void)? { get set }
}
