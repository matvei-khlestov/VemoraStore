//
//  UIView+ext.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 28.09.2025.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { self.addSubview($0) }
    }
    
    func shake(
        offset: CGFloat = 6,
        duration: CFTimeInterval = 0.05,
        repeatCount: Float = 3
    ) {
        let anim = CABasicAnimation(keyPath: "position")
        anim.duration = duration
        anim.repeatCount = repeatCount
        anim.autoreverses = true
        anim.fromValue = NSValue(
            cgPoint: CGPoint(x: center.x - offset, y: center.y)
        )
        anim.toValue = NSValue(
            cgPoint: CGPoint(x: center.x + offset, y: center.y)
        )
        layer.add(anim, forKey: "shake")
    }
}
