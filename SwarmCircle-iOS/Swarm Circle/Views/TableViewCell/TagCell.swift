//
//  TagCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 27/12/2022.
//

import UIKit

class TagCell: UITableViewCell {

    @IBOutlet weak var selectionBtn: UIButton!
    @IBOutlet weak var tagLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
        self.selectionBtn.isSelected = selected
    }
    
    func configureCell(_ info: TagDM) {
        
        self.tagLbl.text = info.name ?? "Some Tag"
    }
    
}
