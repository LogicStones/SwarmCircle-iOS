//
//  ProfileVC.swift
//  Swarm Circle
//
//  Created by Macbook on 04/07/2022.
//

import UIKit
import SafariServices

class ProfileVC: BaseViewController {
    
    @IBOutlet weak var profilePicImgView: CircleImage!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    @IBOutlet weak var idLbl: UILabel!
    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    var optionList = ["Edit Profile", "My Transactions", "Account Details", "My Avatar","Subscriptions", "Settings", "Contact Us", "Terms & Conditions", "Privacy Policy", "Invite to SwarmCircle", "Delete my Account"]
    var iconsList = ["edit", "money-stack", "id", "avatarIcon","subscription", "lockedLockIcon", "phone", "cost-estimate", "contract", "shareIcon", "deleteAccountIcon"]
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.isVerifiedIcon.isHidden = !(PreferencesManager.getUserModel()?.isAccountVerified ?? false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Profile"
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        self.nameLbl.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
        
        self.idLbl.text = PreferencesManager.getUserModel()?.userID ?? ""
        
        self.profilePicImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: PreferencesManager.getUserModel()?.displayImageURL) {
            self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.tableView.register(UINib(nibName: "EditProfileCell", bundle: nil), forCellReuseIdentifier: "EditProfileCell")
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
    // MARK: - Remove user defaults
    @IBAction func logoutBtnTapped(_ sender: UIButton) {
        
        Alert.sharedInstance.alertWindow(title: "Alert", message: "Are you sure you want to logout") { result in
            if result {
                self.showLoader()
                self.viewModel.logout()
            }
        }
    }
    
    @IBAction func createAviTapped(_ sender: Any) {
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "MyAvatarVC") as? MyAvatarVC{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func clipboardBtnTapped(_ sender: UIButton) {
        UIPasteboard.general.string = "\(PreferencesManager.getUserModel()?.userID ?? "")"
        self.showToast(message: "User Id copied to clipboard", delay: 0.75, toastType: .black)
    }
    
    @IBAction func editProfileIconTapped(_ sender: UIButton) {
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    
    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async {
            super.updateViewConstraints()
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
    }
    
    func showIdentificationScreen(){
        if let vc = AppStoryboard.Identify.instance.instantiateViewController(withIdentifier: "IdentifyVC") as? IdentifyVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.optionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditProfileCell") as? EditProfileCell else {
            return UITableViewCell()
        }
        
        cell.optionTitleLBL.text = self.optionList[indexPath.row]
        cell.optionIcon.image = UIImage(named: self.iconsList[indexPath.row])?.withRenderingMode(.alwaysOriginal)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "EditProfileVC") as? EditProfileVC {
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 1:
            if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "TransactionsVC") as? TransactionsVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 2:
            if PreferencesManager.getUserDetailModel()?.isAMLSuccess ?? false {
                if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "MyAccountVC") as? MyAccountVC {
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.showLoader()
                self.getUserDetails()
            }
            
            
        case 3:
            if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "MyAvatarVC") as? MyAvatarVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 4:
            if let vc = AppStoryboard.Subscriptions.instance.instantiateViewController(withIdentifier: "SubscriptionListVC") as? SubscriptionListVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 5:
            if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "PrivacySettingsVC") as? PrivacySettingsVC {
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 6:
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ContactUsVC") as? ContactUsVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 7:
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "AppInfoVC") as? AppInfoVC {
                vc.sourceCell = .termsNConditions
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 8:
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "AppInfoVC") as? AppInfoVC {
                vc.sourceCell = .privacyPolicy
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case 9:

            Utils.openShareIntent(self, description: "Hey, Checkout this Application...", shareLink: "\(AppConstants.baseURL)Account/Register?Referal=7f57bfb4")
//            guard let shareLink = PreferencesManager.getUserModel()?.shareLink else {
//                return
//            }
//            Utils.openShareIntent(self, description: "Hey, Checkout this Application...", shareLink: shareLink)
            
        case 10:
            
            Alert.sharedInstance.alertWindow(title: "Warning", message: "Are you sure you want to delete this account") { result in
                if result {
                    self.deleteAccount()
                }
            }
        default:
            print("Do Nothing")
        }
        
    }
    
    func deleteAccount() {
        self.showLoader()
        self.viewModel.deleteAccount()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
    
}

extension ProfileVC: NetworkResponseProtocols {
    
    
    // MARK: - User Details Response
    func didGetUserDetails() {
        
        self.hideLoader()
        if let data = self.viewModel.userDetailsResponse?.data {
            PreferencesManager.saveUserDetailsModel(user: data)
            if data.isAMLSuccess ?? false{
                if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "MyAccountVC") as? MyAccountVC {
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.showIdentificationScreen()
            }
        } else {
//            popOnErrorAlert(self.viewModel.userDetailsResponse?.message ?? "")
        }
    }
    
    
    // MARK: - Delete account response
    func didDeleteAccount() {
        
        self.hideLoader()
        
        if self.viewModel.deleteAccountResponse?.isSuccess ?? false {
            
            let fcmToken = PreferencesManager.getFirebaseToken()
            
            PreferencesManager.saveLoginState(isLogin: false)
            
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
            UserDefaults.standard.synchronize()
                
            PreferencesManager.saveFirebaseToken(fcmToken)
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.deleteAccountResponse?.message ?? "Something went wrong") { result in
                
                if result {
                    self.dismiss(animated: true)
                }
            }
            
        } else {
            self.showToast(message: self.viewModel.deleteAccountResponse?.message ?? "Something went wrong", toastType: .red)
        }
    }
    
    // Logout Response
    func didLogout() {
        
        self.hideLoader()
        
        if self.viewModel.logoutResponse?.isSuccess ?? false {
            
            //            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.logoutResponse?.message ?? "Some error occured") { result in
            //                if result {
            
            let fcmToken = PreferencesManager.getFirebaseToken()
            
            PreferencesManager.saveLoginState(isLogin: false)
            self.dismiss(animated: true) {
                let domain = Bundle.main.bundleIdentifier!
                UserDefaults.standard.removePersistentDomain(forName: domain)
                UserDefaults.standard.synchronize()
                
                PreferencesManager.saveFirebaseToken(fcmToken)
            }
            //                }
            //            }
        }
        else {
            self.showToast(message: self.viewModel.logoutResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
}

extension ProfileVC: AppProtocol {
    func moveToWalletTab() {
        self.tabBarController?.selectedIndex = 3
    }
    
    // MARK: - Update User Info after Profile has been edited in EditProfileVC
    func updateUserInfo() {
        
        self.nameLbl.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
        
        self.profilePicImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: PreferencesManager.getUserModel()?.displayImageURL) {
            self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
    }
}
extension ProfileVC{
    
    // MARK: - Get User Details
    func getUserDetails() {
        self.viewModel.getUserDetails()
    }
}
