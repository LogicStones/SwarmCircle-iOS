//
//  FeedsCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 15/08/2022.
//

import UIKit
import ActiveLabel

class FeedsTextCell: UITableViewCell {
    
    @IBOutlet weak var profileImgView: CircleImage!
    @IBOutlet weak var nameLbl: ActiveLabel!
    @IBOutlet weak var postTimeLbl: UILabel!
    @IBOutlet weak var feedTextLbl: ActiveLabel!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var cmtBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var cmtCountLbl: UILabel!
    @IBOutlet weak var likesBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var readBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var profilePicBtn: UIButton!
    @IBOutlet weak var privacyIcon: UIImageView!
    
    var navigationController: UINavigationController?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Configure Cell
    func configureCell(info: PostDM) {
        
        self.nameLbl.numberOfLines = 0
        
        let completeText = NSMutableAttributedString(string: "\(self.getPostCreatorFullName(info: info)) ")
        
        if info.isAccountVerified ?? false { // if user is verified
            
//            let imageAttachment = NSTextAttachment()
//            imageAttachment.image = UIImage(named:"verifiedIcon")
//            let imageOffsetY: CGFloat = -5.0
//            imageAttachment.bounds = CGRect(x: 0, y: imageOffsetY, width: imageAttachment.image!.size.width, height: imageAttachment.image!.size.height)
//            // Create string with attachment
//            let attachmentString = NSAttributedString(attachment: imageAttachment)
//            completeText.append(attachmentString)
            completeText.append(NSAttributedString(attachment: NSTextAttachment(image: UIImage(named:"verifiedIcon")!)))
        }
        
        if info.taggedFriends != nil {

            if info.taggedFriends!.count > 0 {

                let poster = ActiveType.custom(pattern: "\\s\(self.getPostCreatorFullName(info: info))\\b") // Looks for "are"
                let with = ActiveType.custom(pattern: "\\s- with\\b") // Looks for "are"
                let firstTaggedPerson = ActiveType.custom(pattern: "\\s\(info.taggedFriends?.first?.name?.capitalized ?? "")\\b") // Looks for "are"
                let and = ActiveType.custom(pattern: "\\sand\\b") // Looks for "are"
                let otherTaggedPersons = ActiveType.custom(pattern: "\\s\(info.taggedFriends!.count - 1) Other\(info.taggedFriends!.count - 1 > 1 ? "s":"")\\b") // Looks for "are"

                self.nameLbl.enabledTypes.append(poster)
                self.nameLbl.enabledTypes.append(firstTaggedPerson)
                self.nameLbl.enabledTypes.append(with)

                completeText.append(NSAttributedString(string: " - with \(info.taggedFriends?.first?.name?.capitalized ?? "")"))

                if info.taggedFriends?.first?.isAccountVerified ?? false {
//                    completeText.append(NSAttributedString(attachment: NSTextAttachment(image: UIImage(named:"verifiedIcon")!)))
                }

                if info.taggedFriends!.count > 1 {
                    self.nameLbl.enabledTypes.append(otherTaggedPersons)
                    self.nameLbl.enabledTypes.append(and)

                    completeText.append(NSAttributedString(string: " and \(info.taggedFriends!.count - 1) Other\(info.taggedFriends!.count - 1 > 1 ? "s":"")"))
                }

                self.nameLbl.customize { label in
                    
                    label.configureLinkAttribute = { (type, attributes, isSelected) in
                        var atts = attributes
                        switch type {
                        case poster:
                            atts[NSAttributedString.Key.font] = UIFont(name: "Gilroy-Medium", size: 16)
                        case with, and:
                            atts[NSAttributedString.Key.font] = UIFont(name: "Gilroy-Regular", size: 16)
                            atts[NSAttributedString.Key.foregroundColor] = UIColor(hexString: "565656")
                        case firstTaggedPerson:
                            atts[NSAttributedString.Key.font] = isSelected ? UIFont(name: "Gilroy-Medium", size: 16.25) : UIFont(name: "Gilroy-Medium", size: 16)
                        case otherTaggedPersons:
                            atts[NSAttributedString.Key.font] = isSelected ? UIFont(name: "Gilroy-Medium", size: 16.25) : UIFont(name: "Gilroy-Medium", size: 16)
                            
                        default:
                            print("Do nothing")
                        }
                        
                        return atts
                    }
                    
                    label.handleCustomTap(for: firstTaggedPerson) { text in
                        
                        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
                            
                            vc.profileIdentifier = info.taggedFriends?.first?.identifier
                            
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                        
                    }
                    
                    label.handleCustomTap(for: otherTaggedPersons) { text in
                        
                        if let vc = AppStoryboard.Posts.instance.instantiateViewController(withIdentifier: "ListVC") as? ListVC {
                            
                            vc.friendList = info.taggedFriends!
                            
                            vc.listType = .taggedList
                            
                            let navigationController = UINavigationController(rootViewController: vc)
                            navigationController.modalPresentationStyle = .overFullScreen
                            navigationController.modalTransitionStyle = .crossDissolve
                            
                            UIApplication.getTopController()?.present(navigationController, animated: true)
                        }
                    }
                }
            }
        }
        
        self.nameLbl.attributedText = completeText
        
        self.feedTextLbl.handleHashtagTap { hashtag in
            
            if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "HashtagPostsVC") as? HashtagPostsVC {
                
                vc.hashtag = hashtag
                
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        
        //        Friends = 1
        //        Public = 2,
        //        ShareWith = 3,
        //        ShareWithExcept = 4
        
        if info.privacy == 1 { // Friends = 1
            self.privacyIcon.image = UIImage(named: "friendOnlyIcon")
        } else if info.privacy == 2 { // Public = 2
            self.privacyIcon.image = UIImage(named: "publicIcon")
        } else { // ShareWith = 3, ShareWithExcept = 4
            self.privacyIcon.image = UIImage()
        }
        
        self.feedTextLbl.numberOfLines = info.isContentExpanded ?? false ? 0 : 3
        
        self.feedTextLbl.text = Utils.decodeUTF(info.content ?? "")
        self.feedTextLbl.text?.removeNewLinesFromStartNEnd()
        self.feedTextLbl.text?.removeWhiteSpacesFromStartNEnd()
        
        self.readBtn.isHidden = true
        
        self.readBtn.isHidden = !self.feedTextLbl.isTruncated && (info.isContentExpanded ?? false) == false // Check if text is truncated, and content is not expanded to hide/show read button.
        
        self.readBtn.isSelected = info.isContentExpanded ?? false
        
        if let imgURL = Utils.getCompleteURL(urlString: PreferencesManager.getUserModel()?.identifier == info.userIdentifier ? PreferencesManager.getUserModel()?.displayImageURL : info.displayImageURL) {
            self.profileImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profileImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.postTimeLbl.text = info.durationAgo ?? ""
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
        
        self.likeCountLbl.text = "\(info.likeCount ?? 0) Likes"
        self.cmtCountLbl.text = "\(info.commentCount ?? 0) Comments"
    }
    
    func getPostCreatorFullName(info: PostDM) -> String {
        return PreferencesManager.getUserModel()?.identifier == info.userIdentifier ? "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")" : "\(info.firstName?.capitalized ?? "") \(info.lastName?.capitalized ?? "")"
    }
}
extension UILabel {
    var mutableAttributedString: NSMutableAttributedString? {
        let attributedString: NSMutableAttributedString
        if let labelattributedText = self.attributedText {
            attributedString = NSMutableAttributedString(attributedString: labelattributedText)
        } else {
            guard let labelText = self.text else { return nil }
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = self.textAlignment
            attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                          value: paragraphStyle,
                                          range: NSRange(location: 0, length: attributedString.length))
        }
        return attributedString
    }

    func addImage(_ image: UIImage, toEndWith height: CGFloat) {
        let fullAttributedString = mutableAttributedString
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image

        let yImage = (font.capHeight - height).rounded() / 2
        let ratio = image.size.width / image.size.height
        imageAttachment.bounds = CGRect(x: 0, y: yImage, width: ratio * height, height: height)
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        fullAttributedString?.append(imageString)
        attributedText = fullAttributedString
    }
    
    func addImage(_ image: UIImage, toStartWith height: CGFloat) {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = image

        let yImage = (font.capHeight - height).rounded() / 2
        let ratio = image.size.width / image.size.height
        imageAttachment.bounds = CGRect(x: 0, y: yImage, width: ratio * height, height: height)
        
        let fullAttributed = NSMutableAttributedString(attachment: imageAttachment)
        if let rawAttributed = mutableAttributedString {
            fullAttributed.append(rawAttributed)
        }
        attributedText = fullAttributed
    }
}
