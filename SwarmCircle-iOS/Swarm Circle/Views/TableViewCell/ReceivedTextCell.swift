//
//  SendTextCell.swift
//  Swarm Circle
//
//  Created by Macbook on 22/08/2022.
//

import UIKit

class ReceivedTextCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: CircleImage!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var timeAgoLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(info: ChatList?) {
        
        self.profileImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: info?.displayImageURL) {
            self.profileImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.msgLbl.text = Utils.decodeUTF(info?.messageText ?? "")
        
//        self.timeAgoLbl.text = Utils.getFormatedDate(dateString: info?.createdOn ?? "").timeAgo()
        
        self.timeAgoLbl.text = Utils.convertStringDateTo12HourTime(info?.createdOn ?? "")
        
//        self.seenImgView.image = info?.isSeen == true ? UIImage(named: "message-read") : UIImage(named: "message-unread")
    }
    
}
