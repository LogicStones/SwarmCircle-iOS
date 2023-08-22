//
//  AvatarPropCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/11/2022.
//

import UIKit

class AvatarPropCell: UICollectionViewCell {
    
    @IBOutlet weak var propImgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                self.borderColor = UIColor(named: "BackgroundColor")
                self.borderWidth = 1
            }
            else {
                self.borderColor = UIColor.clear
                self.borderWidth = 0
            }
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.cornerRadius = self.frame.height / 2
        self.propImgView.cornerRadius = self.propImgView.frame.height / 2
    }
    
    func configureCell(info: AvatarPropsDM) {
        
        self.backgroundColor = UIColor.systemGray6
        self.propImgView.image = UIImage()
        self.propImgView.backgroundColor = .clear
        
        if info.propname == "Glasses" && info.id == 0 {
            return
        }
        
        if info.propname == "Skin" {
            
            self.propImgView.cornerRadius = self.propImgView.frame.height / 2
            
            if info.id == 1 || info.id == 3 {
                self.propImgView.backgroundColor = UIColor(hexString: "#E1CBBF")
            }
            else if info.id == 2 || info.id == 4 {
                self.propImgView.backgroundColor = UIColor(hexString: "#A4745B")
            }
            return
        }
        
        self.propImgView.cornerRadius = 0
        
        self.propImgView.kf.indicatorType = .activity
        
    
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: info.propLink) {
            self.propImgView.kf.setImage(with: imgURL)
        } else {
            self.propImgView.image = UIImage(named: "defaultProfileImage")!
        }
    }
}
