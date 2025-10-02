//
//  CheckoutCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

protocol CheckoutCoordinatingProtocol: Coordinator {
    var onFinish: (() -> Void)? { get set }
    var onOrderSuccess: (() -> Void)? { get set }
    func start()
}
