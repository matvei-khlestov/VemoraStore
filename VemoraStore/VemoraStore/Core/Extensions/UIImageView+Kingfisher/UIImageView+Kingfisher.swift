//
//  UIImageView+Kingfisher.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 14.10.2025.
//


import UIKit
import Kingfisher

extension UIImageView {
    
    /// Загружает изображение с downsampling.
    /// `fadeOnFirstLoad` — плавный fade только при первом показе (когда image == nil).
    func loadImage(from urlString: String?,
                   showIndicator: Bool = false,
                   fadeOnFirstLoad: Bool = true) {
        kf.cancelDownloadTask()
        
        let processor = DownsamplingImageProcessor(size: bounds.size)
        let url = URL(string: urlString ?? "")
        
        kf.indicatorType = showIndicator ? .activity : .none
        
        var options: KingfisherOptionsInfo = [
            .processor(processor),
            .scaleFactor(UIScreen.main.scale),
            .backgroundDecode,
            .cacheOriginalImage,
            .forceTransition
        ]
        
        if fadeOnFirstLoad, self.image == nil {
            options.append(.transition(.fade(0.25)))
        }
        
        kf.setImage(with: url, options: options)
    }
}
