//
//  EditProfileVC.swift
//  Swarm Circle
//
//  Created by Macbook on 06/07/2022.
//

import UIKit
import FlagPhoneNumber

class EditProfileVC: BaseViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addInterestBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var interestTxtField: UITextField!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profilePicImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    @IBOutlet weak var idLbl: UILabel!
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var phoneTF: FPNTextField!
    @IBOutlet weak var saveChangesBtn: UIButton!
    
    var oldProfilePic: UIImage?
    
    var tagsList: [String] = []
    
    var userDetails: UserDetailDM?
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    var currentCountryCode = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Edit Profile"
    }
    
    func initUI() {
        
        saveChangesBtn.isEnabled = false
        
        self.emailTF.isEnabled = false
        
        self.phoneTF.delegate = self

        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.collectionView.register(UINib(nibName: "InterestsTagCell", bundle: nil), forCellWithReuseIdentifier: "InterestsTagCell")
        
        self.phoneTF.setFlag(key: .US)
        self.currentCountryCode = self.phoneTF.selectedCountry!.phoneCode
        
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        
        showLoader()
        self.getUserDetails()
    }
    
    // MARK: - Get User Details
    func getUserDetails() {
        self.viewModel.getUserDetails()
    }
    
    // MARK: - Update Profile
    func updateProfile() {
        
        self.showLoader()
        
        self.viewModel.updateProfile(userDetail: self.userDetails!)
    }
    
    // MARK: - Upload Image Button Tapped
    @IBAction func uploadImgBtnTapped(_ sender: UIButton) {
        
        ImagePickerManager().pickImage(self) { image in
            self.profilePicImgView.image = image
        }
    }
    // MARK: - Set User Detail in Fields
    func setUserDetails() {
 
        self.nameLbl.text = "\(self.userDetails!.firstName!.capitalized) \(self.userDetails!.lastName!.capitalized)"
        
        self.isVerifiedIcon.isHidden = !(self.userDetails!.isAccountVerified ?? false)
        
        self.idLbl.text = "\(PreferencesManager.getUserModel()?.userID ?? "")"
        
        self.profilePicImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: self.userDetails!.displayImageURL) {
            self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage")) { _ in
                self.oldProfilePic = self.profilePicImgView.image
                self.saveChangesBtn.isEnabled = true
            }
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // Force Enable save changes button after 3 seconds of response, even if profile image is not retrieved.
            self.saveChangesBtn.isEnabled = true
        }
        
        self.firstNameTF.text = self.userDetails!.firstName!.capitalized
        self.lastNameTF.text = self.userDetails!.lastName!.capitalized
        self.emailTF.text = self.userDetails!.emailAddress ?? ""
        self.phoneTF.set(phoneNumber: self.userDetails!.phoneNumber!)
        
        if let tags = self.userDetails?.tag {
            self.tagsList.append(contentsOf: Utils.convertCommaSeperatedStringToStringArray(tags))
            self.collectionView.reloadData()
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
    
    @IBAction func clipboardBtnTapped(_ sender: UIButton) {
        
        UIPasteboard.general.string = "\(PreferencesManager.getUserModel()?.userID ?? "")"
        self.showToast(message: "User Id copied to clipboard", delay: 0.75, toastType: .black)
    }
    
    @IBAction func editAvatarPressed(_ sender: Any) {
        self.view.endEditing(true)
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "MyAvatarVC") as? MyAvatarVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func changePasswordPressed(_ sender: Any) {
        self.view.endEditing(true)
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "ChangePasswordVC") as? ChangePasswordVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func addSocialLinksPressed(_ sender: UIButton) {
        self.view.endEditing(true)
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "AddSocialLinksVC") as? AddSocialLinksVC {
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            vc.delegate = self
            vc.currentInstagramLink = self.userDetails?.instagramLink
            vc.currentYoutubeLink = self.userDetails?.youtubeLink
            vc.currentTwitterLink = self.userDetails?.twitterLink
            vc.currentFacebookLink = self.userDetails?.facebookLink
            self.present(vc, animated: true)
        }
    }
    
    // MARK: - Save Button Tapped
    @IBAction func saveChangesPressed(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.firstNameTF.text?.removeWhiteSpacesFromStartNEnd()
        self.lastNameTF.text?.removeWhiteSpacesFromStartNEnd()
        self.phoneTF.text?.removeWhiteSpacesFromStartNEnd()
        
        self.firstNameTF.text?.condenseWhitespace()
        self.lastNameTF.text?.condenseWhitespace()
        
        if self.validateFields() {
            
//            Alert.sharedInstance.alertWindow(title: "Save Changes", message: "Are you sure you want to save your changes? Choosing 'Yes' will refresh the App.") { result in
                
//                if result {

                    self.userDetails?.firstName = self.firstNameTF.text!
                    self.userDetails?.lastName = self.lastNameTF.text!
            
            let phoneNumber = "\(phoneTF.selectedCountry!.phoneCode)\(phoneTF.text!)".replacingOccurrences(of: " ", with: "")
            
                    self.userDetails?.phoneNumber = phoneNumber
                    
                    let tagListString = Utils.convertArrayToCommaSeperatedString(self.tagsList)
                    let oldTagList = self.userDetails?.tag ?? ""
                    
                    self.userDetails?.tag = tagListString == oldTagList ? nil : tagListString
                    
                    self.userDetails?.imageFile = self.oldProfilePic == self.profilePicImgView.image ? nil : self.profilePicImgView.image?.jpeg(.low)
                    
                    self.updateProfile()
//                }
//            }
            
            // if updating phone number open enter otp screen.
//            if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "EnterOTPVC") as? EnterOTPVC {
//    //            vc.delegate = self
//
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
        }
    }
    
    // MARK: - Validate Fields
    func validateFields() -> Bool {
        
        if self.firstNameTF.text!.isEmpty {
            self.showToast(message: "First name required", toastType: .red)
            return false
        }
        if self.firstNameTF.text!.count < 2 {
            self.showToast(message: "First name should be atleast 2 characters long.", toastType: .red)
            return false
        }
        if Utils.validateString(text: self.firstNameTF.text!.replacingOccurrences(of: " ", with: ""), with: AppConstants.specialCharacterRegex) {
            self.showToast(message: "First name cannot contain special characters", toastType: .red)
            return false
        }
        if self.lastNameTF.text!.isEmpty {
            self.showToast(message: "Last name required", toastType: .red)
            return false
        }
        if self.lastNameTF.text!.count < 2 {
            self.showToast(message: "Last name should be atleast 2 characters long.", toastType: .red)
            return false
        }
        if Utils.validateString(text: self.lastNameTF.text!.replacingOccurrences(of: " ", with: ""), with: AppConstants.specialCharacterRegex) {
            self.showToast(message: "Last name cannot contain special characters", toastType: .red)
            return false
        }
        if self.phoneTF.text!.isEmpty {
            self.showToast(message: "Phone Number name required", toastType: .red)
            return false
        }
        if !Utils.validatePhoneNumber(flagPhoneNumberTextField: self.phoneTF) {
            Alert.sharedInstance.showAlert(title: "Invalid Phone", message: "Please provide a valid phone number")
            return false
        }
//        if self.phoneTF.text!.count != 12 {
//            self.showToast(message: "Phone Number should be 12-digits", toastType: .red)
//            return false
//        }
        return true
    }
    
    // MARK: - Add interest i.e (Add Tags) Button Tapped
    @IBAction func addInterestPressed(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.interestTxtField.text!.removeWhiteSpacesFromStartNEnd()
        
        if self.interestTxtField.text!.count < 3 {
            self.showToast(message: "Tag should be a minimum of 3 characters in length!", toastType: .red)
            return
        }
        
        self.tagsList.append(interestTxtField.text!)
//        self.userDetails!.tag = Utils().convertArrayToCommaSeperatedString(tagsList)
        self.interestTxtField.text = ""
        self.addInterestBtn.isHidden = true
        self.collectionViewHeight.constant = 50
        self.collectionView.reloadData()
    }
}

// MARK: - CollectionView Configuration
extension EditProfileVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        self.collectionViewHeight.constant = self.tagsList.count > 0 ? 50 : 0
        
        return self.tagsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsTagCell", for: indexPath) as? InterestsTagCell else { // cellTapBtn added because did select item was not working due to this: addDismissKeyboardOnTapGesture(scrollView: scrollView)
            return UICollectionViewCell()
        }
        cell.tagName.text = self.tagsList[indexPath.row]
        cell.cellTapBtn.tag = indexPath.row
        cell.cellTapBtn.addTarget(self, action: #selector(self.removeTag(_:)), for: .touchUpInside)
        return cell
    }

    @objc func removeTag(_ sender: UIButton) {
        self.tagsList.remove(at: sender.tag)
        self.collectionViewHeight.constant = tagsList.isEmpty ? 0 : 50
        self.collectionView.reloadData()
    }
}

extension EditProfileVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.returnKeyType == .done {
            textField.resignFirstResponder()
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Limit TextField to certain number of characters.
        if textField == self.phoneTF && string != "" {
            return textField.text!.count + (string.count - range.length) <= 12
        }
        
        // First name textfield should not contain special characters.
        if textField == self.firstNameTF || textField == self.lastNameTF {
            
            if string == " " && textField.text!.isEmpty {
                return false
            }
            
            if Utils.validateString(text: string, with: AppConstants.specialCharacterRegex) && string != " " {
                return false
            }
            if string.isNumber {
                return false
            }
            
            // Limit first name and last name TextField to certain number of characters.
            return textField.text!.count + (string.count - range.length) <= 20
        }
        
        if textField == self.interestTxtField {
            if Utils.validateString(text: string, with: AppConstants.specialCharacterRegex) && string != " " {
                return false
            }
            
            let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
            if updatedString!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).count > 0 {
                self.addInterestBtn.isHidden = false
            } else {
                self.addInterestBtn.isHidden = true
            }
            
            return textField.text!.count + (string.count - range.length) <= 50
        }
        
        return true
    }
}

extension EditProfileVC: NetworkResponseProtocols {
    
    // MARK: - User Details Response
    func didGetUserDetails() {
        
        self.hideLoader()
        
        self.scrollView.flashScrollIndicators()
        
        if let data = self.viewModel.userDetailsResponse?.data {
            
            guard
//                let _ = data.id,
//                let _ = data.identifier,
                let _ = data.firstName,
                let _ = data.lastName,
                let _ = data.emailAddress,
                let _ = data.phoneNumber,
//                let _ = data.imageFile,
                let _ = data.displayImageURL
//                let _ = data.facebookLink,
//                let _ = data.twitterLink,
//                let _ = data.youtubeLink,
//                let _ = data.instagramLink,
//                let _ = data.typeOfLink,
//                let _ = data.link,
//                let _ = data.tag,
//                let _ = data.userTypeID,
//                let _ = data.countryID,
//                let _ = data.isDiscoverable,
//                let _ = data.city,
//                let _ = data.dateOfBirth,
//                let _ = data.genderID,
//                let _ = data.genderName,
//                let _ = data.zipcode,
//                let _ = data.isTwoFAEnabled
                
            else {
                popOnErrorAlert("Some error occured")
                return
            }
            
            self.userDetails = data
            self.setUserDetails()
        }
        else {
            popOnErrorAlert(self.viewModel.userDetailsResponse?.message ?? "")
        }
    }
    
    // MARK: - Update Profile Response
    func didUpdateProfile() {
        
        self.hideLoader()
        
        if let data = self.viewModel.updateProfileResponse?.data {
            
            PreferencesManager.saveUserModel(user: data)
            
            self.delegate?.updateUserInfo()
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.updateProfileResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
        else {
            self.showToast(message: self.viewModel.updateProfileResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
}

extension EditProfileVC: AppProtocol {
    
    func updateSocialLink(facebookLink: String?, twitterLink: String?, youtubeLink: String?, instagramLink: String?) {
        
        if let facebookLink {
            self.userDetails?.facebookLink = facebookLink
        }
        if let twitterLink {
            self.userDetails?.twitterLink = twitterLink
        }
        if let youtubeLink {
            self.userDetails?.youtubeLink = youtubeLink
        }
        if let instagramLink {
            self.userDetails?.instagramLink = instagramLink
        }
    }
}

extension EditProfileVC: FPNTextFieldDelegate {
    
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
