//
//  BlockedFriendsCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 18/08/2022.
//

import UIKit

class BlockedFriendsCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var unblockBtn: UIButton!
    @IBOutlet weak var circleCountLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(userInfo: BlockedFriendDM) {
        
        self.isVerifiedIcon.isHidden = !(userInfo.isAccountVerified ?? false)
        
        self.name.text = userInfo.name?.capitalized ?? ""
        
        self.circleCountLbl.text = "\(userInfo.circleCount) Circle\(userInfo.circleCount > 0 ? "s" : "")"
        
        if let imgURL = Utils.getCompleteURL(urlString: userInfo.displayImageURL) {
            
            self.profileImage.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImage.image = UIImage(named: "defaultProfileImage")!
        }
    }
    
}
