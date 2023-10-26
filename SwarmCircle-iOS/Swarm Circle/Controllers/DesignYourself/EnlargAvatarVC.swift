//
//  EnlargAvatarVC.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 03/10/2023.
//

import UIKit

class EnlargAvatarVC: BaseViewController {

    @IBOutlet var imgAvatar: UIImageView!
    
    var avatarUrl:String = ""
    let viewModel = ViewModel()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initVariable()
        if let imgURL = URL(string: self.avatarUrl)
        {
            self.imgAvatar.kf.setImage(with: imgURL)
        }
        else
        {
            self.imgAvatar.image = UIImage(named: "defaultProfileImage")!
        }
    }

    func initVariable()
    {
        self.viewModel.delegateNetworkResponse = self
    }
    
    @IBAction func btnClose(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func btnSetAsDefault(_ sender: Any) {
        let params = [
            "URL": self.avatarUrl
        ] as! [String : Any]
        self.showLoader()
            self.viewModel.setAvatarProfilePicture(params: params)
    }
}
extension EnlargAvatarVC:NetworkResponseProtocols
{
    func didSetAvatarProfilePicture() {
        self.hideLoader()
        //self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        //self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.setAvatarProfilePictureResponse?.isSuccess ?? false {
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.setAvatarProfilePictureResponse?.message ?? "Some error occured") { result in
                if result {
                   //refresh profile picture
                    NotificationCenter.default.post(name: .refreshProfileImage, object: nil)
                    self.dismiss(animated: true)
                }
            }
        }
        else {
            self.showToast(message: self.viewModel.setAvatarProfilePictureResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}
