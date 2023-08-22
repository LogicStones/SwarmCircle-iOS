//
//  TransactionRecordCell.swift
//  Swarm Circle
//
//  Created by Macbook on 07/07/2022.
//

import UIKit

class TransactionRecordCell: UITableViewCell {
    
    @IBOutlet weak var accountLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var actionLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet var currencyIconImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(info: TransactionDM) {
        
        self.accountLbl.text = info.account
        
        if let stringDate = info.date {
            
            self.dateLbl.text = Utils.getFormattedDateShortFormat(dateString: stringDate)
        }
        
        self.actionLbl.text = info.transType
        
        switch info.transType {
        case "Deposited":
            self.actionLbl.textColor = UIColor(red: 88/255, green: 173/255, blue: 231/255, alpha: 1)
        case _ where info.transType?.contains("Withdrawn") ?? false:
            self.actionLbl.textColor = UIColor(hexString: "#F19301")
        case "Transferred":
            self.actionLbl.textColor = UIColor(named: "FontColor")
        default:
            print("Switch default case")
        }
        
        if info.transType == "Transferred" {
            self.amountLbl.text = "\(info.amount ?? 0.0)"
            self.currencyIconImgView.isHidden = false
        } else {
            self.amountLbl.text = "$ \(info.amount ?? 0.0)"
            self.currencyIconImgView.isHidden = true
        }
        
        
    }
    
}
