//
//  CommentsCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 18/08/2022.
//

import UIKit

class CommentsCell: UITableViewCell {

    @IBOutlet private weak var connectionLineView: UIView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var commentTimeLbl: UILabel!
    @IBOutlet weak var likesCountLbl: UILabel!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var profilePicBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(info: ComRepDM) {
        
        self.isVerifiedIcon.isHidden = !(info.isAccountVerified ?? false)
        
        self.profileImageView.kf.indicatorType = .activity
         
        if let imgURL = Utils.getCompleteURL(urlString: info.displayImageURL) {
            self.profileImageView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImageView.image = UIImage(named: "defaultProfileImage")!
        }
    
        self.nameLbl.text = "\(info.firstName?.capitalized ?? "") \(info.lastName?.capitalized ?? "")"
        self.commentLbl.text =   Utils.decodeUTF(info.comment ?? "")
        
        if let isLiked = info.isLiked {
            self.likeBtn.isSelected = isLiked
            
            if !isLiked {
                self.likeBtn.setImage(UIImage(named: "heartIcon"), for: [.disabled, .normal])
                self.likeBtn.setTitle(" Like", for: [.disabled, .normal])
                self.likeBtn.setTitleColor(UIColor.systemGray4, for: [.normal, .disabled])
            } else {
                self.likeBtn.setImage(UIImage(named: "heartFillIcon"), for: [.disabled, .selected])
                self.likeBtn.setTitle(" Like", for: [.disabled, .selected])
                self.likeBtn.setTitleColor(UIColor.systemGray4, for: [.disabled, .selected])
            }
        }
        
        self.likeBtn.isEnabled = info.isLikeBtnEnabled ?? true
        self.commentTimeLbl.text = info.durationAgo ?? ""
        self.likesCountLbl.text = "\(info.likeCount ?? 0) Likes"
        
        self.commentLbl.text?.removeNewLinesFromStartNEnd()
        self.commentLbl.text?.removeWhiteSpacesFromStartNEnd()
    }
    
    func hideLine(_ shouldHideLine: Bool = false) {
        self.connectionLineView.isHidden = !shouldHideLine
    }
    
}
