//
//  TabBar.swift
//  Swarm Circle
//
//  Created by Macbook on 29/04/2022.
//

import UIKit

@IBDesignable class TabBar: UITabBar {
    @IBInspectable var color: UIColor?
    @IBInspectable var radii: CGFloat = 20.0

    private var shapeLayer: CALayer?

    override func draw(_ rect: CGRect) {
        addShape()
    }

    private func addShape() {
        let shapeLayer = CAShapeLayer()

        shapeLayer.path = createPath()
        shapeLayer.strokeColor =  UIColor(hexString: "#F2F2F2").cgColor //UIColor.gray.withAlphaComponent(0.1).cgColor
        shapeLayer.fillColor = color?.cgColor ?? UIColor.white.cgColor
        shapeLayer.lineWidth = 1
//        shapeLayer.shadowColor = UIColor.black.cgColor
//        shapeLayer.shadowOffset = CGSize(width: 0   , height: -1);
//        shapeLayer.shadowOpacity = 0.1
        shapeLayer.shadowPath =  UIBezierPath(roundedRect: bounds, cornerRadius: radii).cgPath
        

        if let oldShapeLayer = self.shapeLayer {
            layer.replaceSublayer(oldShapeLayer, with: shapeLayer)
        } else {
            layer.insertSublayer(shapeLayer, at: 0)
        }

        self.shapeLayer = shapeLayer
    }

    private func createPath() -> CGPath {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: radii, height: 0.0))

        return path.cgPath
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.isTranslucent = true
        let tabFrame = self.frame
//        tabFrame.size.height    = 65 + (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? CGFloat.zero)
//        tabFrame.origin.y       = self.frame.origin.y +   ( self.frame.height - 65 - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? CGFloat.zero))
        self.layer.cornerRadius = 20
        self.frame = tabFrame
//        self.items?.forEach({ $0.titlePositionAdjustment = UIOffset(horizontal: 0.0, vertical: -5.0) })


    }

}
