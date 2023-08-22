//
//  ContactUsVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 15/11/2022.
//

import UIKit
import FlagPhoneNumber

class ContactUsVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: FPNTextField!
    @IBOutlet weak var subjectTF: UITextField!
    @IBOutlet weak var descriptionTV: UITextView!
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        self.nameTF.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
        self.emailTF.text = PreferencesManager.getUserModel()?.email ?? ""
        self.phoneTF.set(phoneNumber: PreferencesManager.getUserModel()?.phoneNo ?? "")
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        self.descriptionTV.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 7.5)
        
        self.subjectTF.delegate = self
        self.descriptionTV.delegate = self
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
    }
    
    // MARK: - Save Contact Us
    func saveContactUs() {
        
        let params: [String: Any] =
        [
            "fullName": self.nameTF.text!,
            "email": self.emailTF.text!,
            "phoneNo": self.phoneTF.text!,
            "subjectText": self.subjectTF.text!,
            "messageText": self.descriptionTV.text!,
        ]
        
        self.showLoader()
        
        self.viewModel.contactUs(params: params)
    }
    
    // MARK: - Submit Button Tapped
    @IBAction func submitBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.subjectTF.text!.removeWhiteSpacesFromStartNEnd()
        self.subjectTF.text!.condenseWhitespace()
        self.descriptionTV.text.removeWhiteSpacesFromStartNEnd()
        self.descriptionTV.text.removeNewLinesFromStartNEnd()
        self.descriptionTV.text!.condenseWhitespace()
        
        if self.validateFields() {
            self.saveContactUs()
        }
    }
    
    // MARK: - Validate Fields
    func validateFields() -> Bool {
        
        if self.subjectTF.text!.isEmpty {
            self.showToast(message: "Subject required", toastType: .red)
            return false
        }
        if self.subjectTF.text!.count < 5 {
            self.showToast(message: "Minimum 5 character required for subject", toastType: .red)
            return false
        }
        
        self.descriptionTV.text = self.descriptionTV.text == "Your Message" ? "" : self.descriptionTV.text
        
        if self.descriptionTV.text!.isEmpty {
            self.showToast(message: "Description required", toastType: .red)
            self.descriptionTV.text = "Your Message"
            return false
        }
        if self.descriptionTV.text!.count < 30 {
            self.showToast(message: "Minimum 30 character required for description", toastType: .red)
            return false
        }
        
        return true
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
                
                self.lastBottomConstraint.constant = keyboardSize.height
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else {
                print("Keyboard Hidden")
                
                self.lastBottomConstraint.constant = 20
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            
        }
    }
}

extension ContactUsVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return textField.text!.count + (string.count - range.length) <= 100
    }
}

extension ContactUsVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count > 1000 {
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Your Message" {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Your Message"
        }
    }
}


extension ContactUsVC: NetworkResponseProtocols {
    
    func didContactUs() {
        
        self.hideLoader()
        
        if self.viewModel.contactUsResponse?.isSuccess ?? false {
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.contactUsResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        else {
            self.showToast(message: self.viewModel.contactUsResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
}
