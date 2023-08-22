//
//  GroupCallingCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 29/11/2022.
//

import UIKit

class GroupCallingCell: UITableViewCell {

    @IBOutlet weak var microphoneBtn: UIButton!
    @IBOutlet weak var titleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(name: String) {
        self.titleLbl.text = name.capitalized
    }
    
}
