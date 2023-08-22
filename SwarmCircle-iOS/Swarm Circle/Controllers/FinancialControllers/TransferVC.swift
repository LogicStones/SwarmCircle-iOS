//
//  TransferVC.swift
//  Swarm Circle
//
//  Created by Macbook on 18/07/2022.
//

import UIKit

class TransferVC: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var receiverWalletIdTF: UITextField!
    @IBOutlet weak var selectFriendBtnView: UIView!
    @IBOutlet weak var selectedFriendButtonViewHeightConstraint: NSLayoutConstraint!
    
    var isTransferFromCircle = false
    
    var selectedFriend = ValueWrapper<FriendDM?>(value: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUI()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Transfer"
    }
    
    func initUI() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        self.amountTF.delegate =  self
        
        setToolBarOnKeyboard(textField: amountTF)
        
        // if friend is already selected then hide the 'select friend' button 
        if selectedFriend.value != nil {
            self.selectFriendBtnView.isHidden = true
            receiverWalletIdTF.text = selectedFriend.value?.walletID ?? ""
            self.selectedFriendButtonViewHeightConstraint.constant = 0
        }
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
    
    @IBAction func selectFriendTapped(_ sender: Any) {
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "FriendsListVC") as? FriendsListVC {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalTransitionStyle = .crossDissolve
            navigationController.modalPresentationStyle = .overFullScreen
            vc.isSingleSelection = true
            vc.selectedFriend = self.selectedFriend
            vc.delegate = self
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    @IBAction func doneBtnTapped(_ sender: UIButton) {
        
        self.amountTF.resignFirstResponder()
        
        if amountTF.text!.isEmpty {
            self.showToast(message: "Amount required", toastType: .red)
            return
        } else if Double(amountTF.text!)! <= 0 {
            self.showToast(message: "Please enter an amount greater than 0", toastType: .red)
            return
        }
        if receiverWalletIdTF.text!.isEmpty {
            self.showToast(message: "No Friend selected", toastType: .red)
            return
        }
        
        if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "ConfirmTransferVC") as? ConfirmTransferVC {
            vc.receiverInfo = self.selectedFriend
            vc.amount = Double(self.amountTF.text!)!
            vc.isTransferFromCircle = self.isTransferFromCircle
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - TextField Configuration
extension TransferVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
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
        
        if string != "" {
            if "\(textField.text!)\(string)".split(separator: ".")[0].count > 8 {
                return false
            }
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
        
        return true
    }
    
    // MARK: - Dismiss keyboard on Done button Tapped
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}

extension TransferVC: AppProtocol {
    
    // MARK: - Set Friend (Receiver) Wallet id (in TextField) in TransferVC after a friend is selected in FriendsListVC.
    func setReceiverWalletId() {
        guard let walletId = self.selectedFriend.value?.walletID else {
            return
        }
        self.receiverWalletIdTF.text = walletId
    }
    
    // MARK: - Set Friend (Receiver) Wallet id (in TextField) in TransferVC after a friend is selected in FriendListVC.
    func setReceiverWalletId(selectedFriend: FriendDM?) {
        guard let walletId = selectedFriend?.walletID else {
            return
        }
        self.receiverWalletIdTF.text = walletId
    }
}
