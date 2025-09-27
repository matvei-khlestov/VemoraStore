//
//  State.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 26.09.2025.
//

import Foundation

struct State {
    var isRunning: Bool = false
    var hasRunBefore: Bool
    var isEnabledFlag: Bool
    var overwrite: Bool = false
    var seedVersion: Int
    var log: String = ""
}
