//
//  ChatDateHeaderView.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 24/10/2022.
//

import UIKit

class ChatDateHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var conversationDateLbl: UILabel!
    
    func configureHeader(info: String) {
        self.conversationDateLbl.text = info
    }

}
