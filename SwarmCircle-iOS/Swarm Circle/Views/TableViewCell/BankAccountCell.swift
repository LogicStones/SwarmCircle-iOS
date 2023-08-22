//
//  BankAccountCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/10/2022.
//

import UIKit

class BankAccountCell: UITableViewCell {
    
    
    @IBOutlet weak var selectionIcon: UIImageView!
    @IBOutlet weak var bankNameLbl: UILabel!
    @IBOutlet weak var accNumberLbl: UILabel!
    @IBOutlet weak var routingNumberLbl: UILabel!
    @IBOutlet weak var accountStatusView: UIView!
    @IBOutlet weak var accountStatusLbl: UILabel!
    
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
    
    func configureCell(info: BankAccountDM) {
        
        self.bankNameLbl.text = info.bankName ?? ""
        self.accNumberLbl.text = "Account No: \(info.accountNumber ?? "")"
        self.routingNumberLbl.text = "Routing No: \(info.routingNumber ?? "")"
        
        if info.isStripeActive ?? false {
            self.accountStatusView.backgroundColor = UIColor(named: "FontColor")
            self.accountStatusLbl.text = "Verified"
        } else {
            self.accountStatusView.backgroundColor = UIColor(named: "lightTextColor")
            self.accountStatusLbl.text = "Pending"
        }
    }
    
}
