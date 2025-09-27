//
//  OrdersCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import Foundation

protocol OrdersCoordinatingProtocol: Coordinator {
    func start()
    var onFinish: (() -> Void)? { get set }
}
