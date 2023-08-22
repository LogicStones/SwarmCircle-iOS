//
//  InformationCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 17/11/2022.
//

import UIKit

class HeadingInfoCell: UITableViewCell {

    @IBOutlet weak var headingLbl: UILabel!
    @IBOutlet weak var informationLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(info: AppInfoDM) {
        
        self.headingLbl.text = info.heading
//        self.informationLbl.text = info.text
        
//        self.headingLbl.attributedText = info.heading?.htmlToAttributedString
        self.informationLbl.attributedText = info.text?.htmlToAttributedString
    }
    
}


