//
//  MyWalletVC.swift
//  Swarm Circle
//
//  Created by Macbook on 04/07/2022.
//

import UIKit

class MyWalletVC: BaseViewController {
    
    @IBOutlet weak var currencyImgView: UIImageView!
    @IBOutlet weak var walletBalanceLbl: UILabel!
    @IBOutlet weak var walletInfoActivityIndView: UIActivityIndicatorView!
    @IBOutlet weak var depositBtn: UIButton!
    @IBOutlet weak var withdrawalBtn: UIButton!
    @IBOutlet weak var transferBtn: UIButton!
    
    var actions: [(String, UIAlertAction.Style)] = [
        ("Bank Account", UIAlertAction.Style.default),
        ("Crypto Wallet", UIAlertAction.Style.default),
        ("Cancel", UIAlertAction.Style.cancel)
    ]
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To My Wallet"
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        self.walletInfoActivityIndView.startAnimating()
        self.walletBalanceLbl.adjustsFontSizeToFitWidth = true
        self.currencyImgView.isHidden = true
        self.walletBalanceLbl.isHidden = true
        
        // Refresh Wallet amount (called in  ConfirmTransferVC after amount is transferred, after amount is deposited in ConfirmPaymentVC)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshWalletAmount(notification:)), name: .refreshWalletAmount, object: nil)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.getWalletBalance()
    }
    
    // MARK: - Get Wallet Balance
    func getWalletBalance() {
        
        self.viewModel.getWalletBalance { balance in
            
            if let balance {
                self.walletInfoActivityIndView.stopAnimating()
                self.currencyImgView.isHidden = false
                self.walletBalanceLbl.isHidden = false
                self.setWalletBalance(value: balance)
            } else {
                self.showToast(message: "Some error occured", toastType: .red)
            }
        }
    }
    
    // MARK: - Set Wallet Balance (Animated)
    func setWalletBalance(value: Double) {
        
        ValueAnimator(from: 0.0, to: value, duration: 0.5) { value in
            self.walletBalanceLbl.text = "\(value)"
        }.start()
    }
    
    @IBAction func depositButtonTapped(_ sender: Any) {
        if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "DepositVC") as? DepositVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func withdrawalPressed(_ sender: UIButton) {
        
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Withdrawal Type", message: "", actions: actions) { index, _ in
            switch index {
            case 0:
                if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "WithdrawVC") as? WithdrawVC { // WithdrawalVC will not be used anymore.
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                break
            case 1:
                
                self.hideLoader()
                if PreferencesManager.getUserDetailModel()?.isAMLSuccess ?? false {
                    self.showCryptoScreen()
                } else {
                    self.getUserDetails()
                }

                break
            default :
                print(self.actions[index].0)
            }
        }    
    }
    
    @IBAction func transferPressed(_ sender: Any) {
        
        if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "TransferVC") as? TransferVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showCryptoScreen(){
        if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "CryptoWithdrawalVC") as? CryptoWithdrawalVC {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showIdentificationScreen(){
        if let vc = AppStoryboard.Identify.instance.instantiateViewController(withIdentifier: "IdentifyVC") as? IdentifyVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

extension MyWalletVC: AppProtocol {
    
    // MARK: - Refresh Wallet amount after cryto withdrawal in CryptoWithdrawalVC
    func refreshWalletAmount() {
        self.getWalletBalance()
    }
    
    // MARK: - Get User Details
    func getUserDetails() {
        self.showLoader()
        self.viewModel.getUserDetails()
    }
}

extension MyWalletVC {
    // MARK: - Refresh Wallet amount (called in  ConfirmTransferVC after amount is transferred, after amount is deposited in ConfirmPaymentVC)
    @objc func refreshWalletAmount(notification: Notification) {
        
        self.getWalletBalance()
        
        if PreferencesManager.getUserModel()?.isAccountVerified ?? true == false {
            
            self.viewModel.getPrivacySettings()
        }
    }
    
}

extension MyWalletVC: NetworkResponseProtocols {
    
    // MARK: - Privacy settings response
    func didGetPrivacySettings() {
        
        if self.viewModel.privacySettingsResponse?.data?.isTransactionVerificationProgress ?? false {
            var currentUserModel = PreferencesManager.getUserModel()
            currentUserModel?.isAccountVerified = true
            PreferencesManager.saveUserModel(user: currentUserModel)
        }
    }
    
    // MARK: - User Details Response
    func didGetUserDetails() {
        
        self.hideLoader()
        if let data = self.viewModel.userDetailsResponse?.data {
            PreferencesManager.saveUserDetailsModel(user: data)
            if data.isAMLSuccess ?? false{
                self.showCryptoScreen()
            } else {
                self.showIdentificationScreen()
            }
        } else {
//            popOnErrorAlert(self.viewModel.userDetailsResponse?.message ?? "")
        }
    }
    
}
