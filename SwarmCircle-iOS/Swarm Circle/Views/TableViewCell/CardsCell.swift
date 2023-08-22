//
//  CardsCell.swift
//  Swarm Circle
//
//  Created by Macbook on 18/07/2022.
//

import UIKit

class CardsCell: UITableViewCell {

    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardIcon: UIImageView!
    @IBOutlet weak var selectionIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        if selected {
            self.selectionIcon.image = UIImage(named: "gray-selectedRadio")
        } else {
            self.selectionIcon.image = UIImage(named: "gray-Radio")
        }
    }
    
    func configureCell(info: CardDM) {
        
        self.cardNumber.text = "**** **** **** \(info.cardNumber ?? "")"
        
        switch info.cardType {
        case "visa":
            self.cardIcon.image = UIImage(named: "visa-card")
        case "mastercard":
            self.cardIcon.image = UIImage(named: "master_card")
        case "amex":
            self.cardIcon.image = UIImage(named: "american-express-card")
        case "discover":
            self.cardIcon.image = UIImage(named: "discover-card")
        case "dinersClub":
            self.cardIcon.image = UIImage(named: "dinners-club-card")
        case "JCB":
            self.cardIcon.image = UIImage(named: "jcb-card")
        case "unionPay":
            self.cardIcon.image = UIImage(named: "union-pay-card")
        default:
            self.cardIcon.image = UIImage(named: "normal-card")
        }
    }
}
