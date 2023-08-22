//
//  AddSocialLinksVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 24/08/2022.
//

import UIKit

class AddSocialLinksVC: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var facebookTF: UITextField!
    @IBOutlet weak var twitterTF: UITextField!
    @IBOutlet weak var youtubeTF: UITextField!
    @IBOutlet weak var instagramTF: UITextField!
    
    var delegate: AppProtocol?
    
    var currentFacebookLink: String?
    var currentTwitterLink: String?
    var currentInstagramLink: String?
    var currentYoutubeLink: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    func initUI() {
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let urlString = self.currentFacebookLink {
            //            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
//            if urlString.isValidURLString {
                if let _ = URL(string: urlString) {
                    self.facebookTF.text = urlString
                }
//            }
        }
        if let urlString = self.currentTwitterLink {
            //            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
//            if urlString.isValidURLString {
                if let _ = URL(string: urlString) {
                    self.twitterTF.text = urlString
                }
//            }
        }
        if let urlString = self.currentYoutubeLink {
            //            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
//            if urlString.isValidURLString {
                if let _ = URL(string: urlString) {
                    self.youtubeTF.text = urlString
                }
//            }
        }
        if let urlString = self.currentInstagramLink {
            //            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
//            if urlString.isValidURLString {
                if let _ = URL(string: urlString) {
                    self.instagramTF.text = urlString
                }
//            }
        }
    }
    
    @IBAction func crossPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func addBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.validateFields() {
            
            self.dismiss(animated: true) {
                self.delegate?.updateSocialLink(facebookLink: self.facebookTF.text! == self.currentFacebookLink ?? "" ? nil : self.facebookTF.text!, twitterLink: self.twitterTF.text! == self.currentTwitterLink ?? "" ? nil : self.twitterTF.text!, youtubeLink: self.youtubeTF.text! == self.currentYoutubeLink ?? "" ? nil : self.youtubeTF.text!, instagramLink: self.instagramTF.text! == self.currentInstagramLink ?? "" ? nil : self.instagramTF.text!)
            }
        }
    }
    
    // MARK: - Validate Fields
    func validateFields() -> Bool {
        
        if !self.facebookTF.text!.isEmpty {
            if !self.facebookTF.text!.contains("acebook") {
                self.showToast(message: "Invalid Facebook Url", toastType: .red)
                return false
            }
//            if !self.facebookTF.text!.isValidURLString {
//                self.showToast(message: "Invalid Facebook Url", toastType: .red)
//                return false
//            }
            if URL(string: self.facebookTF.text!) == nil {
                self.showToast(message: "Invalid Facebook Url", toastType: .red)
                return false
            }
        }
        
        if !self.twitterTF.text!.isEmpty {
            if !self.twitterTF.text!.contains("witter") {
                self.showToast(message: "Invalid Twitter Url", toastType: .red)
                return false
            }
//            if !self.twitterTF.text!.isValidURLString {
//                self.showToast(message: "Invalid Twitter Url", toastType: .red)
//                return false
//            }
            if URL(string: self.twitterTF.text!) == nil {
                self.showToast(message: "Invalid Twitter Url", toastType: .red)
                return false
            }
        }
        
        if !self.youtubeTF.text!.isEmpty {
            if !self.youtubeTF.text!.contains("outube") {
                self.showToast(message: "Invalid Youtube Url", toastType: .red)
                return false
            }
//            if !self.youtubeTF.text!.isValidURLString {
//                self.showToast(message: "Invalid Youtube Url", toastType: .red)
//                return false
//            }
            if URL(string: self.youtubeTF.text!) == nil {
                self.showToast(message: "Invalid Youtube Url", toastType: .red)
                return false
            }
        }
        
        if !self.instagramTF.text!.isEmpty {
            if !self.instagramTF.text!.contains("nstagram") {
                self.showToast(message: "Invalid Instagram Url", toastType: .red)
                return false
            }
//            if !self.instagramTF.text!.isValidURLString {
//                self.showToast(message: "Invalid Instagram Url", toastType: .red)
//                return false
//            }
            if URL(string: self.instagramTF.text!) == nil {
                self.showToast(message: "Invalid Instagram Url", toastType: .red)
                return false
            }
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
                self.lastBottomConstraint.constant = keyboardSize.height - (view.frame.height * 0.15) + 30
            } else {
                print("Keyboard Hidden")
                self.lastBottomConstraint.constant = 30
            }
            
            view.layoutIfNeeded()
            
        }
    }
}
