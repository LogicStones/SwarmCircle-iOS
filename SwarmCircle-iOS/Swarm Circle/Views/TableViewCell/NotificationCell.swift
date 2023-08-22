//
//  NotificationCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/09/2022.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var notifMsgLbl: UILabel!
    @IBOutlet weak var notifTimeLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(info: NotificationDM) {
        self.notifMsgLbl.text = info.message ?? ""
        self.notifTimeLbl.text = info.durationAgo ?? ""
    }
    
}
