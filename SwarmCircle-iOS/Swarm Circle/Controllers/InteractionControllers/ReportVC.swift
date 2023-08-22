//
//  ReportVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 01/11/2022.
//

import UIKit

class ReportVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var typeTF: UITextField!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var reportTypeBackgroundView: UIView!
    
    var reportTypePickerView = UIPickerView()
    
    var reportTypeList: [ReportTypeDM] = []
    var selectedReportTypeIndex = -1
    
    var sourceId: Int?
    var sourceType: Int?
    
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        self.descriptionTV.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 7.5)
        self.typeTF.delegate = self
        self.descriptionTV.delegate = self
        self.view.backgroundColor = UIColor.init(white: 0.2, alpha: 0.7)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        
        guard let _ = sourceId, let _ = sourceType else {
            popOnErrorAlert("Some error occured")
            return
        }
        
        guard let reportTypeList = PreferencesManager.getReportTypeList() else {
            
            self.viewModel.delegateNetworkResponse = self
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showLoader()
                self.getReportTypeList()
            }
            return
        }
        self.reportTypeList = reportTypeList
    }
    
    // MARK: - Fetch Report Type List
    func getReportTypeList() {
        self.viewModel.getReportTypeList()
    }
    
    // MARK: - Save Report
    func saveReport() {
        
        let descriptionText = self.descriptionTV.text! == "Description (Optional)" ? "" : self.descriptionTV.text!
        
        let params: [String: Any] =
        [
            "sourceID": self.sourceId!,
            "sourceType": self.sourceType!,
            "reportTypeID": reportTypeList[self.selectedReportTypeIndex].id!,
            "reportText": descriptionText
        ]
        
        self.showLoader()
        
        self.viewModel.saveReport(params: params)
    }
    
    // MARK: - Cross Button Tapped
    @IBAction func crossBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Report Button Tapped
    @IBAction func reportBtnTapped(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.descriptionTV.text.removeWhiteSpacesFromStartNEnd()
        self.descriptionTV.text.removeNewLinesFromStartNEnd()
        
        if self.validateFields() {
            self.saveReport()
        }
    }
    
    // MARK: - Validate Fields
    func validateFields() -> Bool {
        if self.typeTF.text!.isEmpty || self.selectedReportTypeIndex == -1 {
            self.showToast(message: "Please choose a report type", toastType: .red)
            return false
        }
        if reportTypeList[self.selectedReportTypeIndex].id == nil {
            popOnErrorAlert("Some error occured")
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
                
                self.lastBottomConstraint.constant = 30
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
        
        self.reportTypePickerView.delegate = self
        self.reportTypePickerView.dataSource = self
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped(_:)))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([doneButton, spaceButton, cancelButton], animated: true)
        //        toolBar.setItems([doneButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        self.typeTF.inputView = self.reportTypePickerView
    }
    
    // MARK: - Cancel for ToolBar
    @objc func cancelClick() {
        view.endEditing(true)
    }
    
    // MARK: - Done for ToolBar
    @objc func doneTapped(_ sender: UIButton) {
        
        view.endEditing(true)
        
        let selectedRow = reportTypePickerView.selectedRow(inComponent: 0)
        self.typeTF.text = self.reportTypeList[selectedRow].typeName
        self.selectedReportTypeIndex = selectedRow
        
        self.reportTypeBackgroundView.backgroundColor = UIColor.white
    }
}

// MARK: - PickerView Delegate & DataSource Configuration
extension ReportVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.reportTypeList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.reportTypeList[row].typeName
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        self.typeTF.text = self.reportTypeList[row].typeName
    }
    
}

extension ReportVC: NetworkResponseProtocols {
    
    // MARK: - Report Type List Response
    func didGetReportTypeList() {
        
        hideLoader()
        
        if let unwrappedList = self.viewModel.reportTypeListResponse?.data {
            self.reportTypeList = unwrappedList
        }
        else {
            self.popOnErrorAlert(self.viewModel.reportTypeListResponse?.message ?? "Some error occured")
        }
    }
    
    func didSaveReport() {
        
        hideLoader()
        
        if self.viewModel.saveReportResponse?.isSuccess ?? false {
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.saveReportResponse?.message ?? "Some error occured") { result in
                if result {
                    self.dismiss(animated: true)
                }
            }
        }
        else {
            self.showToast(message: self.viewModel.saveReportResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
}

extension ReportVC: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
//        if textField == typeTF {
        self.setPickerView(textField: self.typeTF)
//        }
    }
}

extension ReportVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count > 500 {
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Description (Optional)" {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Description (Optional)"
        }
    }
}
