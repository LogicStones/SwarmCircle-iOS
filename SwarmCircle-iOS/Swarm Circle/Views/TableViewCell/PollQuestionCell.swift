//
//  PollQuestionCell.swift
//  Swarm Circle
//
//  Created by Macbook on 08/07/2022.
//

import UIKit

class PollQuestionCell: UITableViewCell {

    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var optionTF: UITextField!
    @IBOutlet weak var titleLBL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.optionTF.keyboardType = .asciiCapable
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
