//
//  ActivityIndicatorExtension.swift
//  Swarm Circle
//
//  Created by Macbook on 29/04/2022.
//

import Foundation
import UIKit

// MARK: - Custom Activity Indicator
extension UIActivityIndicatorView {
    public static func customIndicator(at center: CGPoint) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        indicator.layer.cornerRadius = 0
        indicator.color = .label
        indicator.center = center
        indicator.backgroundColor =  UIColor.clear
        indicator.hidesWhenStopped = true
        
        return indicator
    }
}
