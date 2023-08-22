//
//  WithdrawVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/10/2022.
//

import UIKit

class WithdrawVC: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var amountLBL: UILabel!
    @IBOutlet weak var amountView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var withdrawBtn: UIButton!
    
    var interactCollectionItem: [(String, UIImage)] = [
        ("Add New Account", UIImage(named: "bank-icon")!),
        ("Remove Account", UIImage(named: "binIcon")!)
    ]
    
    var bankAccountList: [BankAccountDM] = []
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Withdraw"
    }
    

    // MARK: - Configuring UI when loading
    func initUI() {
        
        setToolBarOnKeyboard(textField: self.amountTF)
        
        self.tableView.register(UINib(nibName: "BankAccountCell", bundle: nil), forCellReuseIdentifier: "BankAccountCell")
        self.collectionView.register(UINib(nibName: "CircleOptionsCell", bundle: nil), forCellWithReuseIdentifier: "CircleOptionsCell")
        
        self.amountTF.text = ""
        self.amountTF.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableView.dragDelegate = self
        self.tableView.dragInteractionEnabled = true
        
        self.collectionView.dropDelegate = self
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.getBankAccountList()
    }
    
    // MARK: - Fetch Bank Account List
    func getBankAccountList() {
        self.viewModel.getBankAccountList()
    }
    
    // MARK: - Remove Bank Account
    func removeBankAccount(accountIdentifier: String, object: BankAccountDM) {
        
        self.viewModel.removeBankAccount(accountIdentifier: accountIdentifier, object: object as AnyObject)
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.amountTF.text != "" && self.amountView.isHidden == true {
            self.withdrawBtn.isSelected = true
            self.amountLBL.text = "$\(Double(amountTF.text!)!)"
            self.textFieldView.isHidden = true
            self.amountView.isHidden = false
        } else {
            
            if self.validateFields() {
                
                if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "ConfirmWithdrawalVC") as? ConfirmWithdrawalVC {
                    vc.bankDetail = self.bankAccountList[self.tableView.indexPathForSelectedRow!.row]
                        vc.amount = Double(amountTF.text!)!
                        self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    // MARK: - Validate Fields on button Tap
    func validateFields() -> Bool {
        
        if amountTF.text!.isEmpty {
            self.showToast(message: "Please Enter an amount", toastType: .red)
            return false
        }
        if Double(amountTF.text!)! < 1.00 {
            self.showToast(message: "Amount must be at least $1.00 usd", toastType: .red)
            return false
        }
        if bankAccountList.isEmpty {
            self.showToast(message: "Please Add an account first", toastType: .red)
            return false
        }
        if self.tableView.indexPathForSelectedRow == nil {
            self.showToast(message: "Please Select an account first", toastType: .red)
            return false
        }
        return true
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        self.withdrawBtn.isSelected = false
        self.textFieldView.isHidden = false
        self.amountView.isHidden = true
        self.amountLBL.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // MARK: - Drop Session
    func canHandle(_ session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    /**
     A helper function that serves as an interface to the data mode, called
     by the `tableView(_:itemsForBeginning:at:)` method.
     */
    // MARK: - Drag Session
    func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
        //        let placeName = placeNames[indexPath.row]
        
        //        let data = placeName.data(using: .utf8)
        let itemProvider = NSItemProvider()
        
        //        itemProvider.registerDataRepresentation(forTypeIdentifier: kUTTypePlainText as String, visibility: .all) { completion in
        //            completion(data, nil)
        //            return nil
        //        }
        
        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }
}

extension WithdrawVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bankAccountList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BankAccountCell") as? BankAccountCell else {
            return UITableViewCell()
        }
        cell.configureCell(info: bankAccountList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if bankAccountList[indexPath.row].isStripeActive ?? false {
            return indexPath
        }
        self.showToast(message: "This account is being verified! You can use it after its successful verification", toastType: .red)
        return nil
    }
}

// MARK: - CollectionView Configuration - Dragging
extension WithdrawVC: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        scrollViewScrollToBottom(self.scrollView)
        
        let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        let dropItem = ["row" : "\(indexPath.row)",
                        "object": self.bankAccountList[indexPath.row]] as [String : Any]
        dragItem.localObject = dropItem
        return [dragItem]
    }
    
    func tableView(_ tableView: UITableView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let previewParameters = UIDragPreviewParameters()
        previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: CGFloat(self.tableView.cellForRow(at: indexPath)?.frame.width ??  120), height: CGFloat(self.tableView.cellForRow(at: indexPath)?.frame.height ?? 120)))
        return previewParameters
    }
}

// MARK: - CollectionView Configuration
extension WithdrawVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.interactCollectionItem.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircleOptionsCell", for: indexPath) as? CircleOptionsCell else {
                return UICollectionViewCell()
            }
            cell.titleLBL.text = self.interactCollectionItem[indexPath.row].0
            cell.featureIcon.image = self.interactCollectionItem[indexPath.row].1
            cell.cardView.backgroundColor = .systemBackground
            
            return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row == 0 {
            
            self.amountTF.resignFirstResponder()
            collectionView.deselectItem(at: indexPath, animated: false)
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "AddBankAccountVC") as? AddBankAccountVC {
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width / 2, height: 180)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: - CollectionView Configuration dropping
extension WithdrawVC: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
//        if collectionView === self.collectionView {
//            if collectionView.hasActiveDrag{
//
//                return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
//            }
//            else{
//                return UICollectionViewDropProposal(operation: .forbidden)
//            }
//        }
//        else{
            if collectionView.hasActiveDrag{
                return UICollectionViewDropProposal(operation: .copy, intent: .insertIntoDestinationIndexPath)
            }
            else{
                if let destinationIndexPath {
                    self.collectionView(self.collectionView, dropPreviewParametersForItemAt: destinationIndexPath)
                }
                return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
            }
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let destinationIndexPath : IndexPath
        
        print(coordinator.proposal.intent.rawValue)
        
        if let indexPath = coordinator.destinationIndexPath {
            
            destinationIndexPath = indexPath
            
        } else {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation {
            
        case .move:
            
            guard let sourceData = coordinator.items[0].dragItem.localObject as? [String: Any] else {
                return
            }
            
            guard let object = sourceData["object"] as? BankAccountDM else {
                return
            }
            let index = Int(sourceData["row"] as! String)!
            
            if destinationIndexPath.row == 1 { // accept cell
                
                guard let accountIdentifier = object.identifier else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    
                    return
                }
                
                Alert.sharedInstance.alertWindow(title: "Warning", message: "Are you sure you want to delete this account?") { result in
                    if result {
                        self.removeBankAccount(accountIdentifier: accountIdentifier, object: object)
                        self.bankAccountList.remove(at: index)
                        self.tableView.reloadData()
                        self.bankAccountList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                        self.collectionView(self.collectionView, dropPreviewParametersForItemAt: destinationIndexPath)
                        self.collectionView.reloadData()
                    }
                }
            }
            print("Moved")
            break
            
        case .copy:
            print("Copy")
        case .cancel:
            print("Cancelled Called")
        default:
            return
        }
    }
    func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession) {
        self.collectionView.reloadData()
        print("Called")
    }
    
    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters(forItemAt:indexPath)
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        print("Called Did End")
        self.collectionView.reloadData()
    }
    
    private func previewParameters(forItemAt indexPath:IndexPath) -> UIDragPreviewParameters? {
        
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? CircleOptionsCell else {
            return nil
        }
        
        let previewParameters = UIDragPreviewParameters()
        
        for cellItem in self.collectionView.visibleCells as! [CircleOptionsCell] {
            
            if cellItem == cell {
                
                switch indexPath.row {

                case 1:
                    cell.cardView.backgroundColor = UIColor(hexString: "#FFCDCD")
                    print("red")
                default:
                    cell.cardView.backgroundColor = .systemBackground
                    print("default called")
                }
            } else  {
                cellItem.cardView.backgroundColor = .systemBackground
            }
            
        }
        previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: CGFloat(self.collectionView.cellForItem(at: indexPath)?.frame.width ??  120), height: CGFloat(self.collectionView.cellForItem(at: indexPath)?.frame.height ?? 120)))
        return previewParameters
    }
}


// MARK: - TextField Configuration
extension WithdrawVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text! == "" && string == "." {
            return false
        }
        
//        if string == "0" && textField.text! == "" {
//            return false
//        }
        
        if string != "" {
            if "\(textField.text!)\(string)".split(separator: ".")[0].count > 8 {
                return false
            }
        }
        
        // only allow one decimal point
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
}


extension WithdrawVC: NetworkResponseProtocols {
    
    // MARK: - Bank Account List Response
    func didGetBankAccountList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.bankAccountListResponse?.data {
            self.bankAccountList.removeAll()
            self.bankAccountList.append(contentsOf: unwrappedList)
            self.tableView.reloadData()
            self.bankAccountList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: viewModel.bankAccountListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Remove Bank Account Response
    func didRemoveBankAccount(object: AnyObject) {
        
        if self.viewModel.removeBankAccountResponse?.isSuccess ?? false {
//            self.delegate?.refreshFriendList() // refresh friend list on MyFriendsVC
            self.showToast(message: self.viewModel.removeBankAccountResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: self.viewModel.removeBankAccountResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.bankAccountList.append(object as! BankAccountDM)
            self.tableView.reloadData()
            self.tableView.restore()
        }
    }
}

extension WithdrawVC: AppProtocol {
    
    // MARK: - Refresh Bank Account List after a new bank account is added in AddBankAccountVC
    func refreshBankAccountList() {
        self.getBankAccountList()
    }
}
