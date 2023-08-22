//
//  TransactionsVC.swift
//  Swarm Circle
//
//  Created by Macbook on 07/07/2022.
//

import UIKit

class TransactionsVC: BaseViewController {

    var datePicker = UIDatePicker()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var transferButton: ToggleButton!
    @IBOutlet weak var withdrawalButton: ToggleButton!
    @IBOutlet weak var depositButton: ToggleButton!
    @IBOutlet weak var allButton: ToggleButton!
    @IBOutlet weak var fromDateTF: UITextField!
    @IBOutlet weak var toDateTF: UITextField!
    
    var fromDatePicker = UIDatePicker()
    var toDatePicker = UIDatePicker()
    
    var segmentButtons = [ToggleButton]()
    
    var pageNumber: Int = 1
    var transactionList: [TransactionDM] = []
    var transactionListFiltered: [TransactionDM] = []
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI(){
        self.segmentsConfigurations()
        self.tableView.register(UINib(nibName: "TransactionRecordCell", bundle: nil), forCellReuseIdentifier: "TransactionRecordCell")
        self.fromDatePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        self.toDatePicker.maximumDate = Calendar.current.date(byAdding: .year, value: 0, to: Date())
        self.toDatePicker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        self.fromDateTF.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        self.setPickerView(textField: self.toDateTF)
        self.setPickerView(textField: self.fromDateTF)
        self.fromDateTF.text = Utils.getFormattedDateMMDDYYYY(date: Calendar.current.date(byAdding: .day, value: -15, to: Date())!)
        self.toDateTF.text = Utils.getFormattedDateMMDDYYYY(date: Calendar.current.date(byAdding: .day, value: 0, to: Date())!)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetTransactionList()
    }
    
    // MARK: - Get Transaction List
    func postGetTransactionList() {
        
        let transType = segmentButtons.first { $0.isSelected }?.titleLabel?.text!.replacingOccurrences(of: " ", with: "")
        
        var transTypeKey = ""
        
        switch transType {
        case "Deposit":
            transTypeKey = "Deposited"
        case "Withdrawals":
            transTypeKey = "Withdrawn"
        case "Transfers":
            transTypeKey = "Transferred"
        default:
            transTypeKey = "All"
        }
        
        self.viewModel.getTransactionList(fromDate: self.fromDateTF.text!, toDate: self.toDateTF.text!, transType: transTypeKey, pageNumber: self.pageNumber)
    }
    
    
    
    @objc func datePickerChanged(picker: UIDatePicker) {
//        let fromDatePicked = self.fromDatePicker.date
        self.toDatePicker.minimumDate = self.fromDatePicker.date
        self.fromDatePicker.maximumDate = self.toDatePicker.date
        
//        self.fromDatePicker.date = fromDatePicked
//        if fromDateTF.text! != "" {
//            self.fromDateTF.text = Utils.getFormattedDate(date: fromDatePicked)
//        }
    }
    
    // MARK: - Configuring for segment Buttons
    func segmentsConfigurations(){
        self.segmentButtons.append(allButton)
        self.segmentButtons.append(depositButton)
        self.segmentButtons.append(withdrawalButton)
        self.segmentButtons.append(transferButton)
        
        self.allButton.tag = 0
        self.depositButton.tag = 1
        self.withdrawalButton.tag = 2
        self.transferButton.tag = 3
        self.allButton.isSelected = true
        self.allButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.depositButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.withdrawalButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        self.transferButton.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
    }
    
    // MARK: - Setting ToolBar on keyboard
    func setPickerView(textField: UITextField){
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        
//        self.pickerView.delegate = self
//        self.pickerView.dataSource = self
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneTapped(_:)))
        doneButton.tag = textField == fromDateTF ? 1 : 2
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelClick(_:)))
        cancelButton.tag = textField == fromDateTF ? 1 : 2
        toolBar.setItems([doneButton, spaceButton, cancelButton], animated: true)
        //        toolBar.setItems([doneButton, cancelButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        textField.inputAccessoryView = toolBar
        
        self.toDatePicker.datePickerMode = .date
        self.fromDatePicker.datePickerMode = .date
        
        if #available(iOS 13.4, *) {
            self.toDatePicker.preferredDatePickerStyle = .wheels
            self.fromDatePicker.preferredDatePickerStyle = .wheels
            
        } else {
            // Fallback on earlier versions
        }
        self.toDateTF.inputView = self.toDatePicker
        self.fromDateTF.inputView = self.fromDatePicker
        
    }

    @objc func buttonPressed(_ sender: ToggleButton) {
        
        for item in self.segmentButtons{
            if item.tag == sender.tag{
                item.isSelected = true
            } else {
                item.isSelected = false
            }
        }
        
        if sender.tag > 0 {
            
            self.transactionList = self.transactionListFiltered.filter { transaction in
                
                if sender.tag == 1 {
                    return transaction.transType == "Deposited"
                }
                if sender.tag == 2 {
                    return transaction.transType?.contains("Withdrawn") ?? false
                }
                if sender.tag == 3 {
                    return transaction.transType == "Transferred"
                }
                return true
            }
            
        } else {
            self.transactionList = self.transactionListFiltered
        }
        self.transactionList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        self.tableView.reloadData()
    }
    
    //     MARK: - Done for ToolBar
    @objc func doneTapped(_ sender: UIButton) {
        if sender.tag == 1 {
            self.fromDateTF.text = Utils.getFormattedDateMMDDYYYY(date: fromDatePicker.date)
        } else {
            self.toDateTF.text = Utils.getFormattedDateMMDDYYYY(date: toDatePicker.date)
        }
        
        view.endEditing(true)
    }
    
    // MARK: - Cancel for ToolBar
    @objc func cancelClick(_ sender: UIButton) {
//        if sender.tag == 1 {
//            self.fromDateTF.text = ""
//        } else {
//            self.toDateTF.text = ""
//        }
        view.endEditing(true)
    }
    
    // MARK: - Search Button Tapped
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        if !self.fromDateTF.text!.isEmpty && !self.toDateTF.text!.isEmpty {
            
            self.pageNumber = 1
            self.pageNumber == 1 ? self.transactionList.removeAll() : ()
            self.pageNumber == 1 ? self.transactionListFiltered.removeAll() : ()
            
            self.buttonPressed(allButton)
            self.tableView.restore()
            self.showLoader()
            self.postGetTransactionList()
        } else {
            self.showToast(message: "Please provide search dates", delay: 2, toastType: .red)
        }
    }
}
extension TransactionsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactionList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionRecordCell") as? TransactionRecordCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(info: transactionList[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.transactionList.count - 10 && self.transactionList.count < self.viewModel.transactionListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.postGetTransactionList()
        }
    }
}

extension TransactionsVC: NetworkResponseProtocols {
    
    // MARK: - Transaction List Response
    func didGetTransactionList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.transactionListResponse?.data {
            
            self.pageNumber == 1 ? self.transactionList.removeAll() : ()
            
            self.transactionList.append(contentsOf: unwrappedList)
            self.transactionListFiltered.append(contentsOf: unwrappedList)
            
            self.tableView.reloadData()
            
            self.transactionList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            
            
        } else {
            self.showToast(message: viewModel.transactionListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.transactionList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
}
