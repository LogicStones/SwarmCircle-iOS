//
//  CreateCircleVC.swift
//  Swarm Circle
//
//  Created by Macbook on 05/07/2022.
//

import UIKit

class CreateCircleVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var circleImgView: UIImageView!
    @IBOutlet weak var circleNameTF: UITextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var createCircleBtn: UIButton!
    @IBOutlet weak var setPrivacyBtn: UIButton!
    
    var privacyOptions: [(String, UIAlertAction.Style)] = [
        ("Public", UIAlertAction.Style.default),
        ("Friends", UIAlertAction.Style.default),
        ("Only Members", UIAlertAction.Style.default),
        ("Cancel", UIAlertAction.Style.cancel)
    ]
    
    var isImageSelected = false
    var selectedPrivacyIndex: Int?
//    var selectedFriends = ArrayWrapper<FriendDM>(array: [])
    var friendListSelected: [FriendDM] = []
    
    let viewModel = ViewModel()
    var SelctedSubscriptionID = 0
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.circleNameTF.keyboardType = .asciiCapable
        self.categoryTF.keyboardType = .asciiCapable
        
        self.circleNameTF.delegate = self
        self.categoryTF.delegate = self
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.getSubscriptionData()
    }
    
    func getSubscriptionData() {
        
        self.showLoader()
        self.viewModel.getSubscriptionDetails()
    }
    
    // MARK: - Create Circle
    func createCircle() {
        
        self.showLoader()
        
//        let stringArray = selectedFriends.array.map { selectedFriend in
//            return selectedFriend.id
//
//        }.map({ String($0!) })
        
//        self.viewModel.createCircleV2(memberIds: stringArray.joined(separator: ","), circleName: Utils.encodeUTF(self.circleNameTF.text!), imageFile: self.circleImgView.image?.jpeg(.low) ?? Data(), circleCategory: Utils.encodeUTF(self.categoryTF.text!), privacy: self.selectedPrivacyIndex!)
        
        self.viewModel.createCircleV2(memberIds: Utils.convertArrayToCommaSeperatedString(self.friendListSelected.map{ $0.id! }), circleName: Utils.encodeUTF(self.circleNameTF.text!), imageFile: self.circleImgView.image?.jpeg(.low) ?? Data(), circleCategory: Utils.encodeUTF(self.categoryTF.text!), privacy: self.selectedPrivacyIndex!)
    }
    
    // MARK: - Image Tapped
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        
        self.circleNameTF.resignFirstResponder()
        
        ImagePickerManager().pickImage(self) { image in
            
            self.isImageSelected = true

            self.circleImgView.image = image
        }
    }
    
    // MARK: - Set privacy button tapped
    @IBAction func setPrivacyBtnTapped(_ sender: UIButton) {
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Audience", message: "Who can see your circle?", actions: self.privacyOptions) { index, _ in
            let selectedIndex = self.SelctedSubscriptionID > 1 ? 3 : 1
            if index < selectedIndex { // Set Privacy
                self.setPrivacyBtn.setTitle(self.privacyOptions[index].0, for: .normal)
                self.selectedPrivacyIndex = index + 1
            }
        }
    }
    
    // MARK: - Add Friends Tapped
    @IBAction func addFriendsBtnTapped(_ sender: Any) {
        
        self.circleNameTF.resignFirstResponder()
        
//        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "FriendsListVC") as? FriendsListVC {
//            let navigationController = UINavigationController(rootViewController: vc)
//            navigationController.modalPresentationStyle = .overFullScreen
//            navigationController.modalTransitionStyle = .crossDissolve
//            vc.selectedFriends = selectedFriends
//            self.present(navigationController, animated: true)
//        }
        
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "FriendListVC") as? FriendListVC {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.modalTransitionStyle = .crossDissolve
            
            vc.controllerTitle = .addFriends
            vc.selection = .multiple
            vc.destinationController = .createCircleVC
//            vc.additionalParams = additionalParameters
            
            vc.friendListSelected = self.friendListSelected

            vc.delegate = self
            
            self.present(navigationController, animated: true)
        }
    }
    
    // MARK: - Create Circle Tapped
    @IBAction func createCircleTapped(_ sender: Any) {
        
        self.circleNameTF.text!.removeWhiteSpacesFromStartNEnd()
        self.circleNameTF.text!.condenseWhitespace()
        
        self.categoryTF.text!.removeWhiteSpacesFromStartNEnd()
        self.categoryTF.text!.condenseWhitespace()
        
        if self.validateCreateCircle() {
            
            self.createCircle()
        }
    }
    
    // MARK: - Create Circle Validations
    func validateCreateCircle() -> Bool {
        
        if !self.isImageSelected {
            self.showToast(message: "Image is required", delay: 2, toastType: .red)
            return false
        }
        if self.circleNameTF.text!.isEmpty {
            self.showToast(message: "Circle name is required", delay: 2, toastType: .red)
            return false
        }
        if self.categoryTF.text!.isEmpty {
            self.showToast(message: "Category name is required", delay: 2, toastType: .red)
            return false
        }
        if self.selectedPrivacyIndex == nil {
            self.showToast(message: "Circle privacy is required", delay: 2, toastType: .red)
            return false
        }
        if self.friendListSelected.isEmpty {
            self.showToast(message: "Atleast 1 member is required to create circle", toastType: .red)
            return false
        }
        return true
    }
        
    // handling show / hide keyboard
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            // get the size of keyboard
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            // checking keyboard status weather it's showing or hidden
            if isKeyboardShowing {
                print("Keyboard Showing")
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - keyboardSize.height, right: 0)
                
                self.lastBottomConstraint.constant = keyboardSize.height - 30
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else{
                print("Keyboard Hidden")
                
                self.lastBottomConstraint.constant = 20
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            view.layoutSubviews()
        }
    }
}

extension CreateCircleVC: NetworkResponseProtocols {
    
    // MARK: - Create Circle Response
    func didCreateCircle() {
        
        self.hideLoader()
        
        if self.viewModel.createCircleResponse?.isSuccess ?? false {
            
            self.delegate?.refreshCircleList()
            
            self.showToast(message: "\(viewModel.createCircleResponse?.message ?? "Something went wrong")", toastType: .green)
            self.resetFields()
            
        } else {
            self.showToast(message: "\(viewModel.createCircleResponse?.message ?? "Something went wrong")", toastType: .red)
        }
    }
    
    // MARK: - Create CircleV2 Response
    func didCreateCircleV2() {
        
        self.hideLoader()
        
        if self.viewModel.createCircleV2Response?.isSuccess ?? false {
            
            self.delegate?.refreshCircleList()
            
            self.showToast(message: "\(viewModel.createCircleV2Response?.message ?? "Something went wrong")", toastType: .green)
            self.resetFields()
            
        } else {
            self.showToast(message: "\(viewModel.createCircleV2Response?.message ?? "Something went wrong")", toastType: .red)
        }
    }
    
    // MARK: - Reset All Fields
    func resetFields() {
        self.isImageSelected = false
        self.circleImgView.image = UIImage(named: "selectProfile")
        self.circleNameTF.text = ""
        self.categoryTF.text = ""
//        self.selectedFriends.array = []
        self.friendListSelected = []
    }
    
    func didGetSubscriptionDetails() {
        self.hideLoader()

        if self.viewModel.getSubscriptionDetailsResponse?.isSuccess ?? false {
            if let subsdetails = self.viewModel.getSubscriptionDetailsResponse?.data
            {
                if let id = subsdetails.id
                {
                    self.SelctedSubscriptionID = id
                    if id == 1
                    {
                        self.privacyOptions.remove(at: 1)
                        self.privacyOptions.remove(at: 1)
                    }
                }
            }
            else
            {
                self.showToast(message: self.viewModel.getSubscriptionDetailsResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            }
        }
    }
}

extension CreateCircleVC: UITextFieldDelegate {
    
    // MARK: - Done Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case self.circleNameTF:
            self.categoryTF.becomeFirstResponder()
        case self.categoryTF:
            self.categoryTF.resignFirstResponder()
        default:
            self.view.endEditing(true) // will never be executed because both textField in this controller is handled.
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text!.isEmpty && (string == " ") { // also check if first character of string is a special character
            return false
        }
        if textField.text!.count + string.count > 100 {
            return false
        }
        return true
    }
}

extension CreateCircleVC: AppProtocol {
    
    // MARK: - Update selected friend list in CreateCircleVC after done button is tapped in FriendListVC
    func updateSelectedFriendList(friendListSelected: [FriendDM]) {
        self.friendListSelected = friendListSelected
    }
}

