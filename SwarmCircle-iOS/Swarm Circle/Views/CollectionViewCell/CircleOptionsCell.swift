//
//  CircleOptionsCell.swift
//  Swarm Circle
//
//  Created by Macbook on 05/07/2022.
//

import UIKit

class CircleOptionsCell: UICollectionViewCell {

    @IBOutlet weak var featureIcon: UIImageView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var cardView: CardViewMaterial!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        self.cardView.cornerRadius = (self.cardView.frame.height / 2)
    }

}
