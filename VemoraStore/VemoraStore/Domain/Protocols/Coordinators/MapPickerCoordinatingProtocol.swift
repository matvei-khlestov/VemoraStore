//
//  MapPickerCoordinatingProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 23.09.2025.
//

import UIKit

protocol MapPickerCoordinatingProtocol: Coordinator {
    var onFinish: (() -> Void)? { get set }
    var onFullAddressPicked: ((String) -> Void)? { get set }
    func start()
}
