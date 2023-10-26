//
//  AvatarListVC.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 01/10/2023.
//

import UIKit
import Alamofire

class AvatarListVC: BaseViewController
{
    @IBOutlet var lblTotalAvatar: UILabel!
    @IBOutlet var cltAvatar: UICollectionView!
    
    var arrGallary:[AvatarGallaryDM] = []
    let viewModel = ViewModel()
    var alamoFireManager : Session?
    
    let inset: CGFloat = 10
    let minimumLineSpacing: CGFloat = 10
    let minimumInteritemSpacing: CGFloat = 10
    let cellsPerRow = 2
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initVariable()
        self.cltAvatar.dataSource = self
        self.cltAvatar.delegate = self
        self.cltAvatar.layoutSubviews()
        self.cltAvatar.contentInsetAdjustmentBehavior = .always
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshAvatarList), name: .refreshAvatarSubscription, object: nil)
    }
    
    @objc private func refreshAvatarList()
    {
        self.getAvatarData()
    }
    
    func initVariable()
    {
        self.viewModel.delegateNetworkResponse = self
        self.getAvatarData()
    }
    
    func getAvatarData()
    {
        self.showLoader()
        self.viewModel.getAvatarGalleryList()
    }
    
    @IBAction func btnCreateAvatar(_ sender: Any) {
        self.showLoader()
        self.viewModel.getAvatarMonthlyRemainingLimit()
    }
}

extension AvatarListVC:UICollectionViewDataSource,UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.arrGallary.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = self.cltAvatar.dequeueReusableCell(withReuseIdentifier: "AvatarGallaryCell", for: indexPath) as! AvatarGallaryCell
        let gallry = self.arrGallary[indexPath.row]
        
        if let imgURL = URL(string: gallry.url ?? "")
        {
            cell.imgAvatar.kf.setImage(with: imgURL)
        }
        else
        {
            cell.imgAvatar.image = UIImage(named: "defaultProfileImage")!
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return minimumLineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return minimumInteritemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let marginsAndInsets = inset * 2 + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerRow - 1)
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerRow)).rounded(.down)
        print(itemWidth)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = AppStoryboard.DesignYourself.instance.instantiateViewController(withIdentifier: "EnlargAvatarVC") as? EnlargAvatarVC
        {
            vc.avatarUrl = self.arrGallary[indexPath.row].url ?? ""
            self.present(vc, animated: true)
        }
    }
}
extension AvatarListVC:NetworkResponseProtocols
{
    func didGetAvatarGalleryList()
    {
        self.hideLoader()
        
        if self.viewModel.getAvatarGalleryListResponse?.isSuccess ?? false {
            if let unwrappedList = self.viewModel.getAvatarGalleryListResponse?.data
            {
                self.arrGallary = unwrappedList
                self.lblTotalAvatar.text = "Total No. of Avatar: \(self.arrGallary.count)"
                self.cltAvatar.reloadData()
                // self.cltAvatar!.collectionViewLayout.invalidateLayout()
                // self.cltAvatar!.layoutSubviews()
            }
        }
        else {
            self.showToast(message: self.viewModel.getAvatarGalleryListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    func didGetAvatarMonthlyRemainingLimit() {
        self.hideLoader()
        
        if self.viewModel.getAvatarGalleryListResponse?.isSuccess ?? false {
            if let remainLimit = self.viewModel.getAvatarMonthlyRemainingLimitResponse?.data
            {
                print(remainLimit)
                if remainLimit > 0
                {
                    ImagePickerManager().pickImage(self) { image in
                        //here call mirror ai
                        self.createAvatarFrmMirror(img: image)
                    }
                }
                else
                {
                    self.showToast(message: "Your limit exceeded", delay: 2, toastType: .red)
                }
            }
            else {
                self.showToast(message: self.viewModel.getAvatarMonthlyRemainingLimitResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            }
        }
    }
    
    @objc private func createAvatarFrmMirror(img:UIImage)
    {
        self.showLoader()
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 100
        configuration.timeoutIntervalForResource = 100
        
        alamoFireManager = Alamofire.Session(configuration: configuration)
        alamoFireManager!.upload(multipartFormData: { multipartFormData in
            
            let photo = img.jpegData(compressionQuality: 0.3)!
            multipartFormData.append(photo, withName: "photo",fileName: "photo.jpg", mimeType: "image/jpeg")
        },
                                 to: "https://public-api.mirror-ai.net/v2/generate?style=kenga", usingThreshold: UInt64.init(), method: .post, headers:[
                                    "accept": "application/json",
                                    "X-Token": "e7ceeeb56784412a8c58c5e6e5e52349",
                                    "Content-Type": "multipart/form-data"
                                 ]).response(completionHandler: { response in
                                     switch response.result {
                                     case .success(_):
                                         do {
                                             print(response)
                                             if response.data != nil
                                             {
                                                 let json = try JSONSerialization.jsonObject(with: response.data!) as! [String: Any]
                                                 if let error = json["ok"] as? Bool, !error
                                                 {
                                                     self.showToast(message: "Something wrong! try again later.", delay: 2, toastType: .red)
                                                 }
                                                 else
                                                 {
                                                     if let face = json["face"] as? [String:Any], let id = face["id"] as? String, let version = face["version"] as? String, let url = face["url"] as? String
                                                     {
                                                         let params = [
                                                            "id": id,
                                                            "version": version,
                                                            "url":url
                                                         ] as [String : Any]
                                                         self.viewModel.saveMirrorAiAvatar(params: params)
                                                     }
                                                 }
                                             }
                                         }catch{}
                                         break
                                     case .failure(let encodingError):
                                         self.showToast(message: encodingError.localizedDescription, delay: 2, toastType: .red)
                                     }
                                 })
    }
    
    func didSaveMirrorAiAvatar()
    {
        
        self.hideLoader()
        
        if self.viewModel.saveMirrorAiAvatarResponse?.isSuccess ?? false {
            self.getAvatarData()
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.saveMirrorAiAvatarResponse?.message ?? "Some error occured") { result in
            }
        }
        else {
            self.showToast(message: self.viewModel.saveMirrorAiAvatarResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}

