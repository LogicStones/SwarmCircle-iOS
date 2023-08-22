//
//  ChangePasswordVC.swift
//  Swarm Circle
//
//  Created by Macbook on 06/07/2022.
//

import UIKit

class ChangePasswordVC: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var currentPasswordTF: UITextField!
    @IBOutlet weak var newPasswordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    func initUI() {
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.currentPasswordTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Current Password Required")
            return
        }
        
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

        self.postChangePassword()
    }
    
    func postChangePassword() {
        
        self.showLoader()
        
        let params = ["currentPassword": self.currentPasswordTF.text!,
                      "newPassword": self.newPasswordTF.text!,
                      "confirmPassword": self.confirmPasswordTF.text!
        ] as [String : Any]
        
        self.viewModel.changePassword(params: params)
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
                
                self.lastBottomConstraint.constant = keyboardSize.height + 10
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else{
                print("Keyboard Hidden")
                
                self.lastBottomConstraint.constant = 20
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            
        }
    }
}

extension ChangePasswordVC: NetworkResponseProtocols {
    
    func didChangePassword() {
        
        self.hideLoader()
        
        if self.viewModel.changePasswordResponse?.isSuccess ?? false {
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.changePasswordResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } else {
            self.showToast(message: self.viewModel.changePasswordResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
}
