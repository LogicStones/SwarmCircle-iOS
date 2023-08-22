//
//  CircleInvitation.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/08/2022.
//

import UIKit

class CircleInvitationVC: BaseViewController {

    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var collectionView: UICollectionView! // drop collection view
    @IBOutlet weak var tableView: UITableView! // drag table view

    var interactCollectionItem: [(String, UIImage)] = [
        ("Accept", UIImage(named: "acceptIcon")!),
        ("Reject", UIImage(named: "rejectIcon")!)
    ]
    
    var pageNumber: Int = 1
    var pendingCircleInviteList: [PendingCircleInviteDM] = []
    
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
        self.collectionView.register(UINib(nibName: "CircleOptionsCell", bundle: nil), forCellWithReuseIdentifier: "CircleOptionsCell")
        self.tableView.register(UINib(nibName: "CirclesInfoCell", bundle: nil), forCellReuseIdentifier: "CirclesInfoCell")

        self.searchTF.delegate = self
        
        self.tableView.dragDelegate = self
        self.tableView.dragInteractionEnabled = true

        self.collectionView.dropDelegate = self
    }
    
    // MARK: - Load data from API
    func initVariable() {

        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetPendingCircleInviteList()
    }
    
    // MARK: - Fetch Pending Circle Invite List
    func postGetPendingCircleInviteList() {
        self.viewModel.getPendingCircleInviteList(pageNumber: pageNumber, searchText: searchTF.text!)
    }
    
    // MARK: - Accept Circle Invite Request
    func acceptInviteRequest(inviteId: Int, object: PendingCircleInviteDM) {
        self.viewModel.acceptCircleInviteRequest(inviteId: inviteId, object: object as AnyObject)
    }
    
    // MARK: - Reject Circle Invite Request
    func rejectInviteRequest(inviteId: Int, object: PendingCircleInviteDM) {
        self.viewModel.rejectCircleInviteRequest(inviteId: inviteId, object: object as AnyObject)
    }
    
    // MARK: - Search/Filter Pending Circle Invite List (using API)
    @IBAction func searchNCloseBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.searchTF.becomeFirstResponder()
            self.searchTF.isHidden = false
        } else {
            self.searchTF.resignFirstResponder()
            self.searchTF.isHidden = true
            
            self.searchTF.text = ""
            self.pageNumber = 1
            self.postGetPendingCircleInviteList()
        }
        
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

        let itemProvider = NSItemProvider()

        return [
            UIDragItem(itemProvider: itemProvider)
        ]
    }

}

// MARK: - CollectionView Configuration
extension CircleInvitationVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
        self.collectionView.deselectItem(at: indexPath, animated: true)
        
//        if indexPath.item == 0 {
//
//        }
//        else if indexPath.item == 1{
//
//        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.frame.width / 2, height: 180)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - CollectionView Configuration dropping
extension CircleInvitationVC: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        
        // Optimize later, extra code can be removed because we have only one collection view in this controller
//        if collectionView !== self.collectionView {
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
            
            guard let object = sourceData["object"] as? PendingCircleInviteDM else {
                return
            }

            let index = Int(sourceData["row"] as! String)!
            
            if destinationIndexPath.row == 0 { // accept cell
                
                guard let inviteId = object.id else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    return
                }
                self.acceptInviteRequest(inviteId: inviteId, object: object)
                self.pendingCircleInviteList.remove(at: index)
                self.tableView.reloadData()
                self.pendingCircleInviteList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                self.collectionView(self.collectionView, dropPreviewParametersForItemAt: destinationIndexPath)
                
            } else if destinationIndexPath.row == 1 { // reject cell
                
                guard let inviteId = object.id else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    return
                }
                self.rejectInviteRequest(inviteId: inviteId, object: object)
                self.pendingCircleInviteList.remove(at: index)
                self.tableView.reloadData()
                self.pendingCircleInviteList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                self.collectionView(self.collectionView, dropPreviewParametersForItemAt: destinationIndexPath)
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
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        print("Called Did End")
        self.collectionView.reloadData()
    }
    
    private func previewParameters(forItemAt indexPath:IndexPath) -> UIDragPreviewParameters? {
        
        let cell = self.collectionView!.cellForItem(at: indexPath) as! CircleOptionsCell
        
        let previewParameters = UIDragPreviewParameters()
        
        for cellItem in self.collectionView.visibleCells as! [CircleOptionsCell] {
            
            if cellItem == cell {
                
                switch indexPath.row {
                case 0:
                    cell.cardView.backgroundColor = UIColor(hexString: "#D6E6FA")
                    
                    print("Blue")
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

// MARK: - TableView Configuration
extension CircleInvitationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pendingCircleInviteList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CirclesInfoCell") as? CirclesInfoCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(circleInfo: self.pendingCircleInviteList[indexPath.row])
        cell.membersListStack.isHidden = true
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.pendingCircleInviteList.count - 10 && self.pendingCircleInviteList.count < self.viewModel.pendingCircleInviteListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.postGetPendingCircleInviteList()
        }
    }
}

// MARK: - TableView Configuration - Dragging
extension CircleInvitationVC: UITableViewDragDelegate {
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        let dropItem = ["row" : "\(indexPath.row)",
                        "object": self.pendingCircleInviteList[indexPath.row]] as [String : Any]
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

extension CircleInvitationVC: NetworkResponseProtocols {
    
    // MARK: - Pending Circle Invite List Response
    func didGetPendingCircleInviteList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.pendingCircleInviteListResponse?.data {
            
            self.pageNumber == 1 ? self.pendingCircleInviteList.removeAll() : ()
            
            self.pendingCircleInviteList.append(contentsOf: unwrappedList)
            
            self.tableView.reloadData()
            
            self.pendingCircleInviteList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            
        } else {
            self.showToast(message: viewModel.pendingCircleInviteListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingCircleInviteList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
    
    // MARK: - Accept Circle Invite Request Response
    func didAcceptCircleInviteRequest(object: AnyObject) {

        if let _ = viewModel.acceptCircleInviteRequestResponse?.data {
            self.showToast(message: viewModel.acceptCircleInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            self.delegate?.refreshCircleList()
        } else {
            self.showToast(message: viewModel.acceptCircleInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingCircleInviteList.append(object as! PendingCircleInviteDM)
            self.tableView.reloadData()
            self.tableView.restore()
        }
    }
    
    // MARK: - Reject Circle Invite Request Response
    func didRejectCircleInviteRequest(object: AnyObject) {

        if viewModel.rejectCircleInviteRequestResponse?.data ?? false {
            self.showToast(message: viewModel.rejectCircleInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: viewModel.rejectCircleInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingCircleInviteList.append(object as! PendingCircleInviteDM)
            self.tableView.reloadData()
            self.tableView.restore()
        }
    }
}

extension CircleInvitationVC: UITextFieldDelegate {
    
    // MARK: - Search Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetPendingCircleInviteList()
        return true
    }
}
