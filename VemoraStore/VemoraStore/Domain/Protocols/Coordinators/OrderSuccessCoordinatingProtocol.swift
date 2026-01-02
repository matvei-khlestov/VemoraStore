//
//  OrderSuccessCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

protocol OrderSuccessCoordinatingProtocol: Coordinator {
    var onOpenCatalog: (() -> Void)? { get set }
    var onFinish: (() -> Void)? { get set }
    func start()
}
