//
//  EditProfileCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation

protocol EditProfileCoordinatingProtocol: Coordinator {
    var onFinish: (() -> Void)? { get set }
}
