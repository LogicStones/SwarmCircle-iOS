//
//  PollOptionsCell.swift
//  Swarm Circle
//
//  Created by Macbook on 08/07/2022.
//

import UIKit

class PollOptionsCell: UITableViewCell {

    @IBOutlet weak var questionLbl: UILabel!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var optionButton: ToggleButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
