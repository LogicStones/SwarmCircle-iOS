//
//  GradientView.swift
//  Swarm Circle
//
//  Created by Macbook on 10/01/2023.
//

import Foundation

import UIKit

class GradientView: UIView {

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
//        gradientLayer.colors = [UIColor.colorWithRed:34.0/255.0 green:211/255.0 blue:198/255.0 alpha:1.0, UIColor.colorWithRed:145/255.0 green:72.0/255.0 blue:203/255.0 alpha:1.0]
//        gradientLayer.colors = [UIColor.init(red: 34.0/255.0, green: 211/255.0, blue: 198/255.0, alpha: 1.0), UIColor.init(red: 145/255.0, green: 72.0/255.0, blue: 203/255.0, alpha: 1.0)]
        gradientLayer.colors = [#colorLiteral(red: 0.7450980392, green: 0, blue: 0.9960784314, alpha: 1).cgColor, #colorLiteral(red: 0.8588235294, green: 0, blue: 0.9960784314, alpha: 1).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.type = .axial
        gradientLayer.endPoint = CGPoint(x:1, y:1)

    }
    
    
}
