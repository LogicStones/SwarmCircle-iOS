//
//  RegisterVC.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import UIKit
import FlagPhoneNumber

class RegisterVC: BaseViewController {
    
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var phoneTF: FPNTextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var dobTF: UITextField!
    @IBOutlet weak var genderTF: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastButtonBottom: NSLayoutConstraint!
    
    var dobPickerView = UIDatePicker()
    var pickerView = UIPickerView()
    
    var genderList: [(String, Int)] = [
        ("Male", 1),
        ("Female", 3),
        ("Other", 2)
    ]
    var selectedGenderIndex = -1
    
    var currentCountryCode = ""
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    private func initUI() {
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.firstNameTF.delegate = self
        self.lastNameTF.delegate = self
        self.emailTF.delegate = self
        self.phoneTF.delegate = self
        self.passwordTF.delegate = self
        self.dobTF.delegate = self
        self.genderTF.delegate = self
        
        setToolBarOnKeyboard(textField: self.phoneTF)
        setToolBarOnKeyboard(textField: self.dobTF)
//        setToolBarOnKeyboard(textField: self.genderTF)
        
        self.phoneTF.setFlag(key: .US)
        self.currentCountryCode = self.phoneTF.selectedCountry!.phoneCode
        
        self.dobPickerView.maximumDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide navigation bar
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // disable back swipe gesture
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationController?.navigationBar.isHidden = false
    }

    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
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
                
                self.lastButtonBottom.constant = keyboardSize.height - 35
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else{
                print("Keyboard Hidden")
                
                self.lastButtonBottom.constant = 20
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            view.layoutSubviews()
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        
        self.navigationController?.popViewController(animated: true)
        //        self.dismiss(animated: true)
    }
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        
        self.view.endEditing(true)
        
        self.firstNameTF.text!.removeWhiteSpacesFromStartNEnd()
        self.firstNameTF.text!.condenseWhitespace()
        self.lastNameTF.text!.removeWhiteSpacesFromStartNEnd()
        self.lastNameTF.text!.condenseWhitespace()
        self.emailTF.text!.removeWhiteSpacesFromStartNEnd()
        self.emailTF.text!.condenseWhitespace()
        
        
        if self.firstNameTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "First name required")
            return
        }
        if self.firstNameTF.text!.count < 2 {
            Alert.sharedInstance.showAlert(title: "Error", message: "First name should be atleast 2 characters long.")
            return
        }

        if Utils.validateString(text: self.firstNameTF.text!.replacingOccurrences(of: " ", with: ""), with: AppConstants.specialCharacterRegex) {
            Alert.sharedInstance.showAlert(title: "Error", message: "First name cannot contain special characters")
            return
        }
        if self.firstNameTF.text!.isNumber {
            Alert.sharedInstance.showAlert(title: "Error", message: "First name cannot contain Numbers")
            return
        }
        
        if self.lastNameTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Last name required")
            return
        }
        if self.lastNameTF.text!.count < 2 {
            Alert.sharedInstance.showAlert(title: "Error", message: "Last name should be atleast 2 characters long.")
            return
        }
        if Utils.validateString(text: self.lastNameTF.text!.replacingOccurrences(of: " ", with: ""), with: AppConstants.specialCharacterRegex) {
            Alert.sharedInstance.showAlert(title: "Error", message: "Last name cannot contain special characters")
            return
        }
        if self.lastNameTF.text!.isNumber {
            Alert.sharedInstance.showAlert(title: "Error", message: "Last name cannot contain Numbers")
            return
        }
    
        if self.emailTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Email required")
            return
        }
        if !Utils.validateString(text: self.emailTF.text!, with: AppConstants.emailRegex) {
            Alert.sharedInstance.showAlert(title: "Error", message: "Invalid Email")
            return
        }
        
        if self.genderTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Gender required")
            return
        }
        
        if self.phoneTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Phone required")
            return
        }
        if !Utils.validatePhoneNumber(flagPhoneNumberTextField: self.phoneTF) {
            Alert.sharedInstance.showAlert(title: "Invalid Phone", message: "Please provide a valid phone number")
            return
        }
//        if self.phoneTF.text!.count != 12 {
//            Alert.sharedInstance.showAlert(title: "Invalid Phone", message: "Phone Number should be 12-digits")
//            return
//        }
        if self.passwordTF.text!.isEmpty {
            Alert.sharedInstance.showAlert(title: "Error", message: "Password required")
            return
        }
        if !Utils.validateString(text: self.passwordTF.text ?? "", with: AppConstants.passwordRegex) {
            Alert.sharedInstance.showAlert(title: "Invalid Password", message: "Passwords must be at least 8 characters and contain at 3 of 4 of the following: upper case (A-Z), lower case (a-z), number (0-9) and special character (e.g. !@#$%^&*)")
            return
        }
        
        self.showLoader()
        
        let phoneNumber = "\(phoneTF.selectedCountry!.phoneCode)\(phoneTF.text!)".replacingOccurrences(of: " ", with: "")
//        phoneNumber = phoneNumber.replacingOccurrences(of: " ", with: "")

        self.postRegister(firstName: firstNameTF.text!, lastName: lastNameTF.text!, email: emailTF.text!, password: passwordTF.text!, phoneNo: phoneNumber, dob: dobTF.text!)
    }
    
    func postRegister(firstName: String, lastName: String, email:  String, password: String, phoneNo: String, dob: String) {
        
        var params = ["firstName": firstName,
                      "lastName": lastName,
                      "email": email,
                      "gender": self.genderList[selectedGenderIndex].1,
                      "password": password,
                      "phoneNo": phoneNo
        ] as [String : Any]
        
        if !dob.isEmpty {
            params["dob"] = dob
        }
        
        self.viewModel.registerUser(params: params)
    }
    
    // MARK: - Setting ToolBar on keyboard
    func setPickerView(textField: UITextField) {
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped(_:)))
        doneButton.tag = textField == genderTF ? 1 : 2
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick(_:)))
        cancelButton.tag = textField == genderTF ? 1 : 2
        toolBar.setItems([doneButton, spaceButton, cancelButton], animated: true)
        //        toolBar.setItems([doneButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        self.dobPickerView.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            self.dobPickerView.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        self.dobTF.inputView = self.dobPickerView
        self.genderTF.inputView = self.pickerView
    }
    
    // MARK: - Cancel for ToolBar
    @objc func cancelClick(_ sender: UIButton) {
        
        view.endEditing(true)
        if sender.tag != 1 {
            self.dobTF.text = ""
        }
    }
    
    // MARK: - Done for ToolBar
    @objc func doneTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        if sender.tag == 1 {
            let selectedRow = pickerView.selectedRow(inComponent: 0)
            self.genderTF.text = self.genderList[selectedRow].0
            self.selectedGenderIndex = selectedRow
        }
        else {
            self.dobTF.text = Utils.getFormattedDateMMDDYYYY(date: dobPickerView.date)
        }
    }
}

// MARK: - PickerView Delegate & DataSource Configuration
extension RegisterVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genderList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genderList[row].0
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedGenderIndex = row
        self.genderTF.text = self.genderList[row].0
    }
    
}

// Handling textfield return events
extension RegisterVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        let nextTextFieldTag = textField.tag + 1
        
        if let nextTextField = textField.superview?.superview?.superview?.viewWithTag(nextTextFieldTag) as? UITextField {
            nextTextField.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.scrollView.setContentOffset(CGPointMake(0, (textField.superview?.frame.origin.y ?? 0) - 42), animated: true)
        
        if textField == self.dobTF {
            self.setPickerView(textField: self.dobTF)
            return
        }
        if textField == self.genderTF {
            self.setPickerView(textField: self.genderTF)
            return
        }
    }
    
    // MARK: - Limit TextField to certain number of characters.
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // Limit TextField to certain number of characters.
        if textField == self.phoneTF {
            return textField.text!.count + (string.count - range.length) <= 12
        }
        
        // First name textfield should not contain special characters.
        if textField == self.firstNameTF || textField == self.lastNameTF {
            
            if string == " " && textField.text!.isEmpty {
                //                    self.showToast(message: "Name should not start with a white space", delay: 0.5, toastType: .red, bottomConstraintConstant: -lastButtonBottom.constant - 0)
                return false
            }
            
            if Utils.validateString(text: string, with: AppConstants.specialCharacterRegex) && string != " " {
                //                    self.showToast(message: "First name should not contain special characters", delay: 0.5, toastType: .red, bottomConstraintConstant: -lastButtonBottom.constant - 0)
                return false
            }
            if string.isNumber {
                return false
            }

            // Limit first name and last name TextField to certain number of characters.
            return textField.text!.count + (string.count - range.length) <= 20
        }
        
        
        return true
    }
}

extension RegisterVC: NetworkResponseProtocols {
    
    func didRegistered() {
        
        self.hideLoader()
        
        if let response = viewModel.registerResponse {
            
            if (response.isSuccess ?? false) == true {
                Alert.sharedInstance.alertOkWindow(title: "Success", message: response.message ?? "Something went wrong") { result in
                    
                    if result {
                        
                        if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "VerifyVC") as? VerifyVC {
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

extension RegisterVC: FPNTextFieldDelegate {
    
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
