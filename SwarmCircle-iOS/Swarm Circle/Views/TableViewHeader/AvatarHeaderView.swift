//
//  AvatarHeaderView.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 31/10/2022.
//

import UIKit

class AvatarHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var hairPropImgView: UIImageView!
    @IBOutlet weak var glassesPropImgView: UIImageView!
    @IBOutlet weak var skinPropImgView: UIImageView!
    @IBOutlet weak var shirtPropImgView: UIImageView!
    @IBOutlet weak var pantPropImgView: UIImageView!
    @IBOutlet weak var shoesPropImgView: UIImageView!
    
    func configureHeader(avatar: AvatarDM) {
        
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: avatar.propHair) {
            self.hairPropImgView.kf.setImage(with: imgURL)
        } else {
            self.hairPropImgView.image = UIImage() // UIImage(named: "defaultProfileImage")!
        }
        
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: avatar.propGlasses) {
            self.glassesPropImgView.kf.setImage(with: imgURL)
        } else {
            self.glassesPropImgView.image = UIImage() // UIImage(named: "defaultProfileImage")!
        }
        
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: avatar.propSkin) {
            self.skinPropImgView.kf.setImage(with: imgURL)
        } else {
            self.skinPropImgView.image = UIImage() // UIImage(named: "defaultProfileImage")!
        }
        
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: avatar.propShirt) {
            self.shirtPropImgView.kf.setImage(with: imgURL)
        } else {
            self.shirtPropImgView.image = UIImage() // UIImage(named: "defaultProfileImage")!
        }
        
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: avatar.propPants) {
            self.pantPropImgView.kf.setImage(with: imgURL)
        } else {
            self.pantPropImgView.image = UIImage() // UIImage(named: "defaultProfileImage")!
        }
        
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: avatar.propShoes) {
            self.shoesPropImgView.kf.setImage(with: imgURL)
        } else {
            self.shoesPropImgView.image = UIImage() // UIImage(named: "defaultProfileImage")!
        }
    }
}
