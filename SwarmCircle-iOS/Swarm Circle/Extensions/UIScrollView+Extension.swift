//
//  UIScrollView+Extension.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 26/09/2022.
//

import UIKit

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
   }
}
