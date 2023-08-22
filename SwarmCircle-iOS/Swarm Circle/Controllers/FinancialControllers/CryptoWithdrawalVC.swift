//
//  CryptoWithdrawalVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 21/09/2022.
//

import UIKit

class CryptoWithdrawalVC: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var availableBalanceLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var withdrawalAmountTF: UITextField!
    @IBOutlet weak var withdrawalAmountInUSDCTF: UITextField!
    @IBOutlet weak var walletAddressTF: UITextField!
    @IBOutlet weak var remainingBalanceLbl: UILabel!
    
    var exchangeRate = 1.0
    
    var availableBalance: Double?
    var senderWalletId: String?
    
    var delegate: AppProtocol?
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        self.availableBalanceLbl.text = "Available Balance: -"
        self.remainingBalanceLbl.text = "Remaining Balance: -"
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        self.walletAddressTF.delegate = self
        
        setToolBarOnKeyboard(textField: withdrawalAmountTF)
        setToolBarOnKeyboard(textField: withdrawalAmountInUSDCTF)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.getWalletDetail()
    }
    
    // MARK: - Get Wallet Detail
    func getWalletDetail() {
        self.viewModel.getWalletDetail()
    }
    
    // MARK: - Post Crypto Withdraw
    func postCrytoWithdraw() {
        
        self.showLoader()
        
        let params: [String: Any] = [
            "amount": Double(Utils.restrictDoubleTwoDecimal(Double(withdrawalAmountTF.text!)!))!,
            "senderWalletID": self.senderWalletId ?? "",
            "receiverAddress": self.walletAddressTF.text ?? ""
        ]
        
        self.viewModel.cryptoWithdraw(params: params)
    }
    
    // MARK: - Handling keyboard Hide/Show
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            
            // get the size of keyboard
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            // checking keyboard status whether it's showing or hidden
            if isKeyboardShowing {
                print("Keyboard Showing")
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - keyboardSize.height, right: 0)
                
                self.lastBottomConstraint.constant = keyboardSize.height - 25
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else{
                print("Keyboard Hidden")
                
                self.lastBottomConstraint.constant = 50
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - Done Button Tapped
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.walletAddressTF.text?.removeWhiteSpacesFromStartNEnd()
        
        if self.validateFields() {
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "EnterOTPVC") as? EnterOTPVC {
                vc.destinationController = .cryptoWithdrawalVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    
    // MARK: - Validate Fields on button Tap
    func validateFields() -> Bool {
        
        if withdrawalAmountTF.text!.isEmpty {
            self.showToast(message: "Withdrawal amount required", toastType: .red)
            return false
        }
        else if Double(withdrawalAmountTF.text!)! <= 0 {
            self.showToast(message: "Please enter an amount greater than 0", toastType: .red)
            return false
        }
        if walletAddressTF.text!.isEmpty {
            self.showToast(message: "Wallet address required", toastType: .red)
            return false
        }
        return true
    }
}

// MARK: - TextField Configuration
extension CryptoWithdrawalVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.withdrawalAmountTF {
            
            if textField.text! == "" && string == "." {
                textField.text = "0"
                return true
            }
            if string == "0" && textField.text! == "" {
                textField.text = "0."
                return false
            }
            if string == "" && textField.text! == "0." {
                textField.text = ""
                return true
            }
            
            if string == "." && textField.text!.contains(".") {
                return false
            }
            
            // Don't allow more than two digits after a decimal point
            if textField.text!.contains(".") && textField.text!.split(separator: ".").count == 2 {
                if textField.text!.split(separator: ".")[1].count == 2 && string != "" {
                    return false
                }
            }
            
            let text = string == "" ? self.withdrawalAmountTF.text!.dropLast() : "\(self.withdrawalAmountTF.text!)\(string)"
            
            if let value = Double(text) {
                
                if value <= self.availableBalance! {
                    self.withdrawalAmountInUSDCTF.text = "\(self.exchangeRate * value)"
                    self.remainingBalanceLbl.text = "Remaining Balance: \(Utils.restrictDoubleTwoDecimal(self.availableBalance! - value))"
                } else {
                    return false
                }
                
            } else {
                self.withdrawalAmountInUSDCTF.text = ""
            }
        }
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        
        if textField == self.withdrawalAmountTF {
            
            if let value = Double(textField.text!) {
                self.withdrawalAmountInUSDCTF.text = "\(self.exchangeRate * value)"
                self.remainingBalanceLbl.text = "Remaining Balance: \(Utils.restrictDoubleTwoDecimal(self.availableBalance! - value))"
            } else {
                self.withdrawalAmountInUSDCTF.text = ""
                self.remainingBalanceLbl.text = "Remaining Balance: \(Utils.restrictDoubleTwoDecimal(self.availableBalance!))"
            }
        }
    }
    
    // MARK: - Dismiss keyboard on Done button Tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension CryptoWithdrawalVC: NetworkResponseProtocols {
    
    // MARK: - Wallet Detail Response
    func didGetWalletDetail() {
        
        self.hideLoader()
        
        if let walletDetail = viewModel.walletDetailResponse?.data {
            
            if let senderWalletId = walletDetail.walletID, let availableBalance = walletDetail.amount {
                self.senderWalletId = senderWalletId
                self.availableBalance = availableBalance
                self.availableBalanceLbl.text = "Available Balance: \(availableBalance)"
                self.remainingBalanceLbl.text = "Remaining Balance: \(Utils.restrictDoubleTwoDecimal(availableBalance))"
                
                self.withdrawalAmountTF.delegate =  self
                
            } else {
                Alert.sharedInstance.alertOkWindow(title: "", message: "Some error occured, please try again later") { result in
                    if result {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            Alert.sharedInstance.alertOkWindow(title: "", message: "Some error occured, please try again later") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Crypto Withdrawal Response
    func didCryptoWithdraw() {
        
        self.hideLoader()
        
        if self.viewModel.cryptoWithdrawResponse?.isSuccess ?? false {
            
            self.delegate?.refreshWalletAmount()
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: viewModel.cryptoWithdrawResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            self.showToast(message: viewModel.cryptoWithdrawResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}

extension CryptoWithdrawalVC: AppProtocol {
    
    // MARK: - Hit 'crypto withdrawal to bank account' API in CryptoWithdrawalVC after OTP is verified in EnterOTPVC
    func hitCryptoWithdrawalAPI() {
        self.postCrytoWithdraw()
    }
}
