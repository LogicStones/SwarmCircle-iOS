//
//  CreatePollVC.swift
//  Swarm Circle
//
//  Created by Macbook on 08/07/2022.
//

import UIKit

class CreatePollVC: BaseViewController {
    
    @IBOutlet weak var durationTF: UITextField!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addOptionLbl: UILabel!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
    var cellsArray: [(String, String)] = [
        ("Your Question", ""),
        ("Option", ""),
        ("Option", "")
    ]
    
    var pickerView = UIPickerView()
    //    var datePicker = UIDatePicker()
    var pollDurationList: [PollDurationDM] = []
    
    var selectedDurationIndex = -1
    
    var circleId: Int?
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    
    // MARK: - Configuring UI when loading
    func initUI(){
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.tableView.register(UINib(nibName: "PollQuestionCell", bundle: nil), forCellReuseIdentifier: "PollQuestionCell")
        self.setDelegate(textField: self.durationTF)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetPollDurationList()
    }
    
    // MARK: - Fetch Poll Duration List
    func postGetPollDurationList() {
        self.viewModel.getPollDurationList()
    }
    
    // MARK: - Create Poll
    func postCreatePoll(durationId: Int, durationHours: Int, userId: Int, circleId: Int) {
        
        var optionArray: [String] = []
        
        // Remove whitespaces from cellsArray first index (i.e: questions)
        self.cellsArray[0].1.removeWhiteSpacesFromStartNEnd()
        self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        
        if cellsArray[0].1.isEmpty {
            self.showToast(message: "Question field cannot be empty", delay: 2, toastType: .red)
            return
        }
        if cellsArray[0].1.count < 10 {
            self.showToast(message: "Question should be atleast 10 characters long", delay: 2, toastType: .red)
            return
        }
        
        // Break cell array into option array
        for i in stride(from: 1, to: cellsArray.count, by: 1) {
            
            self.cellsArray[i].1.removeWhiteSpacesFromStartNEnd()
            self.tableView.reloadRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
            
            if !cellsArray[i].1.isEmpty {
                optionArray.append(cellsArray[i].1)
            } else {
                self.showToast(message: "Option fields cannot be empty", delay: 2, toastType: .red)
                return
            }
        }
        
        self.showLoader()
        
        let params: [String: Any] =
        [
            "question": cellsArray[0].1,
            "durationID": durationId,
            "durationHours": durationHours,
            "circleID": circleId,
            "pollOptions": optionArray,
            "expDate": Utils.getCurrentDateTime(),
            "createdBy": userId,
            "createdOn": Utils.getCurrentDateTime()
        ]
        self.viewModel.createPoll(params: params)
    }
    
    // MARK: - Create Poll Button Tapped
    @IBAction func createPollBtnPreseed(_ sender: UIButton) {
        
        view.endEditing(true)
        
        if selectedDurationIndex < 0 {
            Alert.sharedInstance.showAlert(title: "Alert", message: "Please select a duration for the Poll")
            return
        }
        
        guard let durationId = pollDurationList[selectedDurationIndex].id, let durationHours = pollDurationList[selectedDurationIndex].durationInHours, let userId = PreferencesManager.getUserModel()?.id, let circleId = self.circleId else {
            Alert.sharedInstance.showAlert(title: "", message: "Some Error Occured")
            return
        }
        
        self.postCreatePoll(durationId: durationId, durationHours: durationHours, userId: userId, circleId: circleId)
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
                
                self.lastBottomConstraint.constant = keyboardSize.height - 35
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            } else {
                print("Keyboard Hidden")
                
                self.lastBottomConstraint.constant = 50
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            
        }
    }
    
    // MARK: - Add Poll Option Button Tapped
    @IBAction func addRowTapped(_ sender: UIButton) {
        if self.cellsArray.count < 6 {
            self.cellsArray.append(("Option", ""))
            self.tableView.reloadData()
            
            addOptionLbl.textColor = self.cellsArray.count == 6 ? UIColor.lightGray : UIColor(named: "BackgroundColor")
        } else {
            self.showToast(message: "Only 5 options allowed", toastType: .red)
        }
    }
    
    // MARK: - DismissKeyboard on touch anywhere
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    // MARK: - Setting Delegate
    func setDelegate(textField: UITextField){
        textField.delegate = self
    }
    
    // MARK: - Setting ToolBar on keyboard
    func setPickerView(textField: UITextField){
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick))
        toolBar.setItems([doneButton, spaceButton, cancelButton], animated: true)
        //        toolBar.setItems([doneButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        textField.inputView = self.pickerView
    }
    
    // MARK: - Done for ToolBar
    //    @objc func doneClick() {
    //        view.endEditing(true)
    //    }
    
    // MARK: - Cancel for ToolBar
    @objc func cancelClick() {
        view.endEditing(true)
    }
    
    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async {
            super.updateViewConstraints()
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
    }
    
}
// MARK: - TableView Configuration
extension CreatePollVC: UITableViewDelegate, UITableViewDataSource {//, UITableViewDragDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cellsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PollQuestionCell") as? PollQuestionCell else {
            return UITableViewCell()
        }
        
        cell.optionTF.tag = indexPath.row
        cell.optionTF.delegate = self
        
        if indexPath.row == 0 {
            cell.titleLBL.text = cellsArray[indexPath.row].0
            cell.optionTF.text = cellsArray[indexPath.row].1
        } else {
            cell.titleLBL.text = "\(cellsArray[indexPath.row].0) \(indexPath.row)"
            cell.optionTF.text = cellsArray[indexPath.row].1
        }
        
        cell.deleteButton.isHidden = !(indexPath.row > 2)
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleterow), for: .touchUpInside)
        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let cell = tableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as? PollQuestionCell {
            if textField == cell.optionTF {
                self.cellsArray[textField.tag].1 = textField.text ?? ""
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let cell = tableView.cellForRow(at: IndexPath(row: textField.tag, section: 0)) as? PollQuestionCell {
            
            if textField == cell.optionTF {
                if textField.text!.count + string.count > 200 {
                    return false
                }
            }
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
    
    @objc func deleterow(sender: UIButton){
        
        self.cellsArray.remove(at: sender.tag)
        self.tableView.reloadData()
        addOptionLbl.textColor = UIColor(named: "BackgroundColor")
    }
}

// MARK: - PickerView Delegate & DataSource Configuration
extension CreatePollVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.pollDurationList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.pollDurationList[row].durationText
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDurationIndex = row
        self.durationTF.text = self.pollDurationList[row].durationText
    }
    
}

// MARK: - TextField Configuration
extension CreatePollVC: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.setPickerView(textField: self.durationTF)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
    }
}

extension CreatePollVC: NetworkResponseProtocols {
    
    // MARK: - Poll Duration List Response
    func didGetPollDurationList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.getPollDurationListResponse?.data {
            
            self.pollDurationList.append(contentsOf: unwrappedList)
            self.tableView.reloadData()
            if self.pollDurationList.count > 0 {
                self.selectedDurationIndex = 0
                self.durationTF.text = self.pollDurationList[0].durationText
            }
            
        } else {
            Alert.sharedInstance.alertWindow(title: "", message: "Some error occured, please try again later") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Create Poll Response
    func didCreatePoll() {
        
        self.hideLoader()
        
        if let _ = viewModel.createPollResponse?.data {
            self.showToast(message: viewModel.createPollResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            self.cellsArray = [("Your Question", ""), ("Option", ""), ("Option", "")]
            self.tableView.reloadData()
            self.addOptionLbl.textColor = UIColor(named: "BackgroundColor")
            self.delegate?.updateNewPollsCount(1)
            
        } else {
            self.showToast(message: viewModel.createPollResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
        
    }
}
