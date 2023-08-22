//
//  PostsHeaderView.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 17/10/2022.
//

import UIKit

class PostsHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    @IBOutlet weak var idLbl: UILabel!
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var createPostBtn: UIButton!
    @IBOutlet weak var clipboardBtn: UIButton!
    @IBOutlet weak var profilePicBtn: UIButton!
    
    func configureHeader() {
        
//        self.nameLbl.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
        
        self.nameLbl.text = PreferencesManager.getUserModel()?.firstName?.capitalized ?? ""
        
        self.isVerifiedIcon.isHidden = !(PreferencesManager.getUserModel()?.isAccountVerified ?? false)
        
        self.idLbl.text = PreferencesManager.getUserModel()?.userID ?? ""
        
        self.profilePicImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: PreferencesManager.getUserModel()?.displayImageURL) {
            self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
    }
}
