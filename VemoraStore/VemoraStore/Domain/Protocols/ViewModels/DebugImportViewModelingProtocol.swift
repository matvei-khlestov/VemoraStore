//
//  DebugImportViewModelProtocol.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 27.09.2025.
//

import Foundation

#if DEBUG

protocol DebugImportViewModelProtocol: AnyObject {
    
    var state: State { get }
    var onStateChange: ((State) -> Void)? { get set }
    
    func setImporterEnabled(_ isOn: Bool)
    func setOverwrite(_ isOn: Bool)
    func setSeedVersion(_ version: Int)
    func bumpSeedVersion(by delta: Int)
    func runImport()
    func resetMarkers()
}
#endif
