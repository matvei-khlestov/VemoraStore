//
//  DebugImportStoringProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

#if DEBUG
protocol DebugImportStoringProtocol: AnyObject {
    var isOverwriteEnabled: Bool { get set }
    var isDebugImportEnabled: Bool { get set }
    var didSeed: Bool { get set }
    var didRunOnce: Bool { get }
    var seedVersion: Int { get set }
    var requiredSeedVersion: Int { get set }
    
    func resetSeedMarkers()
}
#endif
