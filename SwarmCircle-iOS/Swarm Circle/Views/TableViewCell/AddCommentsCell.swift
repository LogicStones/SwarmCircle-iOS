//
//  AddCommentsCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 19/08/2022.
//

import UIKit

class AddCommentsCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var writeReplyBtn: UIButton!
    @IBOutlet weak var profilePicBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell() {
        self.profileImageView.kf.indicatorType = .activity
         
        if let imgURL = Utils.getCompleteURL(urlString: PreferencesManager.getUserModel()?.displayImageURL) {
            self.profileImageView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImageView.image = UIImage(named: "defaultProfileImage")!
        }
    }
    
}
