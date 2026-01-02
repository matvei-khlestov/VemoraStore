//
//  UIView+Animations.swift
//  VemoraStore
//
//  Created by Matvei Khlestov on 05.09.2025.
//

import UIKit

extension UIView {
    func pulse(
        scale: CGFloat = 0.9,
        duration: TimeInterval = 0.12,
        returnDuration: TimeInterval = 0.18
    ) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }) { _ in
            UIView.animate(withDuration: returnDuration) {
                self.transform = .identity
            }
        }
    }
}
