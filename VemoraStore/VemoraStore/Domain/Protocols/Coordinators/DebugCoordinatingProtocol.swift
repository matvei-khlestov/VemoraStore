//
//  DebugCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import Foundation

protocol DebugCoordinatingProtocol: Coordinator {
    func start()
    var onFinish: (() -> Void)? { get set }
}
