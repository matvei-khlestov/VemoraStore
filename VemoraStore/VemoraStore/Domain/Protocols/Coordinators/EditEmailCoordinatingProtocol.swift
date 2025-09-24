//
//  EditEmailCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 24.09.2025.
//

import Foundation

protocol EditEmailCoordinatingProtocol: Coordinator {
    var onFinish: (() -> Void)? { get set }
}
