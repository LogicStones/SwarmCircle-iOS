//
//  ConfirmWithdrawalVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/10/2022.
//

import UIKit

class ConfirmWithdrawalVC: BaseViewController {

    @IBOutlet weak var senderFullNameLbl: UILabel!
    @IBOutlet weak var senderWalletIdLbl: UILabel!
    @IBOutlet weak var bankNameLbl: UILabel!
    @IBOutlet weak var accNumberLbl: UILabel!
    @IBOutlet weak var accHolderNameLbl: UILabel!
    @IBOutlet weak var routingNumberLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var feesLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet var pfLbl: UILabel!
    @IBOutlet weak var checkmarkBtn: UIButton!
    @IBOutlet var confirmWithdrawBtn: UIButton!
    
    var amount: Double?
    var feeAmount = 0.0
    var bankDetail: BankAccountDM?
    var platformFees = 3.0

    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        self.senderFullNameLbl.text = PreferencesManager.getWalletDetail()?.walletName ?? ""
        self.senderWalletIdLbl.text = PreferencesManager.getWalletDetail()?.walletID ?? ""
        
        self.bankNameLbl.text = bankDetail?.bankName ?? ""
        self.accNumberLbl.text = bankDetail?.accountNumber ?? ""
        self.accHolderNameLbl.text = bankDetail?.accountHolderName ?? ""
        self.routingNumberLbl.text = bankDetail?.routingNumber ?? ""
        
        guard let amount else {
            popOnErrorAlert("Amount missing")
            return
        }
        guard let _ = bankDetail?.identifier else {
            popOnErrorAlert("Bank Identifier missing")
            return
        }
        //fee calculation
        self.pfLbl.text = "$ \(self.platformFees)"
        self.feesLbl.text = "$ " + String(format: "%.2f", self.feeAmount )
        self.amountLbl.text = "$ \(String(format: "%.2f", amount - self.feeAmount - self.platformFees))"
        self.totalLbl.text = "$ " + String(format: "%.2f", amount)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
    }
    
    // MARK: - Withdraw amount to Bank Account
    func withdrawAmountToBankAccount() {
        
        self.showLoader()

        let params = [
            "bankIdentifier": self.bankDetail!.identifier!,
            "amount": self.amount!
        ] as [String : Any]
        
        self.viewModel.withdrawAmountToBankAccount(params: params)
    }
    
    // MARK: - Checkmark Button Tapped
    @IBAction func checkmarkBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
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
        
        if self.checkmarkBtn.isSelected {
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "EnterOTPVC") as? EnterOTPVC {
                vc.destinationController = .confirmWithdrawalVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            self.showToast(message: "Please agree Terms & conditions to Proceed", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Cancel Button Tapped
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension ConfirmWithdrawalVC: NetworkResponseProtocols {
    
    // MARK: - Withdraw Amount To Bank
    func didWithdrawAmountToBank() {
        
        self.hideLoader()

        if self.viewModel.withdrawAmountToBankResponse?.isSuccess ?? false {
            
            // refresh wallet amount in MyWalletVC
            NotificationCenter.default.post(name: .refreshWalletAmount, object: nil)
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.withdrawAmountToBankResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            self.showToast(message: self.viewModel.withdrawAmountToBankResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}

extension ConfirmWithdrawalVC: AppProtocol {
    
    // MARK: - Hit 'withdraw amount to bank account' API in ConfirmWithdrawalVC after OTP is verified in EnterOTPVC
    func hitWithdrawalAPI() {
        self.withdrawAmountToBankAccount()
    }
}
