//
//  CircleImage.swift
//  Swarm Circle
//
//  Created by Macbook on 21/07/2022.
//

import Foundation
import UIKit
@IBDesignable

class CircleImage: UIImageView {

    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    func customizeView(){
//        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width / 2
        self.clipsToBounds = true
    }

}
