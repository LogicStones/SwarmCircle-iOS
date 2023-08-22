//
//  interestsTagCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 24/08/2022.
//

import UIKit

class InterestsTagCell: UICollectionViewCell {
    
    
    @IBOutlet weak var cellTapBtn: UIButton!
    @IBOutlet weak var tagName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(_ info: TagDM) {
        self.tagName.text = info.name ?? "Some Tag"
    }

}
