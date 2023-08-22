//
//  InviteFriendsCell.swift
//  Swarm Circle
//
//  Created by Macbook on 07/07/2022.
//

import UIKit
import Kingfisher

class InviteFriendsCell: UITableViewCell {

    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var inviteBTN: ToggleButton!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(userInfo: UsersListDM) {
        
        self.isVerifiedIcon.isHidden = !(userInfo.isAccountVerified ?? false)

//        if userInfo.isFriendRequest ?? false {
//            self.inviteBtn.isSelected = true
//            self.inviteBtn.setTitle("     Cancel     ", for: .selected)
            
//        } else {
//            self.inviteBtn.isSelected = false
//            self.inviteBtn.setTitle("       Invite       ", for: .normal)
//        }
//        self.inviteBtn.togg
//        self.inviteBtn.isSelected = (userInfo.isFriendRequest ?? false)
        
        self.profilePicImgView.kf.indicatorType = .activity
         
        if let imgURL = Utils.getCompleteURL(urlString: userInfo.displayImageURL) {
            
            self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
        self.nameLbl.text = "\(userInfo.firstName?.capitalized ?? "") \(userInfo.lastName?.capitalized ?? "")"
    }
    
    func configureCell(userInfo: GetFriendListToInviteToCircleDM) {
        
        self.isVerifiedIcon.isHidden = !(userInfo.isAccountVerified ?? false)
        
        self.profilePicImgView.kf.indicatorType = .activity
         
        if let imgURL = Utils.getCompleteURL(urlString: userInfo.displayImageURL) {
            
            self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.nameLbl.text = userInfo.name?.capitalized
    }
    
}
