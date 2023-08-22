//
//  ConfirmTransferVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/09/2022.
//

import UIKit

class ConfirmTransferVC: BaseViewController {

    @IBOutlet weak var senderFullNameLbl: UILabel!
    @IBOutlet weak var senderWalletIdLbl: UILabel!
    @IBOutlet weak var receiverFullNameLbl: UILabel!
    @IBOutlet weak var receiverWalletIdLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var feesLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var checkImgView: UIImageView!
    
    var receiverInfo = ValueWrapper<FriendDM?>(value: nil)
    var amount: Double?
    
    var isTransferFromCircle = false
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        senderFullNameLbl.text = "\(PreferencesManager.getUserModel()?.firstName ?? "") \(PreferencesManager.getUserModel()?.lastName ?? "")"
        senderWalletIdLbl.text = PreferencesManager.getWalletDetail()?.walletID ?? ""
    
        if let receiversInfo = receiverInfo.value, let _ = receiverInfo.value?.identifier, let amount {
            
            self.receiverFullNameLbl.text = receiversInfo.name ?? ""
            self.receiverWalletIdLbl.text = receiversInfo.walletID ?? ""
            
            self.amountLbl.text = "$ \(amount)"
            
            self.totalLbl.text = "$ \(amount - 0)" // replace 0 by fees later
        }
        else {
            Alert.sharedInstance.alertOkWindow(title: "", message: "Some error occured, please try again later") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
    }
    
    // MARK: - Transfer to Friend
    func transferToFriend() {
        
        self.showLoader()
        
        let params: [String: Any] = [
            "amount": amount!,
            "membersIdentifier": receiverInfo.value!.identifier!
        ]
        self.viewModel.transferToFriend(params: params)
    }
    
    // MARK: - Check/Uncheck Terms and Condition Tap Gesture
    @IBAction func checkImgTapped(_ sender: UITapGestureRecognizer) {
        if checkImgView.image == UIImage(named: "checked") {
            checkImgView.image = UIImage(named: "radioIcon")
        } else {
            checkImgView.image = UIImage(named: "checked")
        }
    }
    
    // MARK: - Terms and Conditions Button Tapped
    @IBAction func termsNConditionBtnTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "AppInfoVC") as? AppInfoVC {
            vc.sourceCell = .termsNConditions
            self.navigationController?.pushViewController(vc, animated: true)
        }
//        guard let url = URL(string: "https://216.108.238.109:7926/about/terms") else { return }
//        UIApplication.shared.open(url)
    }
    
    // MARK: - Confirm Transfer Button Tapped
    @IBAction func confirmTransferBtnTapped(_ sender: UIButton) {
        
        if checkImgView.image == UIImage(named: "checked") {
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "EnterOTPVC") as? EnterOTPVC {
                vc.destinationController = .confirmTransferVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            self.showToast(message: "Please agree Terms & conditions to Proceed", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Cancel Button Tapped
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ConfirmTransferVC: NetworkResponseProtocols {
    
    // MARK: - Transfer to Friend Response
    func didTransferToFriend() {
        
        self.hideLoader()
        
        if self.viewModel.transferToFriendResponse?.isSuccess ?? false {
            
            // refresh wallet amount in MyWalletVC
            NotificationCenter.default.post(name: .refreshWalletAmount, object: nil)
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: viewModel.transferToFriendResponse?.message ?? "Some error occured") { result in
                if result {
                    if self.isTransferFromCircle {
                        self.dismiss(animated: true)
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        } else {
            self.showToast(message: viewModel.transferToFriendResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}

extension ConfirmTransferVC: AppProtocol {
    
    // MARK: - Hit 'transfer to friend' API in ConfirmTransferVC after OTP is verified in EnterOTPVC
    func hitTransferAPI() {
        self.transferToFriend()
    }
}
