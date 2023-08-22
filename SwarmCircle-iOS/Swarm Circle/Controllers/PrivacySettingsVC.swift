//
//  PrivacySettingsVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/12/2022.
//

import UIKit

class PrivacySettingsVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var emailPrivacySettingsLbl: UILabel!
    @IBOutlet weak var phonePrivacySettingsLbl: UILabel!
    @IBOutlet weak var friendPrivacySettingsLbl: UILabel!
    @IBOutlet weak var circlePrivacySettingsLbl: UILabel!
    
    @IBOutlet weak var twoFactorSwitch: UISwitch!
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var emailImgView: UIImageView!
    @IBOutlet weak var emailToPhoneView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneImgView: UIImageView!
    @IBOutlet weak var phoneToTransactionView: UIView!
    @IBOutlet weak var transactionView: UIView!
    @IBOutlet weak var transactionImgView: UIImageView!
    
    let privacyOptions: [(String, UIAlertAction.Style)] = [
        ("Only Me", UIAlertAction.Style.default),
        ("Friends", UIAlertAction.Style.default),
        ("Everyone", UIAlertAction.Style.default),
        ("Cancel", UIAlertAction.Style.cancel)
    ]
    
    enum PrivacyType: String {
        
        case emailPrivacy
        case phonePrivacy
        case friendListPrivacy
        case circleListPrivacy
    }
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Privacy Settings"
    }
    
    // MARK: - UI initialization
    func initUI() {
        
        DispatchQueue.main.async {
            self.scrollView.flashScrollIndicators()
        }
    }
    
    // MARK: - Load data
    func initVariable() {
        
        self.viewModel.delegateNetworkResponse = self
        
        self.getPrivacySettings()
    }
    
    // MARK: - Get privacy settings
    func getPrivacySettings() {
        
        self.showLoader()
        
        self.viewModel.getPrivacySettings()
    }
    
    // MARK: - Change privacy settings
    func changePrivacySettings(privacyType: PrivacyType, value: Int, currentPrivacyText: String) {
        
        let params = [
            "privacyType": privacyType.rawValue,
            "value": value // AccountPrivacy: OnlyMe = 0, Friends = 1, Everyone = 2
        ] as [String : Any]
        
        self.viewModel.changePrivacySettings(params: params, currentPrivacyText: currentPrivacyText)
    }
    
    // MARK: - Change two factor authentication
    func changeTwoFactorAuthentication(isEnabled: Bool) {
        
        self.viewModel.changeTwoFactorAuthentication(isEnabled: isEnabled)
    }
    
    // MARK: - Email address privacy button tapped
    @IBAction func emailAddressPrivacyBtnTapped(_ sender: UIButton) {
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Audience", message: "Who can see your email address?", actions: self.privacyOptions) { index, _ in
            if index < 3 { // Set Privacy
                self.emailPrivacySettingsLbl.text = self.privacyOptions[index].0
                self.changePrivacySettings(privacyType: .emailPrivacy, value: index, currentPrivacyText: self.emailPrivacySettingsLbl.text!)
            }
        }
    }
    
    // MARK: - Phone number privacy button tapped
    @IBAction func phoneNumberPrivacyBtnTapped(_ sender: UIButton) {
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Audience", message: "Who can see your phone number?", actions: self.privacyOptions) { index, _ in
            if index < 3 { // Set Privacy
                self.phonePrivacySettingsLbl.text = self.privacyOptions[index].0
                self.changePrivacySettings(privacyType: .phonePrivacy, value: index, currentPrivacyText: self.phonePrivacySettingsLbl.text!)
            }
        }
    }
    
    // MARK: - My friends privacy button tapped
    @IBAction func myFriendsPrivacyBtnTapped(_ sender: UIButton) {
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Audience", message: "Who can see your friends?", actions: self.privacyOptions) { index, _ in
            if index < 3 { // Set Privacy
                self.friendPrivacySettingsLbl.text = self.privacyOptions[index].0
                self.changePrivacySettings(privacyType: .friendListPrivacy, value: index, currentPrivacyText: self.friendPrivacySettingsLbl.text!)
            }
        }
    }
    
    // MARK: - My circles privacy button tapped
    @IBAction func myCirclesPrivacyBtnTapped(_ sender: UIButton) {
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Audience", message: "Who can see your circles?", actions: self.privacyOptions) { index, _ in
            if index < 3 { // Set Privacy
                self.circlePrivacySettingsLbl.text = self.privacyOptions[index].0
                self.changePrivacySettings(privacyType: .circleListPrivacy, value: index, currentPrivacyText: self.circlePrivacySettingsLbl.text!)
            }
        }
    }
    
    // MARK: - Two factor authentication button tapped
    @IBAction func twoFactorSwitchBtnTapped(_ sender: UISwitch) {
        
        if self.twoFactorSwitch.isOn {
            
            self.twoFactorSwitch.isOn = false
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "EnterOTPVC") as? EnterOTPVC {
                vc.destinationController = .privacySettingsVC
                vc.additionalParams[.isSwitchingTwoFactor] = true
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        } else {
            self.changeTwoFactorAuthentication(isEnabled: false)
        }
    }
    
    // MARK: - Phone button tapped
    @IBAction func phoneBtnTapped(_ sender: UIButton) {
        
        if self.phoneView.isHidden {
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "EnterOTPVC") as? EnterOTPVC {
                vc.destinationController = .privacySettingsVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    // MARK: - Transaction button tapped
    @IBAction func transactionBtnTapped(_ sender: UIButton) {
        
        if self.transactionView.isHidden {
            
            self.navigationController?.popViewController(animated: true)
            self.delegate?.moveToWalletTab()
        }
    }
}

extension PrivacySettingsVC: NetworkResponseProtocols {
    
    // MARK: - Privacy settings response
    func didGetPrivacySettings() {
        
        self.hideLoader()
        
        if let data = self.viewModel.privacySettingsResponse?.data {
            
            //    AccountPrivacy: Only Me = 0, Friends = 1, Everyone = 2
            self.emailPrivacySettingsLbl.text = data.emailPrivacyText
            self.phonePrivacySettingsLbl.text = data.phonePrivacyText
            self.friendPrivacySettingsLbl.text = data.friendListPrivacyText
            self.circlePrivacySettingsLbl.text = data.circleListPrivacyText
            
            self.twoFactorSwitch.isOn = data.isTwoFAEnabled ?? false
            
            if data.isPhoneVerificationProgress ?? false {
                self.emailToPhoneView.isHidden = false
                self.phoneView.isHidden = false
                self.phoneImgView.image = UIImage(named: "phoneFilledIcon")
            }
            
            if data.isTransactionVerificationProgress ?? false {
                self.phoneToTransactionView.isHidden = false
                self.transactionView.isHidden = false
                self.transactionImgView.image = UIImage(named: "transactionFilledIcon")
            }
            
        } else {
            popOnErrorAlert(self.viewModel.privacySettingsResponse?.message ?? "Something went wrong")
        }
    }
    
    
    // MARK: - Change privacy settings response
    func didChangePrivacySettings(privacyType: Any, currentPrivacyText: String) {
        
        if self.viewModel.changePrivacyResponse?.isSuccess ?? false {
            
            self.showToast(message: self.viewModel.changePrivacyResponse?.message ?? "Something went wrong", toastType: .green)
            
        } else {
            
            self.showToast(message: self.viewModel.changePrivacyResponse?.message ?? "Something went wrong", toastType: .red)
            
            self.setPrivacyText(privacyType, currentPrivacyText)
        }
    }
    
    // MARK: - Set privacy text
    fileprivate func setPrivacyText(_ privacyType: Any, _ currentPrivacyText: String) {
        
        guard let privacyType = privacyType as? PrivacyType else { return }
        
        switch privacyType {
            
        case .emailPrivacy:
            self.emailPrivacySettingsLbl.text = currentPrivacyText
        case .phonePrivacy:
            self.phonePrivacySettingsLbl.text = currentPrivacyText
        case .friendListPrivacy:
            self.friendPrivacySettingsLbl.text = currentPrivacyText
        case .circleListPrivacy:
            self.circlePrivacySettingsLbl.text = currentPrivacyText
        }
    }
    
    // MARK: - Two factor authentication response
    func didChangeTwoFactorAuthentication(isEnabled: Bool) {
        
        if self.viewModel.changeTwoFactorAuthenticationResponse?.isSuccess ?? false {
            
            if isEnabled {
                self.getPrivacySettings()
            }
            
            self.showToast(message: self.viewModel.changeTwoFactorAuthenticationResponse?.message ?? "Something went wrong", toastType: .green)
    
        } else {
            
            self.twoFactorSwitch.isOn = !isEnabled
        
            self.showToast(message: self.viewModel.changeTwoFactorAuthenticationResponse?.message ?? "Something went wrong", toastType: .red)
        }
    }
}

extension PrivacySettingsVC: AppProtocol {
    
    // MARK: - Refresh PrivacySettingsVC and turn on 2FA if check is true, after two factor process is successful in EnterOTPVC.
    func refreshPrivacySettingsScreen(turnOnTwoFactor: Bool) {
        if turnOnTwoFactor { // hit two factor authentication api when switching 2FA.
            self.changeTwoFactorAuthentication(isEnabled: true)
        } else { // just refresh screen when we are just verifying phone number.
            self.getPrivacySettings()
        }
    }
}

//class purpleGradientView: UIView {
//    private lazy var gradient: CAGradientLayer = {
//        let l = CAGradientLayer()
//        l.type = .radial
//        l.colors = [
//            UIColor(red: 0.87, green: 0, blue: 1, alpha: 1),
//            UIColor(red: 0.86, green: 0, blue: 1, alpha: 1),
//            UIColor(red: 0.81, green: 0, blue: 1, alpha: 1),
//            UIColor(red: 0.75, green: 0, blue: 1, alpha: 1),
//            UIColor(red: 0.63, green: 0.09, blue: 0.95, alpha: 1)
//        ]
//        l.locations = [ 0.0, 0.25, 0.5, 0.71, 1.0 ]
//        l.startPoint = CGPoint(x: 0.0, y: 0.0)
//        l.endPoint = CGPoint(x: 1, y: 1)
//        layer.addSublayer(l)
//        return l
//    }()
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        gradient.frame = bounds
//        gradient.cornerRadius = bounds.width / 2.0
//    }
//}
