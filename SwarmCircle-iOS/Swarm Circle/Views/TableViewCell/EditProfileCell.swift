//
//  EditProfileCell.swift
//  Swarm Circle
//
//  Created by Macbook on 05/07/2022.
//

import UIKit

class EditProfileCell: UITableViewCell {

    @IBOutlet weak var optionTitleLBL: UILabel!
    @IBOutlet weak var optionIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .gray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
