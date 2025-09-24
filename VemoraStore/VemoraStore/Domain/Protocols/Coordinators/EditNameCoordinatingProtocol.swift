//
//  EditNameCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

protocol EditNameCoordinatingProtocol: Coordinator {
    var onFinish: (() -> Void)? { get set }
}
