//
//  FriendsListCell.swift
//  Swarm Circle
//
//  Created by Macbook on 05/07/2022.
//

import UIKit

class FriendsListCell: UITableViewCell {

    @IBOutlet weak var radioIcon: UIButton!
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var onlineStatusView: UIView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var busyLbl: UILabel!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var busyOnCallLbl: UILabel!
    @IBOutlet weak var radioBtnRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.radioIcon.isSelected = selected
    }

    
    func configureCell(userInfo: FriendDM, isSelected: Bool) {
        
        self.verifiedIcon.isHidden = !(userInfo.isAccountVerified ?? false)
        
        DispatchQueue.main.async {
            self.nameLBL.text = userInfo.name?.capitalized ?? ""
//            self.setSelected(isSelected, animated: true)
            print(isSelected)
            if let imgURL = Utils.getCompleteURL(urlString: userInfo.displayImageURL) {
                self.profileImage.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
            } else {
                self.profileImage.image = UIImage(named: "defaultProfileImage")!
            }
        }
       
    }
    
    func configureCell(userInfo: CircleMembersByCircleIdDM) {
        DispatchQueue.main.async {
            self.nameLBL.text = userInfo.name?.capitalized ?? ""
//            self.setSelected(isSelected, animated: true)

            if let imgURL = Utils.getCompleteURL(urlString: userInfo.displayImageURL) {
                self.profileImage.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
            } else {
                self.profileImage.image = UIImage(named: "defaultProfileImage")!
            }
        }
    }
    
    func configureCell(_ info: FriendDM) {
        
        self.verifiedIcon.isHidden = !(info.isAccountVerified ?? false)
        
        let friend = info
        
        self.nameLBL.text = friend.name?.capitalized ?? ""
        
        if let imgURL = Utils.getCompleteURL(urlString: friend.displayImageURL) {
            self.profileImage.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImage.image = UIImage(named: "defaultProfileImage")!
        }
    }
    
    func configureCell(_ info: CircleMemberDM, hideSelectionIcon: Bool = false) {
        
        self.verifiedIcon.isHidden = !(info.isAccountVerified ?? false)
        
        let member = info
        
        self.nameLBL.text = member.name?.capitalized ?? ""
        
        if let imgURL = Utils.getCompleteURL(urlString: member.displayImageURL) {
            self.profileImage.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImage.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.radioIcon.isHidden = member.IsInCall ?? false
        self.busyOnCallLbl.isHidden = !(member.IsInCall ?? false)
        
        self.radioIcon.isHidden = hideSelectionIcon
    }
    
}
