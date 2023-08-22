//
//  DocumentTypeCell.swift
//  Swarm Circle
//
//  Created by Macbook on 05/06/2023.
//

import UIKit

class DocumentTypeCell: UITableViewCell {

    @IBOutlet weak var radioIV: UIImageView!
    @IBOutlet weak var iconIV: UIImageView!
//    @IBOutlet weak var descLBL: UILabel!
    @IBOutlet weak var titleLBL: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected{
            self.radioIV.image = UIImage(named: "selectedRadioIcon")
        } else {
            self.radioIV.image = UIImage(named: "radioIcon 1")
        }
    }
    
    func configureCell(_ object: (UIImage, String, String)) {
        self.iconIV.image = object.0
        self.titleLBL.text = object.1
//        self.descLBL.text = object.2
    }
}
