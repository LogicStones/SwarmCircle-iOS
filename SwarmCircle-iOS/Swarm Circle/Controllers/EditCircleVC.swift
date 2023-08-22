//
//  EditCircleVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 09/01/2023.
//

import UIKit

class EditCircleVC: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var circleImgView: UIImageView!
    @IBOutlet weak var circleNameTF: UITextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var createCircleBtn: UIButton!
    @IBOutlet weak var setPrivacyBtn: UIButton!

    let privacyOptions: [(String, UIAlertAction.Style)] = [
        ("Public", UIAlertAction.Style.default), // 1
        ("Friends", UIAlertAction.Style.default), // 2
        ("Only Members", UIAlertAction.Style.default), // 3
        ("Cancel", UIAlertAction.Style.cancel)
    ]

    var isImageUpdated = false
    var selectedPrivacyIndex: Int?
    var memberList: [CircleMemberDM] = []
    
    var circleDetail: CircleDetailDM?

    let viewModel = ViewModel()

    var delegate: AppProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }

    // MARK: - Configuring UI when loading
    func initUI() {
        
        if let imgURL = Utils.getCompleteURL(urlString: self.circleDetail?.circleImageURL) {
            self.circleImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.circleImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        guard
            let circleName = self.circleDetail?.circleName,
//            let circleCategory = self.circleDetail?.category,
            let _ = self.circleDetail?.circleID,
            let circlePrivacy = self.circleDetail?.privacy
        else {
            popOnErrorAlert("Some circle data is missing")
            return
        }
        
        self.circleNameTF.text = circleName
        self.categoryTF.text = self.circleDetail?.category ?? ""
        self.selectedPrivacyIndex = circlePrivacy
        
        self.setPrivacyBtn.setTitle(self.privacyOptions[circlePrivacy - 1].0, for: .normal)

        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.circleNameTF.keyboardType = .asciiCapable

        self.circleNameTF.delegate = self
        self.categoryTF.delegate = self
    }

    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        
        if self.memberList.isEmpty {
            self.fetchCircleMemberList()
        }
    }
    
    // MARK: - Fetch Circle Member List
    func fetchCircleMemberList() {
        
        guard let circleId = self.circleDetail?.circleID else {
            dismissOnErrorAlert("Circle ID missing")
            return
        }
        self.showLoader()
        self.viewModel.getCircleMemberList(circleId: circleId, pageNumber: 0, searchText: "")
    }

    // MARK: - Edit Circle
    func editCircle() {
        
        let editedMemberList = self.memberList.filter { member in
            (member.isSelected ?? false) == false
        }
        
//        if editedMemberList.count == self.memberList.count {
//            self.showToast(message: "You can't remove all the circle members", delay: 2, toastType: .red)
//            return
//        }
        
        if editedMemberList.isEmpty {
            self.showToast(message: "You can't remove all the circle members", delay: 2, toastType: .red)
            return
        }
        
        self.showLoader()
        
        self.viewModel.editCircleV2(id: (self.circleDetail?.circleID)!,
                                    memberIds: Utils.convertArrayToCommaSeperatedString(editedMemberList.map{ "\($0.id!)"}),
                                    circleName: Utils.encodeUTF(self.circleNameTF.text!),
                                    imageFile: self.isImageUpdated ? self.circleImgView.image?.jpeg(.low) ?? Data() : nil,
                                    circleCategory: Utils.encodeUTF(self.categoryTF.text!),
                                    privacy: self.selectedPrivacyIndex!)
    }

    // MARK: - Image Tapped
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {

        self.circleNameTF.resignFirstResponder()

        ImagePickerManager().pickImage(self) { image in

            self.isImageUpdated = true

            self.circleImgView.image = image
        }
    }

    // MARK: - Set privacy button tapped
    @IBAction func setPrivacyBtnTapped(_ sender: UIButton) {
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Audience", message: "Who can see your circle?", actions: self.privacyOptions) { index, _ in
            if index < 3 { // Set Privacy
                self.setPrivacyBtn.setTitle(self.privacyOptions[index].0, for: .normal)
                self.selectedPrivacyIndex = index + 1
            }
        }
    }

    // MARK: - Add Friends Tapped
    @IBAction func addFriendsBtnTapped(_ sender: Any) {

        self.circleNameTF.resignFirstResponder()

        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CircleMemberListVC") as? CircleMemberListVC {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.modalTransitionStyle = .crossDissolve

            vc.controllerTitle = .removeMembers
            vc.selection = .multiple
            vc.destinationController = .editCircleVC

            vc.memberList = self.memberList

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

        if self.validateEditCircle() {

            self.editCircle()
        }
    }

    // MARK: - Edit Circle Validations
    func validateEditCircle() -> Bool {

        if self.circleNameTF.text!.isEmpty {
            self.showToast(message: "Circle name is required", delay: 2, toastType: .red)
            return false
        }
        if self.categoryTF.text!.isEmpty {
            self.showToast(message: "Category name is required", delay: 2, toastType: .red)
            return false
        }
//        if self.memberList.isEmpty {
//            self.showToast(message: "Atleast 1 member is required to create circle", toastType: .red)
//            return false
//        }
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

extension EditCircleVC: NetworkResponseProtocols {
    
    // MARK: - Edit CircleV2 Response
    func didEditCircleV2() {
        
        self.hideLoader()
        
        if self.viewModel.editCircleV2Response?.isSuccess ?? false {
            
            self.delegate?.refreshCircleDetail()
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.editCircleV2Response?.message ?? "Something went wrong") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.showToast(message: "\(self.viewModel.editCircleV2Response?.message ?? "Something went wrong")", toastType: .red)
        }
    }
    
    // MARK: - Circle Member List Response
    func didGetCircleMemberList() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.circleMemberListResponse?.data {
            
            self.memberList = unwrappedList

            self.memberList.sort { a, b in // sort member list according to id, because we will use binary search to sync main list to filtered list when selecting.
                a.id! < b.id!
            }
            
        } else {
            self.dismissOnErrorAlert("\(self.viewModel.circleMemberListResponse?.message ?? "Something went wrong")")
        }
    }
}

extension EditCircleVC: UITextFieldDelegate {

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

extension EditCircleVC: AppProtocol {

    // MARK: - Set member list with updated selection in EditCircleVC after 'remove members' button is tapped in CircleMemberListVC
    func setUpdatedMemberList(memberList: [CircleMemberDM]) {
        
        self.memberList = memberList
    }
}

