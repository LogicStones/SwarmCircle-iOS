//
//  VerifyVC.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import UIKit

class VerifyVC: BaseViewController {
    
    @IBOutlet weak var otpCodeTF: UITextField!
    @IBOutlet weak var descriptionLBL: UILabel!
    
    var didForgetPassword: Bool = false
    var is2FA: Bool = false
    var identifier: String = ""
    var isPhoneOTP: Bool = false
    var isFromRegister: Bool = false
    
    private var viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//
////         hide navigation bar
//        navigationController?.navigationBar.isHidden = false
//
//        // disable back swipe gesture
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//    }
    
    
    func initUI() {
        
        if !isFromRegister{
            if let rootVC = self.navigationController?.viewControllers.first {
                self.navigationController?.viewControllers = [rootVC, self]
            }
        }
        
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back to Login" // This will set back title of all the controllers pushing to current controller.
//        self.navigationController?.navigationBar.backItem?.backButtonTitle = "Back to Login" // This will set back title of current controller.
        
        self.descriptionLBL.text = self.isPhoneOTP ? "A 4-digit code has been sent to your registered phone number." : "A 4-digit code has been sent to your registered email address."
        
        viewModel.delegateNetworkResponse = self
        setToolBarOnKeyboard(textField: otpCodeTF)
    }

    @IBAction func codeSubmitTapped(_ sender: Any) {
        
        if self.otpCodeTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Code required")
            return
        }
        
        
        if otpCodeTF.text!.count == 4 {
            
            self.view.endEditing(true)
            
            self.showLoader()
            
            if is2FA {
                self.post2FAVerify(code: otpCodeTF.text!)
            }
            else if didForgetPassword {
                self.postForgetPasswordVerify(code: otpCodeTF.text!)
            }
            else {
                self.postEmailVerify(code: otpCodeTF.text!)
            }
        }
        else {
            Alert.sharedInstance.showAlert(title: "Error", message: "Please provide a valid code")
        }
    }
    
    func post2FAVerify(code: String) {
        
        let params = ["code": code,
                      "identifier": identifier,
                      "firebaseToken": PreferencesManager.getFirebaseToken(),
                      "deviceType": "ios"
        ] as [String : Any]
        viewModel.verify2FA(params: params)
    }
    func postForgetPasswordVerify(code: String) {
        
        let params = ["code": code,
                      "identifier": identifier
        ] as [String : Any]
        viewModel.verifyForgetPassword(params: params)
    }
    func postEmailVerify(code: String) {
        
        let params = ["code": code,
                      "identifier": identifier
        ] as [String : Any]
        viewModel.verifyEmail(params: params)
    }
}


extension VerifyVC: UITextFieldDelegate {
    
    // MARK: - Limit OTP Text to 4.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == otpCodeTF {
            return textField.text!.count + (string.count - range.length) <= 4
        }
        return true
    }
}

extension VerifyVC: NetworkResponseProtocols {
    
    func didVerify2FA() {
        
        self.hideLoader()
        
        if let response = viewModel.verify2FAResponse {
            
            if (response.isSuccess ?? false) == true {
                
                PreferencesManager.saveUserModel(user: response.data?.user)
                PreferencesManager.saveDiscoverableState(state: response.data?.user?.isDiscoverable ?? false)
                PreferencesManager.saveLoginState(isLogin: true)
                
                if self.is2FA {
                    
                    self.dismiss(animated: true)
                    
                } else {
                    
                    if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "VerifiedVC") as? VerifiedVC {
                        vc.didVerified2FA = true
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
            else {
                Alert.sharedInstance.showAlert(title: "Error", message: response.message ?? "Some Error Occured")
            }
        }
    }
    
    func didVerifyForgetPAssword() {
        
        self.hideLoader()
        
        if let response = viewModel.verifyForgetPasswordResponse {
            if (response.isSuccess ?? false) {
                
                // Go to update password VC to create new password.
                if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "UpdatePasswordVC") as? UpdatePasswordVC {
                    vc.identifier = self.identifier
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                Alert.sharedInstance.showAlert(title: "Error", message: response.message ?? "Some Error Occured")
            }
        }
    }
    
    func didVerifyEmail() {
        
        self.hideLoader()
        
        if let response = viewModel.verifyEmailResponse {
            
            if (response.isSuccess ?? false) == true {
                
                if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "VerifiedVC") as? VerifiedVC {
                    vc.didVerified2FA = false
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            else {
                Alert.sharedInstance.showAlert(title: "Error", message: response.message ?? "Some Error Occured")
            }
        }
    }
}

