//
//  EditAvatarVC.swift
//  Swarm Circle
//
//  Created by Macbook on 20/07/2022.
//

import UIKit

class EditAvatarVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var hairPropImgView: UIImageView!
    @IBOutlet weak var glassesPropImgView: UIImageView!
    @IBOutlet weak var skinPropImgView: UIImageView!
    @IBOutlet weak var shirtPropImgView: UIImageView!
    @IBOutlet weak var pantPropImgView: UIImageView!
    @IBOutlet weak var shoesPropImgView: UIImageView!
    
    var customizationList = [
        (UIImage(named: "skinColor"), "Skin Color"),
        (UIImage(named: "hairstyle"), "Hair Style"),
        (UIImage(named: "jeansIcon"), "Jeans"),
        (UIImage(named: "shirt"), "Outfits"),
        (UIImage(named: "shoe"), "Shoes"),
        (UIImage(named: "sunglasses"), "Eye Glasses")
    ]
    
    var currentAvatar: AvatarDM?
    
    var propList: [AvatarPropsDM] = []
    var filteredPropList: [AvatarPropsDM] = []
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        if self.currentAvatar?.genderName == "Female" {
            self.customizationList[1].0 = UIImage(named: "girlHairIcon")
        }
        
        self.tableView.register(UINib(nibName: "EditAvatarOptionsCell", bundle: nil), forCellReuseIdentifier: "EditAvatarOptionsCell")
        self.collectionView.register(UINib(nibName: "AvatarPropCell", bundle: nil), forCellWithReuseIdentifier: "AvatarPropCell")
        self.collectionView.contentInset = .init(top: 0, left: 0, bottom: 0, right: 10)
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.showsVerticalScrollIndicator = true
        self.collectionView.bounces = false
        
        self.hairPropImgView.kf.indicatorType = .activity
        self.glassesPropImgView.kf.indicatorType = .activity
        self.skinPropImgView.kf.indicatorType = .activity
        self.shirtPropImgView.kf.indicatorType = .activity
        self.pantPropImgView.kf.indicatorType = .activity
        self.shoesPropImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: self.currentAvatar?.propHair) {
            self.hairPropImgView.kf.setImage(with: imgURL)
        }
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: self.currentAvatar?.propGlasses) {
            self.glassesPropImgView.kf.setImage(with: imgURL)
        }
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: self.currentAvatar?.propSkin) {
            self.skinPropImgView.kf.setImage(with: imgURL)
        }
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: self.currentAvatar?.propShirt) {
            self.shirtPropImgView.kf.setImage(with: imgURL)
        }
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: self.currentAvatar?.propPants) {
            self.pantPropImgView.kf.setImage(with: imgURL)
        }
        if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: self.currentAvatar?.propShoes) {
            self.shoesPropImgView.kf.setImage(with: imgURL)
        }
    }
    
    // MARK: - Load data from API
    func initVariable() {
        
        guard let _ = self.currentAvatar else {
            popOnErrorAlert("Current Avatar was not Fetched")
            return
        }
        
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.getAvatarPropList()
    }
    
    // MARK: - Fetch Avatar Prop List
    func getAvatarPropList() {
        self.viewModel.getAvatarPropsByGenderList()
    }
    
    // MARK: - Save Avatar
    func saveAvatar() {
        
        let params: [String: Any] =
        [
            "genderID": 1,
            "userID": self.currentAvatar!.userID!,
            "skinID": self.currentAvatar!.skin!,
            "hairID": self.currentAvatar!.hair!,
            "shoesID": self.currentAvatar!.shoes!,
            "pantsID": self.currentAvatar!.pants!,
            "shirtID": self.currentAvatar!.shirt!,
            "glassesID": self.currentAvatar!.glasses!
        ]
        
        self.showLoader()
        
        self.viewModel.saveUserAvatar(params: params)
    }
    
    // MARK: - Save Avatar Button Tapped
    @IBAction func saveChangesBtnTapped(_ sender: UIButton) {
        self.saveAvatar()
    }
}

// MARK: - TableView Configuration
extension EditAvatarVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.customizationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditAvatarOptionsCell") as? EditAvatarOptionsCell else {
            return UITableViewCell()
        }
        cell.configureCell(fImage: self.customizationList[indexPath.row].0!, featureName: self.customizationList[indexPath.row].1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.filteredPropList = []
        
        let selectedPropType = self.customizationList[indexPath.row].1
        
        switch selectedPropType {
            
        case "Skin Color":
            self.filteredPropList = self.propList.filter { $0.propname == "Skin" }
        case "Hair Style":
            self.filteredPropList = self.propList.filter { $0.propname == "Hair" }
        case "Jeans":
            self.filteredPropList = self.propList.filter { $0.propname == "Pants" }
            
            if self.currentAvatar!.skin == 2 || self.currentAvatar!.skin == 4 {
                self.filteredPropList = self.filteredPropList.filter { $0.propLink!.contains("dark") || $0.color == 3 }
            }
            else if self.currentAvatar!.skin == 1 || self.currentAvatar!.skin == 3 {
                self.filteredPropList = self.filteredPropList.filter { !($0.propLink!.contains("dark")) || $0.color == 3 }
            }
        case "Outfits":
            self.filteredPropList = self.propList.filter { $0.propname == "Shirt" }
        case "Shoes":
            self.filteredPropList = self.propList.filter { $0.propname == "Shoes" }
        case "Eye Glasses":
            self.filteredPropList = self.propList.filter { $0.propname == "Glasses" }
            self.filteredPropList.append(AvatarPropsDM(propname: "Glasses", id: 0, genderID: nil, propType: 6, propLink: nil, propLinkApp: "avatar-mobile/boy/shirts/thumbs/6.png", genderName: "Male", color: nil))
        default:
            self.filteredPropList = []
        }
        
        self.collectionView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.collectionView.flashScrollIndicators()
        }
    }
    
    //    func switchPantsNSetId() {
    //
    //        var indexArrayBlack: [Int] = []
    //        var indexArrayWhite: [Int] = []
    //
    //        for i in stride(from: 0, to: self.propList.count, by: 1) {
    //
    //            if self.propList[i].propname == "Pants" {
    //                if self.currentAvatar!.skin == 2 || self.currentAvatar!.skin == 4 { // switching towards.. white
    //
    //                    if self.propList[i].color == 2  {
    //                        indexArrayBlack.append(i)
    //                    }
    //                }
    //                else if self.currentAvatar!.skin == 1 || self.currentAvatar!.skin == 3 { // switching towards.. black
    //
    //                    if self.propList[i].color == 1 {
    //                        indexArrayWhite.append(i)
    //                    }
    //                }
    //            }
    //        }
    //
    //        for index in indexArrayBlack { // switching towards.. white
    //            let link = self.propList[index].propLinkApp!.replacingOccurrences(of: "-dark.", with: ".")
    //
    //            if self.propList[index].propLinkApp == self.currentAvatar!.propPants {
    //
    //                if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: link) {
    //                    self.pantPropImgView.kf.setImage(with: imgURL)
    //                }
    //
    //                for prop in propList {
    //                    if link == prop.propLinkApp {
    //                        self.currentAvatar!.pants = prop.id
    //                        break
    //                    }
    //                }
    //
    //                self.currentAvatar!.propPants = link
    //                break
    //            }
    //        }
    //
    //        for index in indexArrayWhite { // switching towards.. black
    //            let link = self.propList[index].propLinkApp!.replacingOccurrences(of: ".", with: "-dark.")
    //
    //            if self.propList[index].propLinkApp == self.currentAvatar!.propPants {
    //
    //                if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: link) {
    //                    self.pantPropImgView.kf.setImage(with: imgURL)
    //                }
    //
    //                for prop in propList {
    //                    if link == prop.propLinkApp {
    //                        self.currentAvatar!.pants = prop.id
    //                        break
    //                    }
    //                }
    //
    //                self.currentAvatar!.propPants = link
    //                break
    //            }
    //        }
    //    }
    
    func switchAvatarAfterSKinChange() {
        
        var newPropPantsLink = ""
        
        if self.currentAvatar!.skin == 2 || self.currentAvatar!.skin == 4 {
            newPropPantsLink = self.currentAvatar!.propPants!.replacingOccurrences(of: ".", with: "-dark.")
        }
        else if self.currentAvatar!.skin == 1 || self.currentAvatar!.skin == 3 {
            newPropPantsLink = self.currentAvatar!.propPants!.replacingOccurrences(of: "-dark.", with: ".")
        }
        
        var isFound = false
        
        for prop in propList {
            if newPropPantsLink == prop.propLinkApp {
                self.currentAvatar!.pants = prop.id
                isFound = true
                break
            }
        }
        
        if isFound {
            self.currentAvatar!.propPants = newPropPantsLink
            if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: newPropPantsLink) {
                self.pantPropImgView.kf.setImage(with: imgURL)
            }
        }
        else {
            newPropPantsLink = self.currentAvatar!.propPants!.replacingOccurrences(of: "-dark.", with: ".")
            self.currentAvatar!.propPants = newPropPantsLink
            if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: newPropPantsLink) {
                self.pantPropImgView.kf.setImage(with: imgURL)
            }
        }
    }
}

// MARK: - TableView Configuration
extension EditAvatarVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredPropList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarPropCell", for: indexPath) as? AvatarPropCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(info: self.filteredPropList[indexPath.row])
        
        if let selectedPropTypeIndex = self.tableView.indexPathForSelectedRow {
            
            let selectedPropType = self.customizationList[selectedPropTypeIndex.row].1
            
            switch selectedPropType {
                
            case "Skin Color":
                if self.filteredPropList[indexPath.row].id == self.currentAvatar!.skin {
                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
            case "Hair Style":
                if self.filteredPropList[indexPath.row].id == self.currentAvatar!.hair {
                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
            case "Jeans":
                if self.filteredPropList[indexPath.row].id == self.currentAvatar!.pants {
                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
            case "Outfits":
                if self.filteredPropList[indexPath.row].id == self.currentAvatar!.shirt {
                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
            case "Shoes":
                if self.filteredPropList[indexPath.row].id == self.currentAvatar!.shoes {
                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
            case "Eye Glasses":
                if self.filteredPropList[indexPath.row].id == self.currentAvatar!.glasses {
                    self.collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredVertically)
                }
            default:
                print("Switch Default Case")
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        guard let selectedPropTypeIndex = self.tableView.indexPathForSelectedRow else {
            return
        }
        
        let selectedPropType = customizationList[selectedPropTypeIndex.row].1
        
        guard let imgURL = Utils.getCompleteURL(urlWithoutSlashString: self.filteredPropList[indexPath.row].propLinkApp) else {
            return
        }
        
        switch selectedPropType {
            
        case "Skin Color":
            if self.currentAvatar!.skin == self.propList[indexPath.row].id {
                return
            }
            //            self.switchPantsNSetId()
            self.currentAvatar!.skin = self.filteredPropList[indexPath.row].id
            self.skinPropImgView.kf.setImage(with: imgURL)
            self.currentAvatar!.propSkin = self.filteredPropList[indexPath.row].propLinkApp
            self.switchAvatarAfterSKinChange()
        case "Hair Style":
            if self.currentAvatar!.hair == self.propList[indexPath.row].id {
                return
            }
            self.currentAvatar!.hair = self.filteredPropList[indexPath.row].id
            self.hairPropImgView.kf.setImage(with: imgURL)
            self.currentAvatar!.propHair = self.filteredPropList[indexPath.row].propLinkApp
        case "Jeans":
            if self.currentAvatar!.pants == self.propList[indexPath.row].id {
                return
            }
            self.currentAvatar!.pants = self.filteredPropList[indexPath.row].id
            self.pantPropImgView.kf.setImage(with: imgURL)
            self.currentAvatar!.propPants = self.filteredPropList[indexPath.row].propLinkApp
        case "Outfits":
            if self.currentAvatar!.shirt == self.propList[indexPath.row].id {
                return
            }
            self.currentAvatar!.shirt = self.filteredPropList[indexPath.row].id
            self.shirtPropImgView.kf.setImage(with: imgURL)
            self.currentAvatar!.propShirt = self.filteredPropList[indexPath.row].propLinkApp
        case "Shoes":
            if self.currentAvatar!.shoes == self.propList[indexPath.row].id {
                return
            }
            self.currentAvatar!.shoes = self.filteredPropList[indexPath.row].id
            self.shoesPropImgView.kf.setImage(with: imgURL)
            self.currentAvatar!.propShoes = self.filteredPropList[indexPath.row].propLinkApp
        case "Eye Glasses":
            if self.currentAvatar!.glasses == self.propList[indexPath.row].id {
                return
            }
            
            self.currentAvatar!.glasses = self.filteredPropList[indexPath.row].id
            
            if self.filteredPropList[indexPath.row].id == 0 {
                self.glassesPropImgView.image = nil
            }
            else {
                self.glassesPropImgView.kf.setImage(with: imgURL)
                self.currentAvatar!.propGlasses = self.filteredPropList[indexPath.row].propLinkApp
            }
            
        default:
            print("Switch Default Case")
        }
    }
    
    //    func switchColors() {
    //        for i in stride(from: 0, to: self.propList.count, by: 1) {
    //            if self.propList[i].propname == "Pants" {
    //                if self.propList[i].color == 2 {
    //                    if self.propList[i].propLink!.contains("dark") {
    //
    ////                        self.propList[i].propLink = self.propList[i].propLink!.replacingOccurrences(of: "-dark.", with: ".")
    ////                        self.propList[i].propLinkApp = self.propList[i].propLinkApp!.replacingOccurrences(of: "-dark.", with: ".")
    ////                        self.currentAvatar
    //                    }
    //                }
    //            }
    //        }
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width / 3) - 10.0, height: (collectionView.bounds.width / 3) - 10.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

extension EditAvatarVC: NetworkResponseProtocols {
    
    // MARK: - Avatar Prop List Response
    func didGetAllAvatarPropsByGender() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.avatarPropsByGenderResponse?.data {
            
            self.propList = unwrappedList
            
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .none)
            self.tableView(self.tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
            self.collectionView.reloadData()
            
            for i in stride(from: 0, to: self.propList.count, by: 1) {
                if let imgURL = Utils.getCompleteURL(urlWithoutSlashString: self.propList[i].propLinkApp) {
                    UIImageView().kf.setImage(with: imgURL)
                }
            }
            
        }
        else {
            Alert.sharedInstance.alertOkWindow(title: "Error", message: self.viewModel.avatarPropsByGenderResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Save Avatar Response
    func didSaveUserAvatar() {
        
        self.hideLoader()
        
        if self.viewModel.saveUserAvatarResponse?.isSuccess ?? false {
            
            self.delegate?.refreshAvatar()
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.saveUserAvatarResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        else {
            self.showToast(message: self.viewModel.saveUserAvatarResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
}
