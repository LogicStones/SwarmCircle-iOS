//
//  UpdatePasswordVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 05/08/2022.
//

import UIKit

class UpdatePasswordVC: BaseViewController {
    
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastButtonBottom: NSLayoutConstraint!
    
    var identifier: String = ""
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initUI()
    }
    
    private func initUI() {
        
        if let rootVC = navigationController?.viewControllers.first {
            self.navigationController?.viewControllers = [rootVC, self]
        }
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back to Login"
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        viewModel.delegateNetworkResponse = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        newPasswordTF.delegate = self
        confirmPasswordTF.delegate = self
    }
    
    @IBAction func updatePasswordButtonClicked(_ sender: UIButton) {
        
        if self.newPasswordTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "New Password required")
            return
        }
        if !Utils.validateString(text: self.newPasswordTF.text!, with: AppConstants.passwordRegex) {
            Alert.sharedInstance.showAlert(title: "Error", message: "Passwords must be at least 8 characters and contain at 3 of 4 of the following: upper case (A-Z), lower case (a-z), number (0-9) and special character (e.g. !@#$%^&*)")
            return
        }
        
        if self.confirmPasswordTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Confirm Password required")
            return
        }
        
        if newPasswordTF.text! != confirmPasswordTF.text! {
            Alert.sharedInstance.showAlert(title: "Error", message: "Password doesn't match")
            return
        }
        
        self.view.endEditing(true)
        self.showLoader()
        self.postUpdatePassword(identifier: identifier, newPassword: newPasswordTF.text!, confirmPassword: confirmPasswordTF.text!)
    }
    
    func postUpdatePassword(identifier:  String, newPassword: String, confirmPassword: String) {
        
        let params = ["identifier": identifier,
                      "newPassword": newPassword,
                      "confirmPassword": confirmPassword
        ] as [String : Any]
        viewModel.updatePassword(params: params) // not defined in view model yet
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
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + keyboardSize.height, right: 0)
                
                self.lastButtonBottom.constant = keyboardSize.height - 20
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else{
                print("Keyboard Hidden")
                
                self.lastButtonBottom.constant = 20
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            
        }
    }
}

extension UpdatePasswordVC: UITextFieldDelegate {
    
    //    func textFieldDidBeginEditing(_ textField: UITextField) {
    //        scrollView.setContentOffset(CGPoint(x: 0, y: 25), animated: true)
    //    }
    //    func textFieldDidEndEditing(_ textField: UITextField) {
    //        scrollView.setContentOffset(CGPoint(x: 0, y: -25), animated: true)
    //    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == newPasswordTF {
            confirmPasswordTF.becomeFirstResponder()
        }
        else {
            confirmPasswordTF.resignFirstResponder()
        }
        return true
    }
}

extension UpdatePasswordVC: NetworkResponseProtocols {
    
    func didUpdatePassword() {
        
        self.hideLoader()
        
        if let response = viewModel.updatePasswordResponse {
            
            if (response.isSuccess ?? false) == true {
                
                Alert.sharedInstance.alertOkWindow(title: "Success", message: "Password updated successfully, please login to continue.") { result in
                    if result {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                }
            }
            else {
                Alert.sharedInstance.showAlert(title: "Error", message: response.message ?? "Some Error Occured")
            }
        }
    }
}
