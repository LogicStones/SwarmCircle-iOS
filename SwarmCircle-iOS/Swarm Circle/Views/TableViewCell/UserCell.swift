//
//  UserCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/12/2022.
//

import UIKit

class UserCell: UITableViewCell {

    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var verifiedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ info: UserListPollOptionDM) {
        
        self.profileImgView.kf.indicatorType = .activity
         
        if let imgURL = Utils.getCompleteURL(urlString: info.displayImageURL) {
            self.profileImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.nameLbl.text = "\(info.firstName?.capitalized ?? "First name") \(info.lastName?.capitalized ?? "Last name")"
        
    }
    
    func configureCell(_ info: FriendDM) {
        
        self.verifiedIcon.isHidden = !(info.isAccountVerified ?? false)
        
        self.profileImgView.kf.indicatorType = .activity
         
        if let imgURL = Utils.getCompleteURL(urlString: info.displayImageURL) {
            self.profileImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.nameLbl.text = "\(info.name?.capitalized ?? "Full Name")"
        
    }
    
    func configureCell(_ info: ProfileCircle) {
        
        self.profileImgView.kf.indicatorType = .activity
         
        if let imgURL = Utils.getCompleteURL(urlString: info.displayImageURL) {
            self.profileImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.nameLbl.text = "\(info.circleName ?? "Circle Name")"
        
    }

    
}
