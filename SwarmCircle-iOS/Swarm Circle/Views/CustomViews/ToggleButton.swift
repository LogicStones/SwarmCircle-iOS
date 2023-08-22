//
//  ToggleButton.swift
//  Swarm Circle
//
//  Created by Macbook on 07/07/2022.
//

import Foundation
import UIKit
class ToggleButton : UIButton {
    
    @IBInspectable var selectedColor: UIColor? = UIColor.clear
    @IBInspectable var unSelectedColor: UIColor? = UIColor.white
    @IBInspectable var selectedTitleColor: UIColor? = UIColor.white
    @IBInspectable var unSelectedTitleColor: UIColor? = UIColor(named: "lightTextColor")
    
    
    override var isSelected: Bool {
        didSet {
            self.backgroundColor = isSelected ? selectedColor : unSelectedColor
//            self.titleLabel?.textColor = isSelected ? selectedTitleColor : unSelectedTitleColor
            self.setTitleColor(unSelectedTitleColor, for: .normal)
            self.setTitleColor(selectedTitleColor, for: .selected)
        }
        willSet{
//            if isSelected{
////                self.setTitleColor(.white, for: .selected)
//                self.setTitleColor(.white, for: .normal)
//            } else {
//                self.setTitleColor(UIColor(named: "lightTextColor"), for: .selected)
//            }
//            self.setTitleColor(.white, for: .selected)
//            self.setTitleColor(UIColor(named: "lightTextColor"), for: .normal)
            self.titleLabel?.textColor = isSelected ? selectedTitleColor : unSelectedTitleColor
        }
    }
    
    override func awakeFromNib() {
        self.titleLabel?.textColor = isSelected ? selectedTitleColor : unSelectedTitleColor
    }
}
