//
//  CirclesInfoCell.swift
//  Swarm Circle
//
//  Created by Macbook on 05/07/2022.
//

import UIKit

class CirclesInfoCell: UITableViewCell {
    
    @IBOutlet weak var membersCountLBL: UILabel!
    @IBOutlet weak var circleTitleLBL: UILabel!
    @IBOutlet weak var membersListStack: UIStackView!
    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet var memberImgView: [UIImageView]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(circleInfo: JoinedCircleDM) {
        
        self.circleTitleLBL.text = Utils.decodeUTF(circleInfo.circleName ?? "")
        self.membersCountLBL.text = "\(circleInfo.totalMember ?? 0) member\((circleInfo.totalMember ?? 0) < 2 ? "":"s")"
        
        self.iconImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: circleInfo.circleImageURL) {
            
            self.iconImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage")!)
        } else {
            self.iconImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        for (i, member) in memberImgView.enumerated() {
            
            member.kf.indicatorType = .activity
            
            if i < circleInfo.membersInfo?.count ?? 0 {
                
                if let imgURL = Utils.getCompleteURL(urlString: circleInfo.membersInfo?[i].displayImageURL) {
                    member.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage")!)
                    member.isHidden = false
                } else {
                    member.image = UIImage(named: "defaultProfileImage")!
                }
            } else {
                member.isHidden = true
            }
        }
    }
    
    func configureCell(circleInfo: PendingCircleInviteDM) {
        
        self.circleTitleLBL.text = Utils.decodeUTF(circleInfo.circleName ?? "")
        self.membersCountLBL.text = "\(circleInfo.totalMember ?? 0) member\((circleInfo.totalMember ?? 0) < 2 ? "":"s")" // members count not available in model
        
        if let imgURL = Utils.getCompleteURL(urlString: circleInfo.circleImageURL) {
            
            self.iconImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.iconImgView.image = UIImage(named: "defaultProfileImage")!
        }
        //        self.membersCountLBL.text = "\(circleInfo.totalMember ?? 0) members"
        //
        //        self.iconImgView.kf.indicatorType = .activity
        //
        //        if let imgURL = Utils.getImageURL(urlString: circleInfo.circleImageURL) {
        //
        //            self.iconImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage")!)
        //        } else {
        //            self.iconImgView.image = UIImage(named: "defaultProfileImage")!
        //        }
        //
        //        for (i, member) in memberImgView.enumerated() {
        //
        //            member.kf.indicatorType = .activity
        //
        //            if i < circleInfo.membersInfo?.count ?? 0 {
        //
        //                if let imgURL = Utils.getImageURL(urlString: circleInfo.membersInfo?[i].displayImageURL) {
        //                    member.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage")!)
        //                    member.isHidden = false
        //                } else {
        //                    member.image = UIImage(named: "defaultProfileImage")!
        //                }
        //            } else {
        //                member.isHidden = true
        //            }
    }
}
