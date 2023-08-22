//
//  EnterOTPVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/12/2022.
//

import UIKit

class EnterOTPVC: BaseViewController {
    
    @IBOutlet weak var otpCodeTF: UITextField!
    @IBOutlet weak var resendOTPBtn: UIButton!
    
    enum DestinationController: String { // next action/controller after pressing done button
        case privacySettingsVC
        case confirmTransferVC
        case confirmWithdrawalVC
        case cryptoWithdrawalVC
    }
    
    enum AdditionalParamsKey: String {
        case isSwitchingTwoFactor
    }
    
    var destinationController: DestinationController?
    var additionalParams: [AdditionalParamsKey: Any] = [:]
    
    var timer: Timer = Timer()
    var otpCountdown = 60
    
    private var viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - UI initialization
    func initUI() {
        self.setToolBarOnKeyboard(textField: self.otpCodeTF)
        self.resendOTPBtn.isHidden = true
    }
    
    // MARK: - Load data
    func initVariable() {
        
        if self.destinationController == nil {
            popOnErrorAlert("Destination controller missing")
        }
        
        self.viewModel.delegateNetworkResponse = self
        
        self.resendCode()
    }
    
    @objc func timerFunction() {
        
        self.otpCountdown -= 1
        
        self.resendOTPBtn.setTitle("Resend OTP in \(self.otpCountdown) seconds", for: .normal)
        
        if self.otpCountdown == 0 {
            self.timer.invalidate()
            self.otpCountdown = 60
            self.resendOTPBtn.isEnabled = true
            self.resendOTPBtn.setTitle("Resend OTP", for: .normal)
        }
    }
    
    // MARK: - Resend OTP button tapped
    @IBAction func resendOTPBtnTapped(_ sender: UIButton) {
        
        self.otpCodeTF.resignFirstResponder()
        
        self.resendCode()
    }
    
    // MARK: - Resend code
    func resendCode() {
        
        switch destinationController! {
            
        case .privacySettingsVC:
            self.resend2FACode()
        case .confirmTransferVC, .confirmWithdrawalVC, .cryptoWithdrawalVC:
            self.resendTransferCode()
        }
    }
    
    // MARK: - Resend transfer code
    func resendTransferCode() {
        self.showLoader()
        self.viewModel.resendTransferCode()
    }
    
    // MARK: - Resend 2FA code
    func resend2FACode() {
        
        guard let identifier = PreferencesManager.getUserModel()?.identifier else {
            popOnErrorAlert("User identifier missing")
            return
        }
        self.showLoader()
        self.viewModel.resend2FACode(identifier: identifier)
    }
    
    // MARK: - Code submit button tapped
    @IBAction func codeSubmitTapped(_ sender: UIButton) {
        
        if self.validateFields() {
            
            self.otpCodeTF.resignFirstResponder()
            
            switch destinationController! {
                
            case .privacySettingsVC:
                self.verifyOTPCode()
            case .confirmTransferVC, .confirmWithdrawalVC, .cryptoWithdrawalVC:
                self.verifyTransferCode()
            }
        }
    }
    
    // MARK: - Validate fields
    func validateFields() -> Bool {
        
        if self.otpCodeTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Code required")
            return false
        }
        
        if self.otpCodeTF.text!.count < 4 {
            Alert.sharedInstance.showAlert(title: "Error", message: "Please provide a valid code")
            return false
        }
        return true
    }
    
    // MARK: - Verify OTP code
    func verifyOTPCode() {
        
        guard let identifier = PreferencesManager.getUserModel()?.identifier else {
            popOnErrorAlert("User identifier missing")
            return
        }
        
        self.showLoader()
        
        let params = ["code": self.otpCodeTF.text!,
                      "identifier": identifier,
        ] as [String : Any]
        
        self.viewModel.verify2FA(params: params)
    }
    
    // MARK: - Verify transfer code
    func verifyTransferCode() {
        
        self.showLoader()
        
        self.viewModel.verifyTransferCode(code: self.otpCodeTF.text!)
    }
}

extension EnterOTPVC: UITextFieldDelegate {
    
    // MARK: - Limit OTP Text to 4.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.otpCodeTF {
            return textField.text!.count + (string.count - range.length) <= 4
        }
        return true
    }
}

extension EnterOTPVC: NetworkResponseProtocols {
    
    // MARK: - Resend transfer code response
    func didResendTransferCode() {
        
        self.hideLoader()
        
        self.startTimer()
        
        if self.viewModel.resendTransferCodeResponse?.isSuccess ?? false {
            self.showToast(message: self.viewModel.resendTransferCodeResponse?.message ?? "Something went wrong", toastType: .green)
        } else {
            self.showToast(message: self.viewModel.resendTransferCodeResponse?.message ?? "Something went wrong", toastType: .red)
        }
    }
    
    // MARK: - Resend 2FA code response
    func didResend2FACode() {
        
        self.hideLoader()
        
        self.startTimer()
        
        if self.viewModel.resend2FACodeResponse?.isSuccess ?? false {
            self.showToast(message: self.viewModel.resend2FACodeResponse?.message ?? "Something went wrong", toastType: .green)
        } else {
            self.showToast(message: self.viewModel.resend2FACodeResponse?.message ?? "Something went wrong", toastType: .red)
        }
    }
    
    // MARK: - Start timer
    func startTimer() {
        self.resendOTPBtn.isHidden = false
        self.resendOTPBtn.isEnabled = false
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timerFunction), userInfo: nil, repeats: true)
        self.timer.fire()
    }
    
    // MARK: - Verify 2FA response
    func didVerify2FA() {
        
        self.hideLoader()
        
        if self.viewModel.verify2FAResponse?.isSuccess ?? false {
            
            self.resendOTPBtn.isHidden = true
            
            self.delegate?.refreshPrivacySettingsScreen(turnOnTwoFactor: (self.additionalParams[.isSwitchingTwoFactor] as? Bool) ?? false)

//            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.verify2FAResponse?.message ?? "Something went wrong") { result in
//                if result {
                    self.navigationController?.popViewController(animated: true)
//                }
//            }
        } else {
            Alert.sharedInstance.alertOkWindow(title: "Error", message: self.viewModel.verify2FAResponse?.message ?? "Something went wrong") { result in
                if result {
                    self.otpCodeTF.becomeFirstResponder()
                }
            }
        }
    }
    
    // MARK: - Verify transfer code response
    func didVerifyTransferCode() {
        
        self.hideLoader()
        
        if self.viewModel.verifyTransferCodeResponse?.isSuccess ?? false {
            
            self.resendOTPBtn.isHidden = true
            
            var currentUserModel = PreferencesManager.getUserModel()
            
            currentUserModel?.isAccountVerified = true
            
            PreferencesManager.saveUserModel(user: currentUserModel)
            
//            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.verifyTransferCodeResponse?.message ?? "Something went wrong") { result in
                
//                if result {
            
            self.showToast(message: self.viewModel.verifyTransferCodeResponse?.message ?? "Something went wrong", toastType: .green)
                    
                    if self.destinationController == .confirmTransferVC {
                        self.delegate?.hitTransferAPI()
                        
                    } else if self.destinationController == .confirmWithdrawalVC {
                        self.delegate?.hitWithdrawalAPI()
                        
                    } else if self.destinationController == .cryptoWithdrawalVC {
                        self.delegate?.hitCryptoWithdrawalAPI()
                    }
                    
                    self.navigationController?.popViewController(animated: true)
//                }
//            }
            
        } else {
            Alert.sharedInstance.alertOkWindow(title: "Error", message: self.viewModel.verifyTransferCodeResponse?.message ?? "Something went wrong") { result in
                if result {
                    self.otpCodeTF.becomeFirstResponder()
                }
            }
        }
    }
}

