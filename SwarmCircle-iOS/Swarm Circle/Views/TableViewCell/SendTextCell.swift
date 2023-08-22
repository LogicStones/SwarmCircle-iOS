//
//  ReceiveTextCell.swift
//  Swarm Circle
//
//  Created by Macbook on 22/08/2022.
//

import UIKit

class SendTextCell: UITableViewCell {
    
    @IBOutlet weak var optionsButton: UIButton!
    @IBOutlet weak var profileImgView: CircleImage!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var seenImgView: UIImageView!
    @IBOutlet weak var timeAgoLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(info: ChatList?, isGroupChat: Bool) {
        
        self.profileImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: info?.displayImageURL) {
            self.profileImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.msgLbl.text = Utils.decodeUTF(info?.messageText ?? "")
        self.timeAgoLbl.text = Utils.decodeUTF(info?.createdOn ?? "")
        self.timeAgoLbl.text = Utils.convertStringDateTo12HourTime(info?.createdOn ?? "") //Utils.getFormatedDate(dateString: info?.createdOn ?? "").timeAgo()
        print(info?.isSeen)
        
//        self.seenImgView.isHidden = isGroupChat
        self.seenImgView.image = info?.isSeen == true ? UIImage(named: "message-read") : UIImage(named: "message-unread")
    }
    
}
