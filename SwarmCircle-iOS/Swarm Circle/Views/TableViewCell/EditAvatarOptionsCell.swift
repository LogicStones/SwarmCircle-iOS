//
//  EditAvatarOptionsCell.swift
//  Swarm Circle
//
//  Created by Macbook on 20/07/2022.
//

import UIKit

class EditAvatarOptionsCell: UITableViewCell {

    @IBOutlet weak var featureLBL: UILabel!
    @IBOutlet weak var featureIcon: UIImageView!
    @IBOutlet weak var bottomBorder: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected{
            self.bottomBorder.backgroundColor = UIColor(named: "FontColor")
            let currentImage = self.featureIcon.image
            self.featureIcon.image = currentImage?.imageWithColor(color: UIColor(named: "FontColor")!)
            self.featureLBL.textColor = .black
        } else {
            self.bottomBorder.backgroundColor = .clear
            self.featureLBL.textColor = UIColor(named: "lightTextColor")
            let currentImage = self.featureIcon.image
            self.featureIcon.image = currentImage?.imageWithColor(color: UIColor(named: "lightTextColor")!)
        }
    }
    
    func configureCell(fImage: UIImage, featureName: String){
        self.featureIcon.image = fImage.imageWithColor(color: UIColor(named: "lightTextColor")!)
        self.featureLBL.text = featureName
    }
}
