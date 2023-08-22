//
//  MessengerCell.swift
//  Swarm Circle
//
//  Created by Macbook on 22/08/2022.
//

import UIKit

class MessengerCell: UITableViewCell {

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var timeLBL: UILabel!
    @IBOutlet weak var dpImage: CircleImage!
    @IBOutlet weak var msgLBL: UILabel!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        statusView.cornerRadius = statusView.frame.width / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    func configCell(chatResponse: MessagesListDM){
        
        self.isVerifiedIcon.isHidden = !(chatResponse.isAccountVerified ?? false)
        
        self.titleLBL.text = "\(chatResponse.firstName?.capitalized ?? "") \(chatResponse.lastName?.capitalized ?? "")"
        self.msgLBL.text = Utils.decodeUTF(chatResponse.messageText ?? "")
        if let imgURL = Utils.getCompleteURL(urlString: chatResponse.displayImageURL) {
            self.dpImage.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.dpImage.image = UIImage(named: "defaultProfileImage")!
        }
        self.statusView.isHidden = !(chatResponse.isOnline ?? false)
        self.timeLBL.text = Utils.convertStringDateTo12HourTime(chatResponse.createdOn ?? "")// Utils.getFormatedDate(dateString:  chatResponse.createdOn ?? "").timeAgo()
    }
    
}
