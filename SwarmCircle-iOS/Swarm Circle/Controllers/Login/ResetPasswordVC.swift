//
//  ResetPasswordVC.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import UIKit
import FlagPhoneNumber

class ResetPasswordVC: BaseViewController {
    
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: FPNTextField!
    @IBOutlet weak var resetViaBtn: UIButton!
    
    var currentCountryCode = ""
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    private func initUI() {
        
        self.viewModel.delegateNetworkResponse = self
        
        self.emailTF.delegate = self
        self.phoneTF.delegate = self
        
        setToolBarOnKeyboard(textField: self.phoneTF)
        
        self.phoneTF.setFlag(key: .US)
        self.currentCountryCode = self.phoneTF.selectedCountry!.phoneCode
    }
    
    // MARK: - Reset Via Button Tapped
    @IBAction func resetViaBtnTapped(_ sender: UIButton) {
        
        // unselected = button text -> Reset Via SMS (initial state)
        // selected = button text -> Reset Via Email Address
        
        self.resetViaBtn.isSelected = !self.resetViaBtn.isSelected
        
        self.emailView.isHidden = !self.resetViaBtn.isSelected
        self.phoneView.isHidden = self.resetViaBtn.isSelected
        
        if self.resetViaBtn.isSelected { // textfield is phone
            self.emailTF.resignFirstResponder()
            self.emailTF.text = ""
            self.phoneTF.becomeFirstResponder()
            self.emailView.isHidden = true
            self.phoneView.isHidden = false
            
        } else { // textfield is email
            self.phoneTF.resignFirstResponder()
            self.phoneTF.text = ""
            self.emailTF.becomeFirstResponder()
            self.phoneView.isHidden = true
            self.emailView.isHidden = false
        }
    }
    
    @IBAction func resetPasswordButtonClicked(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.resetViaBtn.isSelected { // textfield is phone
            if self.phoneTF.text!.isEmpty {
                Alert.sharedInstance.showAlert(title: "Error", message: "Phone required")
                return
            }
            if !Utils.validatePhoneNumber(flagPhoneNumberTextField: self.phoneTF) {
                Alert.sharedInstance.showAlert(title: "Invalid Phone", message: "Please provide a valid phone number")
                return
            }
            self.showLoader()
            self.postForgotPassword(emailOrPhone: self.phoneTF.text!)
            
        } else { // textfield is email
            if self.emailTF.text!.isEmpty {
                Alert.sharedInstance.showAlert(title: "Error", message: "Email required")
                return
            }
            if !Utils.validateString(text: self.emailTF.text!, with: AppConstants.emailRegex) {
                Alert.sharedInstance.showAlert(title: "Error", message: "Invalid Email")
                return
            }
            self.showLoader()
            self.postForgotPassword(emailOrPhone: self.emailTF.text!)
        }
    }
    
    func postForgotPassword(emailOrPhone: String) {
        
        // unselected = button text -> Reset Via SMS (initial state)
        // selected = button text -> Reset Via Email Address
        
        if self.resetViaBtn.isSelected { // sms = true -> isRecoveryTypePhone = true
            
            let params = [
                "phoneNo": emailOrPhone,
                "isRecoveryTypePhone": true
            ] as [String : Any]
            
            self.viewModel.forgotPassword(params: params)
            
        } else { // email
            
            let params = [
                "email": emailOrPhone,
            ] as [String : Any]
            
            self.viewModel.forgotPassword(params: params)
        }
    }
}

extension ResetPasswordVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTF.resignFirstResponder()
    }
}

extension ResetPasswordVC: NetworkResponseProtocols {
    
    func didSendForgotPasswordRequest() {
        
        self.hideLoader()
        
        if let response = viewModel.forgotPasswordResponse {
            
            if (response.isSuccess ?? false) == true {
                Alert.sharedInstance.alertOkWindow(title: "Success", message: response.message ?? "Something went wrong") { result in
                    
                    if result {
                        if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "VerifyVC") as? VerifyVC {
                            vc.didForgetPassword = true
                            vc.isPhoneOTP = self.resetViaBtn.isSelected
                            vc.identifier = response.data?.identifier ?? ""
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
                    }
                }
            }
            else {
                Alert.sharedInstance.showAlert(title: "Error", message: response.message ?? "Some Error Occured")
            }
        }
    }
}

extension ResetPasswordVC: FPNTextFieldDelegate {
    
    func fpnDidSelectCountry(name: String, dialCode: String, code: String) {
        if dialCode != self.currentCountryCode {
            self.phoneTF.text = ""
            self.currentCountryCode = dialCode
        }
    }
    
    func fpnDidValidatePhoneNumber(textField: FlagPhoneNumber.FPNTextField, isValid: Bool) {
        //
    }
    
    func fpnDisplayCountryList() {
        //
    }
}
