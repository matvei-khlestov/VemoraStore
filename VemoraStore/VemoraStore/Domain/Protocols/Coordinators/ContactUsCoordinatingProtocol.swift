//
//  ContactUsCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

protocol ContactUsCoordinatingProtocol: Coordinator {
    func start()
    var onFinish: (() -> Void)? { get set }
}
