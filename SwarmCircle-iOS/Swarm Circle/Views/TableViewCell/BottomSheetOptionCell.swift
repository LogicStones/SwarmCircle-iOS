//
//  BottomSheetOptionCell.swift
//  Swarm Circle
//
//  Created by Macbook on 20/07/2022.
//

import UIKit

class BottomSheetOptionCell: UITableViewCell {

    @IBOutlet weak var optionIcon: UIImageView!
    @IBOutlet weak var optionLBL: UILabel!
    @IBOutlet weak var leadingConstant: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.selectionStyle = .default
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
