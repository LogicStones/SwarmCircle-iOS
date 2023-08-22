//
//  ViewProfileHeaderView.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 31/10/2022.
//

import UIKit

class ViewProfileHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var clipboardBtn: UIButton!
    @IBOutlet weak var profileImgView: CircleImage!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    @IBOutlet weak var userIdLbl: UILabel!
    @IBOutlet weak var facebookBtn: UIButton!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    @IBOutlet weak var youtubeBtn: UIButton!
    @IBOutlet weak var chatNowBtn: UIButton!
    @IBOutlet weak var chatNowBtnBackgroundView: UIView!
    @IBOutlet weak var removeFriendBtn: UIButton!
    @IBOutlet weak var removeFriendBtnBackgroundView: UIView!
    @IBOutlet weak var alreadyFriendStackView: UIStackView!
    @IBOutlet weak var alreadyFriendStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var friendRequestedStackView: UIStackView!
    @IBOutlet weak var friendRequestedStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var acceptFriendBtn: UIButton!
    @IBOutlet weak var rejectFriendBtn: UIButton!
    @IBOutlet weak var inviteBtn: ToggleButton!
    @IBOutlet weak var inviteBtnTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var inviteBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var phoneNoLbl: UILabel!
    @IBOutlet weak var phoneNoBtn: UIButton!
    @IBOutlet weak var circleCountLbl: UILabel!
    @IBOutlet weak var friendCountLbl: UILabel!
    @IBOutlet weak var inviteBtnHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var circleListBtn: UIButton!
    @IBOutlet weak var friendListBtn: UIButton!
    
    func configureHeader(info: ViewProfileDM) {
        
        self.hideNShowBtn(info: info)
        
        self.setupLinks(info: info)
        
        self.profileImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: info.displayImageURL) {
            self.profileImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImgView.image = UIImage(named: "defaultProfileImage")!
        }
        self.inviteBtn.isSelected = info.isFriendRequestSent ?? false
        self.userNameLbl.text = "\(info.firstName?.capitalized ?? "") \(info.lastName?.capitalized ?? "")"
        
        self.isVerifiedIcon.isHidden = !(info.isAccountVerified ?? false)
        
        self.userIdLbl.text = "SwarmCircle ID: \(info.uID ?? 0)"
        self.circleCountLbl.text = "\(info.circleMemberCount ?? 0)"
        self.friendCountLbl.text = "\(info.friendsCount ?? 0)"
        
        if info.isEmailVisible ?? false {
            self.emailLbl.text = info.email ?? "N/A"
            self.emailBtn.isEnabled = true
        } else {
            self.emailLbl.text = Utils.getSymbols(symbol: "*", count: 10)
            self.emailBtn.isEnabled = false
        }
        
        if info.isPhoneVisible ?? false {
            self.phoneNoLbl.text = info.phoneNo ?? "N/A"
            self.phoneNoBtn.isEnabled = true
        } else {
            self.phoneNoLbl.text = Utils.getSymbols(symbol: "*", count: 10)
            self.phoneNoBtn.isEnabled = false
        }
        
        if info.isFriendListVisible ?? false {
            self.friendListBtn.isEnabled = true
        } else {
            self.friendListBtn.isEnabled = false
        }
        
        if info.isCircleListVisible ?? false {
            self.circleListBtn.isEnabled = true
        } else {
            self.circleListBtn.isEnabled = false
        }
    }
    
    func setupLinks(info: ViewProfileDM) {
        
//        self.facebookBtn.isHidden = true // uncomment these later
//        self.instagramBtn.isHidden = true
//        self.youtubeBtn.isHidden = true
//        self.twitterBtn.isHidden = true
        
//        if let urlString = info.facebookLink {
//
////            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
//
//            if urlString.isValidURLString {
//                if let url = URL(string: urlString) {
//                    self.facebookBtn.isHidden = !UIApplication.shared.canOpenURL(url)
//                }
//            }
//        }
//
//        if let urlString = info.instagramLink {
//
////            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
//
//            if urlString.isValidURLString {
//                if let url = URL(string: urlString) {
//                    self.instagramBtn.isHidden = !UIApplication.shared.canOpenURL(url)
//                }
//            }
//        }
//
//
//        if let urlString = info.youtubeLink {
//
////            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
//
//            if urlString.isValidURLString {
//                if let url = URL(string: urlString) {
//                    self.youtubeBtn.isHidden = !UIApplication.shared.canOpenURL(url)
//                }
//            }
//        }
//
//        if let urlString = info.twitterLink {
//
////            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
//
//            if urlString.isValidURLString {
//                if let url = URL(string: urlString) {
//                    self.twitterBtn.isHidden = !UIApplication.shared.canOpenURL(url)
//                }
//            }
//        }
//
//        if self.facebookBtn.isHidden && self.instagramBtn.isHidden && self.youtubeBtn.isHidden && self.twitterBtn.isHidden {
//            self.inviteBtnTopConstraint.constant = 0
//            self.alreadyFriendStackViewTopConstraint.constant = 0
//            self.friendRequestedStackViewTopConstraint.constant = 0
//        }
        
        self.facebookBtn.isHidden = false
        self.instagramBtn.isHidden = false
        self.youtubeBtn.isHidden = false
        self.twitterBtn.isHidden = false
    }
    
    func isStringLink(string: String) -> Bool {
        let types: NSTextCheckingResult.CheckingType = [.link]
        let detector = try? NSDataDetector(types: types.rawValue)
        guard (detector != nil && string.count > 0) else { return false }
        if detector!.numberOfMatches(in: string, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, string.count)) > 0 {
            return true
        }
        return false
    }
    
    
    func hideNShowBtn(info: ViewProfileDM) {
        
        self.inviteBtn.isHidden = true
        self.alreadyFriendStackView.isHidden = true
        self.friendRequestedStackView.isHidden = true
        
        if info.isMyFriend ?? false {
            self.alreadyFriendStackView.isHidden = false
        }
        else if info.isFriendRequestRecieved ?? false {
            self.friendRequestedStackView.isHidden = false
        }
        else if info.identifier == PreferencesManager.getUserModel()?.identifier {
//            self.inviteBtn.isHidden = true
            self.inviteBtnTopConstraint.constant = 0
//            self.alreadyFriendStackView.isHidden = true
            self.alreadyFriendStackViewTopConstraint.constant = 0
//            self.friendRequestedStackView.isHidden = true
            self.friendRequestedStackViewTopConstraint.constant = 0
            self.acceptFriendBtn.isHidden = true
            self.rejectFriendBtn.isHidden = true
            self.chatNowBtn.isHidden = true
            self.removeFriendBtn.isHidden = true
            self.chatNowBtnBackgroundView.isHidden = true
            self.removeFriendBtnBackgroundView.isHidden = true
            self.inviteBtnBottomConstraint.constant = 5
            self.inviteBtnHeightConstraint.constant = 0
        }
        else { // info.isFriendRequestSent
            self.inviteBtn.isHidden = false
        }
        
    }
}
