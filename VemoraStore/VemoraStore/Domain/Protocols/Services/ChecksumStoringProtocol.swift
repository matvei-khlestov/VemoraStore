//
//  ChecksumStoringProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import Foundation

#if DEBUG
protocol ChecksumStoringProtocol: AnyObject {
    func value(for name: String) -> String?
    func set(_ value: String?, for name: String)
}
#endif
