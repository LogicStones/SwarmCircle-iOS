//
//  UILabel+Extension.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 19/10/2022.
//

import UIKit

extension UILabel {
    
    //    var isTruncated: Bool {
    //        guard let labelText = text else {
    //            return false
    //        }
    //
    //        let labelTextSize = (labelText as NSString).boundingRect(
    //            with: CGSize(width: frame.size.width, height: .greatestFiniteMagnitude),
    //            options: .usesLineFragmentOrigin,
    //            attributes: [.font: font!],
    //            context: nil).size
    //
    //        self.layoutIfNeeded()
    //        return labelTextSize.height > bounds.size.height
    //    }
    
    func countLabelLines() -> Int {
//        self.layoutIfNeeded()
        guard let myText = self.text as? NSString else {return 1}
        let attributes = [NSAttributedString.Key.font : self.font]
        
        let labelSize = myText.boundingRect(with: CGSize(width: self.bounds.width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: attributes as [NSAttributedString.Key : Any], context: nil)
        return Int(ceil(CGFloat(labelSize.height) / self.font.lineHeight))
    }
    
    var isTruncated: Bool {
        
        if (self.countLabelLines() > self.numberOfLines) {
            return true
        }
        return false
    }
}
