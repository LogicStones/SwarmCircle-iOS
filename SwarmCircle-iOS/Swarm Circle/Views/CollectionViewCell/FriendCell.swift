//
//  FriendCell.swift
//  Swarm Circle
//
//  Created by Macbook on 06/07/2022.
//

import UIKit

class FriendCell: UICollectionViewCell {
    
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var circleCountLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(userInfo: FriendDM) {
        self.nameLbl.text = userInfo.name
        
        self.isVerifiedIcon.isHidden = !(userInfo.isAccountVerified ?? false)
        
        self.circleCountLbl.text = "\(userInfo.circleCount ?? 0) Circle\((userInfo.circleCount ?? 0) < 2 ? "":"s")"
        
        if let imgURL = Utils.getCompleteURL(urlString: userInfo.displayImageURL) {
            
            self.iconImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.iconImgView.image = UIImage(named: "defaultProfileImage")!
        }
    }
    
    func configureCell(userInfo: PendingCircleJoinDM) {
        
        self.nameLbl.text = userInfo.name
        
        self.circleCountLbl.text = "\(userInfo.circleCount ?? 0) Circle\((userInfo.circleCount ?? 0) < 2 ? "":"s")"
        
        if let imgURL = Utils.getCompleteURL(urlString: userInfo.displayImageURL) {
            
            self.iconImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.iconImgView.image = UIImage(named: "defaultProfileImage")!
        }
    }
    
    func configureCell(userInfo: PendingUserDM) {
        
        self.isVerifiedIcon.isHidden = !(userInfo.isAccountVerified ?? false)
        
        self.nameLbl.text = userInfo.name
        
        self.circleCountLbl.text = "\(userInfo.circleCount ?? 0) Circle\((userInfo.circleCount ?? 0) < 2 ? "":"s")"
        
        if let imgURL = Utils.getCompleteURL(urlString: userInfo.displayImageURL) {
            
            self.iconImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.iconImgView.image = UIImage(named: "defaultProfileImage")!
        }
    }
}
