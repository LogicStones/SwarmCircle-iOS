//
//  RoundCornorView.swift
//  Swarm Circle
//
//  Created by Macbook on 05/07/2022.
//

import Foundation
import UIKit

class CardViewMaterial: UIView {

    override func prepareForInterfaceBuilder() {
        customizeView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        customizeView()
    }
    
    // UIView border
    func customizeView(){
        self.layer.masksToBounds = true
        self.layer.cornerRadius = cornerRadius
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = .zero
        self.layer.shadowColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        self.clipsToBounds = false
    }
}
