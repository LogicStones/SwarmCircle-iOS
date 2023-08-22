//
//  GroupAVCallingCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 05/12/2022.
//

import UIKit
import OpenTok

class GroupAVCallingCell: UICollectionViewCell {
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var profileImgView: UIImageView!
    @IBOutlet weak var microphoneBtn: UIButton!
    @IBOutlet weak var userNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.profileImgView.backgroundColor = UIColor.red
    }
    
    func configureCell(subscriber: (subscriber: OTSubscriber, isMuted: Bool)) {
        
        if let subView = subscriber.subscriber.view {
            
            if subscriber.subscriber.stream?.hasVideo ?? false {
            
                subView.isHidden = false
                
                subView.frame = CGRect(x: 0, y: 0, width: self.videoPlayerView.frame.width, height: self.videoPlayerView.frame.height)
                
                self.videoPlayerView.addSubview(subView)
                self.videoPlayerView.sendSubviewToBack(subView)
                self.videoPlayerView.sendSubviewToBack(self.userNameLbl)
                self.videoPlayerView.sendSubviewToBack(self.profileImgView)
                
                subView.widthAnchor.constraint(equalTo: self.videoPlayerView.widthAnchor).isActive = true
                subView.heightAnchor.constraint(equalTo: self.videoPlayerView.heightAnchor).isActive = true
                
            } else {
                subView.isHidden = true
            }
        }
        
        self.microphoneBtn.isSelected = subscriber.isMuted

        self.profileImgView.isHidden = subscriber.subscriber.stream?.hasVideo ?? false
        
        if let array = subscriber.subscriber.stream?.name?.split(separator: ",") {
            
            if array.count >= 2 {
                
                self.userNameLbl.text = String(array[0])
                
                self.profileImgView.kf.indicatorType = .activity
                 
                if let imgURL = Utils.getCompleteURL(urlString: String(array[1])) {
                    self.profileImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
                } else {
                    self.profileImgView.image = UIImage(named: "defaultProfileImage")!
                }
            }
        }
    }

}
