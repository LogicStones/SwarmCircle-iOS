//
//  LoginVC.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import UIKit

class LoginVC: BaseViewController {
    
    @IBOutlet weak var lastButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    private func initUI() {
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back to Login"
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        viewModel.delegateNetworkResponse = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        emailTF.delegate = self
        passwordTF.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
//         show navigation bar
        navigationController?.navigationBar.isHidden = false
        
        // enable back swipe gesture
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    // handling show / hide keyboard
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            
            // get the size of keyboard
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            // checking keyboard status weather it's showing or hidden
            if isKeyboardShowing {
                print("Keyboard Showing")
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - keyboardSize.height, right: 0)
                
                self.lastButtonBottom.constant = keyboardSize.height - 35
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else{
                print("Keyboard Hidden")
                
                self.lastButtonBottom.constant = 50
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "RegisterVC") as? RegisterVC {
            
            navigationController?.pushViewController(vc, animated: true)
            //            vc.modalPresentationStyle = .fullScreen
            //            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        
        if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func loginPressed(_ sender: Any) {
        
        self.emailTF.text!.removeWhiteSpacesFromStartNEnd()
        
        if self.emailTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Email required")
            return
        }
        if !Utils.validateString(text: self.emailTF.text ?? "", with: AppConstants.emailRegex) {
            Alert.sharedInstance.showAlert(title: "Error", message: "Invalid Email")
            return
        }
        
        if self.passwordTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Password required")
            return
        }

        self.view.endEditing(true)
                        
        self.showLoader()
        
        self.postLogin(email: self.emailTF.text ?? "", password: self.passwordTF.text ?? "")
  
    }
    
    
    func postLogin(email:  String, password: String) {
        
        let params = [
            "email": email,
            "password": password,
            "signUpMethod": 1,
            "firebaseToken": PreferencesManager.getFirebaseToken(),
            "deviceType": "ios"
        ]
        as [String : Any]
        viewModel.loginUser(params: params)
    }
    
    func setTransparent() {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .clear // Your color
            appearance.shadowColor = .clear
            appearance.shadowImage = UIImage()
            navigationController?.navigationBar.standardAppearance = appearance;
            navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        } else {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default) //UIImage.init(named: "transparent.png")
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.view.backgroundColor = .clear
        }
        
    }
}

// Handling textfield return events
extension LoginVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 50), animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailTF {
            passwordTF.becomeFirstResponder()
            return true
        }
        else {
            textField.resignFirstResponder()
            return true
        }
    }
}

extension LoginVC: NetworkResponseProtocols {
    
    fileprivate func showVerifyVC(identifier: String, is2FA: Bool = false) {
        if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "VerifyVC") as? VerifyVC {
            vc.is2FA = is2FA
            vc.identifier = identifier
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func didLogin() {
        
        self.hideLoader()
        
        if !(viewModel.loginResponse?.isSuccess ?? false)  {
            
            if self.viewModel.loginResponse?.data?.tooManyAttemptRedirect ?? false {
                if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                return
            }
            
            Alert.sharedInstance.alertOkWindow(title: "Fail", message: viewModel.loginResponse?.message ?? "Invalid Credentials") { _ in
                return
            }
            return
        }
        

        
        if let is2FAEnabled = viewModel.loginResponse?.data?.isTwoFAEnabled, let isVerified = viewModel.loginResponse?.data?.isVerified {
            
            
            if !isVerified {
                
                Alert.sharedInstance.alertOkWindow(title: "Success", message: "Please verify your account first.") { result in
                    
                    if result {
                        self.showVerifyVC(identifier: self.viewModel.loginResponse?.data?.user?.identifier ?? "")
                    }
                }
            }
            else if is2FAEnabled {
                
                Alert.sharedInstance.alertOkWindow(title: "Success", message: "Two Factor Authentication is on, please verify...") { result in
                    
                    if result {
                        self.showVerifyVC(identifier: self.viewModel.loginResponse?.data?.user?.identifier ?? "", is2FA: true)
                    }
                }
            }
            else {
                
                if (viewModel.loginResponse?.isSuccess) ?? false == true {
                    
                    showToast(message: "Login was Successful", toastType: .green)
                    
                    PreferencesManager.saveUserModel(user: self.viewModel.loginResponse?.data?.user)
                    PreferencesManager.saveDiscoverableState(state: self.viewModel.loginResponse?.data?.user?.isDiscoverable ?? false)
                    PreferencesManager.saveLoginState(isLogin: true)
                    
                    self.dismiss(animated: true)
                }
                else {
                    Alert.sharedInstance.showAlert(title: "Error", message: viewModel.loginResponse?.message ?? "Some Error Occured")
                }
                
            }
        }
    }
}


