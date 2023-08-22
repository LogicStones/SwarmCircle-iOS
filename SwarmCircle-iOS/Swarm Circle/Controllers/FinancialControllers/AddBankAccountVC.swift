//
//  AddBankAccountVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/10/2022.
//

import UIKit

class AddBankAccountVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var accHolderTF: UITextField!
    @IBOutlet weak var accNumberTF: UITextField!
    @IBOutlet weak var routingNumberTF: UITextField!
    @IBOutlet weak var dateOfBirthTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var stateTF: UITextField!
    @IBOutlet weak var cityTF: UITextField!
    @IBOutlet weak var postalCodeTF: UITextField!
    @IBOutlet weak var line1TF: UITextField!
    @IBOutlet weak var line2TF: UITextField!
    @IBOutlet weak var socialSecurityNumberTF: UITextField!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    
    var countryPickerView = UIPickerView()
    var dobPickerView = UIDatePicker()
    
    var attachmentData: Data?
    
    var countryList: [CountryDM] = []
    var selectedCountryIndex = -1
    
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
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.accHolderTF.delegate = self
        self.accNumberTF.delegate = self
        self.routingNumberTF.delegate = self
        self.dateOfBirthTF.delegate = self
        self.countryTF.delegate = self
        self.stateTF.delegate = self
        self.cityTF.delegate = self
        self.postalCodeTF.delegate = self
        self.line1TF.delegate = self
        self.line2TF.delegate = self
        self.socialSecurityNumberTF.delegate = self
        
        self.dobPickerView.maximumDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())
        
//        self.dobPickerView.maximumDate = self.dobPickerView.date(byAdding: .day, value: -1, to: self.dobPickerView.maximumDate)
        
        setToolBarOnKeyboard(textField: self.socialSecurityNumberTF)
        setToolBarOnKeyboard(textField: self.accNumberTF)
        setToolBarOnKeyboard(textField: self.routingNumberTF)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.getCountryList()
    }
    
    // MARK: - Fetch Bank Account List
    func getCountryList() {
        self.viewModel.getCountryList()
    }
    
    // MARK: - Fetch Bank Account List
    func createBankAccount() {
        
        self.showLoader()
        
        self.viewModel.createBankAccount(accHolderName: self.accHolderTF.text!, accNumber: self.accNumberTF.text!, routingNumber: self.routingNumberTF.text!, city: self.cityTF.text!, country: self.countryList[selectedCountryIndex].shortCode!, line1: self.line1TF.text!, line2: self.line2TF.text!, state: self.stateTF.text!, postalCode: self.postalCodeTF.text!, ssn: self.socialSecurityNumberTF.text!, dob: self.dateOfBirthTF.text!, documentFile: self.attachmentData!)
    }
    
    
    @IBAction func attachmentBtnTapped(_ sender: UIButton) {
        DocumentPickerManager(self).pickDocument()
    }
    
    @IBAction func addBankAccBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.accHolderTF.text!.removeWhiteSpacesFromStartNEnd()
        self.accNumberTF.text!.removeWhiteSpacesFromStartNEnd()
        self.routingNumberTF.text!.removeWhiteSpacesFromStartNEnd()
        self.dateOfBirthTF.text!.removeWhiteSpacesFromStartNEnd()
        self.countryTF.text!.removeWhiteSpacesFromStartNEnd()
        self.stateTF.text!.removeWhiteSpacesFromStartNEnd()
        self.cityTF.text!.removeWhiteSpacesFromStartNEnd()
        self.postalCodeTF.text!.removeWhiteSpacesFromStartNEnd()
        self.line1TF.text!.removeWhiteSpacesFromStartNEnd()
        self.line2TF.text!.removeWhiteSpacesFromStartNEnd()
        self.socialSecurityNumberTF.text!.removeWhiteSpacesFromStartNEnd()
        
        self.accHolderTF.text?.condenseWhitespace()
        self.cityTF.text?.condenseWhitespace()
        self.stateTF.text?.condenseWhitespace()
        
        if self.validateFields() {
            self.createBankAccount()
        }
    }
    
    // MARK: - Validate Fields on button Tap
    func validateFields() -> Bool {
        
        if self.accHolderTF.text!.isEmpty {
            self.showToast(message: "Account Holder name required", toastType: .red)
            return false
        }
        if self.accNumberTF.text!.isEmpty {
            self.showToast(message: "Account Number required", toastType: .red)
            return false
        }
        if self.routingNumberTF.text!.isEmpty {
            self.showToast(message: "Routing Number required", toastType: .red)
            return false
        }
        if self.routingNumberTF.text!.count < 9 {
            self.showToast(message: "Routing Number must be 9 digits long", toastType: .red)
            return false
        }
        if self.dateOfBirthTF.text!.isEmpty {
            self.showToast(message: "Date of Birth required", toastType: .red)
            return false
        }
        if self.countryTF.text!.isEmpty  {
            self.showToast(message: "Country required", toastType: .red)
            return false
        }
        if countryList[self.selectedCountryIndex].shortCode == nil {
            popOnErrorAlert("Country Short code missing.")
        }
        if self.stateTF.text!.isEmpty {
            self.showToast(message: "State required", toastType: .red)
            return false
        }
        if self.cityTF.text!.isEmpty {
            self.showToast(message: "City required", toastType: .red)
            return false
        }
        if self.postalCodeTF.text!.isEmpty {
            self.showToast(message: "Postal Code required", toastType: .red)
            return false
        }
        if self.socialSecurityNumberTF.text!.isEmpty {
            self.showToast(message: "Social Security Number required", toastType: .red)
            return false
        }
        if !self.socialSecurityNumberTF.text!.isNumber || self.socialSecurityNumberTF.text!.count != 4 {
            self.showToast(message: "Invalid SSN last 4. SSN last 4 must be exactly four digits", toastType: .red)
            return false
        }
        if self.attachmentData == nil {
            self.showToast(message: "Attachment required", toastType: .red)
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
                
                self.lastBottomConstraint.constant = keyboardSize.height - 25
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
    
    // MARK: - Setting ToolBar on keyboard
    func setPickerView(textField: UITextField){
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        self.countryPickerView.delegate = self
        self.countryPickerView.dataSource = self
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped(_:)))
        doneButton.tag = textField == dateOfBirthTF ? 1 : 2
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
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
        
        self.dateOfBirthTF.inputView = self.dobPickerView
        self.countryTF.inputView = self.countryPickerView
    }
    
    // MARK: - Cancel for ToolBar
    @objc func cancelClick() {
        view.endEditing(true)
    }
    
    // MARK: - Done for ToolBar
    @objc func doneTapped(_ sender: UIButton) {
        
        view.endEditing(true)
        
        if sender.tag == 1 { //dob picker view
            self.dateOfBirthTF.text = Utils.getFormattedDateMMDDYYYY(date: dobPickerView.date)
            self.countryTF.becomeFirstResponder()
        } else {
            let selectedRow = countryPickerView.selectedRow(inComponent: 0)
            self.countryTF.text = self.countryList[selectedRow].countryName
            self.selectedCountryIndex = selectedRow
            self.stateTF.becomeFirstResponder()
        }
    }
}

extension AddBankAccountVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.socialSecurityNumberTF {
            // only allow 4 digits
            if textField.text!.count >= 4 && string != "" {
                return false
            }
        }
        if textField == self.accNumberTF {
            if (textField.text!.count + string.count) > 12 {
                return false
            }
        }
        
        if textField == self.routingNumberTF {
            if (textField.text!.count + string.count) > 9 {
                return false
            }
        }

        if textField == self.postalCodeTF {
            
            if Utils.validateString(text: string, with: AppConstants.specialCharacterRegex) {
                return false
            }
            
            if (textField.text!.count + string.count) > 6 {
                return false
            }
            
        }
        
        if textField == self.accHolderTF || textField == self.cityTF || textField == self.stateTF {
            if string.isNumber {
                return false
            }
            if Utils.validateString(text: string, with: AppConstants.specialCharacterRegex) && string != " " {
                return false
            }
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField.returnKeyType == .next {
            
            let nextTextFieldTag = textField.tag + 1
            
            if let nextTextField = textField.superview?.superview?.superview?.viewWithTag(nextTextFieldTag) as? UITextField {
                nextTextField.becomeFirstResponder()
            }
            return true
        }
        else {
            textField.resignFirstResponder()
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.scrollView.setContentOffset(CGPointMake(0, (textField.superview?.frame.origin.y ?? 0) - 125), animated: true)
        
        if textField == dateOfBirthTF {
            self.setPickerView(textField: self.dateOfBirthTF)
        } else if textField == countryTF {
            self.setPickerView(textField: self.countryTF)
        }
    }
}

extension AddBankAccountVC: NetworkResponseProtocols {
    
    // MARK: - Country List Response
    func didGetCountryList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.countryListResponse?.data {
            
            // Only append countries that are active
            //            self.countryList.append(contentsOf: unwrappedList.filter { $0.isActive ?? false }) // uncomment later if needed
            
            self.countryList.append(contentsOf: unwrappedList)
            
            if self.countryList.isEmpty {
                popOnErrorAlert("Country list not Available")
            }
            //            self.tableView.reloadData()
            //            self.bankAccountList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: viewModel.countryListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    func didCreateBankAccount() {
        
        self.hideLoader()
        
        if self.viewModel.bankAccountCreateResponse?.isSuccess ?? false {
            
            self.delegate?.refreshBankAccountList()
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.bankAccountCreateResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.showToast(message: self.viewModel.bankAccountCreateResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}

// MARK: - PickerView Delegate & DataSource Configuration
extension AddBankAccountVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.countryList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.countryList[row].countryName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        self.countryTF.text = self.countryList[row].countryName
    }
    
}

extension AddBankAccountVC: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let url = urls.first else {
            return
        }
        do {
            
            if Utils().sizePerMB(url: url) > 16.0 {
                self.showToast(message: "The file you uploaded was too large. Please upload a file smaller than 16 MB", toastType: .red)
                return
            }
            
            let data = try Data(contentsOf: url)
            if self.attachmentData != nil {
                self.showToast(message: "Attachment Replaced", toastType: .green)
            } else {
                self.showToast(message: "Attachment Added", toastType: .green)
            }
        
            self.attachmentData = data
            
        } catch {
            self.showToast(message: error.localizedDescription, toastType: .red)
        }
    }
}
