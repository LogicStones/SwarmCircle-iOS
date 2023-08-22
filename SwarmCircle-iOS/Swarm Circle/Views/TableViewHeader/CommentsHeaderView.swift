//
//  CommentsHeaderView.swift
//  Swarm Circle
//
//  Created by Macbook on 19/08/2022.
//

import UIKit

class CommentsHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var connectionLine: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    @IBOutlet weak var commentLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var replyBtn: UIButton!
    @IBOutlet weak var commentTimeLbl: UILabel!
    @IBOutlet weak var likesCountLbl: UILabel!
    @IBOutlet weak var repliesCountBtn: LoadingButton!
    @IBOutlet weak var moreBtn: UIButton!
    @IBOutlet weak var profilePicBtn: UIButton!
    
    func configureHeader(info: ComRepDM) {
        
        self.isVerifiedIcon.isHidden = !(info.isAccountVerified ?? false)
        
        self.profileImageView.kf.indicatorType = .activity
         
        if let imgURL = Utils.getCompleteURL(urlString: info.displayImageURL) {
            self.profileImageView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImageView.image = UIImage(named: "defaultProfileImage")!
        }
    
        self.nameLbl.text = "\(info.firstName?.capitalized ?? "") \(info.lastName?.capitalized ?? "")"
        self.commentLbl.text = Utils.decodeUTF(info.comment ?? "")
        
        if let isLiked = info.isLiked {
            self.likeBtn.isSelected = isLiked
            
            if !isLiked {
                self.likeBtn.setImage(UIImage(named: "heartIcon"), for: [.disabled, .normal])
                self.likeBtn.setTitle(" Like", for: [.disabled, .normal])
                self.likeBtn.setTitleColor(UIColor.systemGray4, for: [.disabled, .normal])
            } else {
                self.likeBtn.setImage(UIImage(named: "heartFillIcon"), for: [.disabled, .selected])
                self.likeBtn.setTitle(" Like", for: [.disabled, .selected])
                self.likeBtn.setTitleColor(UIColor.systemGray4, for: [.disabled, .selected])
            }
        }
        
        self.likeBtn.isEnabled = info.isLikeBtnEnabled ?? true
        self.commentTimeLbl.text = info.durationAgo ?? ""
        self.likesCountLbl.text = "\(info.likeCount ?? 0) Likes"
        self.repliesCountBtn.setTitle("\(info.replyCount ?? 0) Replies", for: .normal)
        
        self.commentLbl.text?.removeNewLinesFromStartNEnd()
        self.commentLbl.text?.removeWhiteSpacesFromStartNEnd()
    }
}
