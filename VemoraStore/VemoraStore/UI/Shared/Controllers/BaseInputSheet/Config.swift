//
//  Config.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 02.10.2025.
//

import UIKit

struct Config {
    let title: String
    let saveTitle: String
    let customDetentHeight: CGFloat
    let titleAlignment: NSTextAlignment
    
    init(
        title: String,
        saveTitle: String,
        customDetentHeight: CGFloat,
        titleAlignment: NSTextAlignment = .left
    ) {
        self.title = title
        self.saveTitle = saveTitle
        self.customDetentHeight = customDetentHeight
        self.titleAlignment = titleAlignment
    }
}
