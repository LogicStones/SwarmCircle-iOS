//
//  CircleCell.swift
//  Swarm Circle
//
//  Created by Macbook on 21/07/2022.
//

import UIKit

class CircleCell: UICollectionViewCell {

    @IBOutlet weak var counterView: UIView!
    @IBOutlet weak var countLBL: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var imageWidth: NSLayoutConstraint!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var circleImage: CircleImage!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

}
