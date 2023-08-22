//
//  PendingFriendRequestVC.swift
//  Swarm Circle
//
//  Created by Macbook on 26/08/2022.
//

import UIKit

class PendingFriendRequestVC: BaseViewController {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var interactCollectionView: UICollectionView! // drop collection view
    @IBOutlet weak var collectionView: UICollectionView! // drag collection view
    
    var interactCollectionItem: [(String, UIImage)] = [
        ("Accept", UIImage(named: "acceptIcon")!),
        ("Reject", UIImage(named: "rejectIcon")!)
    ]
    
    var pageNumber: Int = 1
    var pendingFriendsList: [PendingUserDM] = []
    
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
        self.collectionView.tag = 1
        self.interactCollectionView.tag = 2
        self.collectionView.register(UINib(nibName: "FriendCell", bundle: nil), forCellWithReuseIdentifier: "FriendCell")
        self.interactCollectionView.register(UINib(nibName: "CircleOptionsCell", bundle: nil), forCellWithReuseIdentifier: "CircleOptionsCell")
        
        self.searchTF.delegate = self
        
        self.collectionView.dragDelegate = self
        self.collectionView.dragInteractionEnabled = true
        
        self.interactCollectionView.dropDelegate = self
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetPendingFriendsList()
    }
    
    // MARK: - Fetch Pending Friend Request List
    func postGetPendingFriendsList() {
        self.viewModel.getPendingFriendsList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "")
    }
    
    // MARK: - Accept Friend Request
    func acceptRequest(userId: Int, requestId: Int, object: PendingUserDM) {
        self.viewModel.acceptFriendInviteRequest(params: ["userId": userId, "requestId": requestId], object: object as AnyObject)
    }
    
    // MARK: - Reject Friend Request
    func rejectRequest(id: Int, object: PendingUserDM) {
        self.viewModel.rejectFriendInviteRequest(params: ["requestId": id], object: object as AnyObject)
    }
    
    // MARK: - Search/Filter Pending Friend Request List (using API)
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
            self.postGetPendingFriendsList()
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
// MARK: - CollectionView Configuration
extension PendingFriendRequestVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.interactCollectionView ? self.interactCollectionItem.count : self.pendingFriendsList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 { // tag == 1 -> Drag collection view (pending friend list)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as? FriendCell else {
                return UICollectionViewCell()
            }
            
            cell.configureCell(userInfo: pendingFriendsList[indexPath.row])
            
            return cell
            
        } else { // Drop collection view
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircleOptionsCell", for: indexPath) as? CircleOptionsCell else {
                return UICollectionViewCell()
            }
            cell.titleLBL.text = self.interactCollectionItem[indexPath.row].0
            cell.featureIcon.image = self.interactCollectionItem[indexPath.row].1
            cell.cardView.backgroundColor = .systemBackground
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.searchTF.resignFirstResponder()
        collectionView.deselectItem(at: indexPath, animated: true)
        
        if collectionView.tag == 1 {
            
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
                
                vc.profileIdentifier = pendingFriendsList[indexPath.row].identifier
                vc.sourceController = .PendingFriendRequestVC
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            if indexPath.row == self.pendingFriendsList.count - 10 && self.pendingFriendsList.count < self.viewModel.pendingFriendsListResponse?.recordCount ?? 0 {
                self.pageNumber += 1
                self.postGetPendingFriendsList()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1 { // tag == 1 -> Drag collection view (pending friend list)
            return CGSize(width: self.collectionView.frame.width / 2, height: 70)
        } else {
            return CGSize(width: self.interactCollectionView.frame.width / 2, height: 180)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
}

// MARK: - CollectionView Configuration - Dragging
extension PendingFriendRequestVC: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        let dropItem = ["row" : "\(indexPath.row)",
                        "object": self.pendingFriendsList[indexPath.row]] as [String : Any]
        dragItem.localObject = dropItem
        return [dragItem]
        
    }
    
    func collectionView(_ collectionView: UICollectionView, dragSessionIsRestrictedToDraggingApplication session: UIDragSession) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters?{
        let previewParameters = UIDragPreviewParameters()
        previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: CGFloat(self.collectionView.cellForItem(at: indexPath)?.frame.width ??  120), height: CGFloat(self.collectionView.cellForItem(at: indexPath)?.frame.height ?? 120)))
        return previewParameters
    }
}

// MARK: - CollectionView Configuration dropping
extension PendingFriendRequestVC: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView === self.collectionView {
            if collectionView.hasActiveDrag{
                
                return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
            }
            else{
                return UICollectionViewDropProposal(operation: .forbidden)
            }
        }
        else{
            if collectionView.hasActiveDrag{
                return UICollectionViewDropProposal(operation: .copy, intent: .insertIntoDestinationIndexPath)
            }
            else{
                if let destinationIndexPath {
                    self.collectionView(self.interactCollectionView, dropPreviewParametersForItemAt: destinationIndexPath)
                }
                return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
            }
        }
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
            
            guard let object = sourceData["object"] as? PendingUserDM else {
                return
            }
            let index = Int(sourceData["row"] as! String)!
            
            if destinationIndexPath.row == 0 { // accept cell
                
                guard
                    let userId = object.userID,
                    let requestId = object.id
                        
                else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    return
                }
                self.acceptRequest(userId: userId, requestId: requestId, object: object)
                self.pendingFriendsList.remove(at: index)
                self.collectionView.reloadData()
                self.pendingFriendsList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
                self.collectionView(self.interactCollectionView, dropPreviewParametersForItemAt: destinationIndexPath)
                
            } else if destinationIndexPath.row == 1 { // reject cell
                
                guard let id = object.id else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    return
                }
                self.rejectRequest(id: id, object: object)
                self.pendingFriendsList.remove(at: index)
                self.collectionView.reloadData()
                self.pendingFriendsList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
                self.collectionView(self.interactCollectionView, dropPreviewParametersForItemAt: destinationIndexPath)
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
        self.interactCollectionView.reloadData()
        print("Called")
    }
    
    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters(forItemAt:indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        print("Called Did End")
        self.interactCollectionView.reloadData()
    }
    
    private func previewParameters(forItemAt indexPath:IndexPath) -> UIDragPreviewParameters? {
        
        let cell = self.interactCollectionView!.cellForItem(at: indexPath) as! CircleOptionsCell
        
        let previewParameters = UIDragPreviewParameters()
        
        for cellItem in self.interactCollectionView.visibleCells as! [CircleOptionsCell] {
            
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
        previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: CGFloat(self.interactCollectionView.cellForItem(at: indexPath)?.frame.width ??  120), height: CGFloat(self.interactCollectionView.cellForItem(at: indexPath)?.frame.height ?? 120)))
        return previewParameters
    }
}

extension PendingFriendRequestVC: NetworkResponseProtocols {
    
    // MARK: - Pending Friend Request List Response
    func didGetPendingFriendsList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.pendingFriendsListResponse?.data {
            
            self.pageNumber == 1 ? self.pendingFriendsList.removeAll() : ()
            
            self.pendingFriendsList.append(contentsOf: unwrappedList)
            
            self.collectionView.reloadData()
            
            self.pendingFriendsList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
            
        } else {
            self.showToast(message: viewModel.pendingFriendsListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingFriendsList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
        }
    }
    
    // MARK: - Accept Friend Request Response
    func didAcceptFriendInviteRequest(object: AnyObject) {
        
        if viewModel.acceptFriendInviteRequestResponse?.data ?? false {
            self.delegate?.refreshFriendList() // refresh friend list on MyFriendsVC
            self.showToast(message: viewModel.acceptFriendInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: viewModel.acceptFriendInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingFriendsList.append(object as! PendingUserDM)
            self.collectionView.reloadData()
            self.collectionView.restore()
        }
    }
    
    // MARK: - Reject Friend Request Response
    func didRejectFriendInviteRequest(object: AnyObject) {
        
        if viewModel.rejectFriendInviteRequestResponse?.data ?? false {
            self.showToast(message: viewModel.rejectFriendInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: viewModel.rejectFriendInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingFriendsList.append(object as! PendingUserDM)
            self.collectionView.reloadData()
            self.collectionView.restore()
        }
    }
}

extension PendingFriendRequestVC: UITextFieldDelegate {
    
    // MARK: - Search Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetPendingFriendsList()
        return true
    }
}

extension PendingFriendRequestVC: AppProtocol {
    
    // MARK: - Refresh Pending Friend List after accepting/rejecting Friend Request in ViewProfileVC
    func refreshPendingFriendList(refreshList: Int) { // 0: pending friend request list and friend list (Accept), 1: pending friend request list (Reject), 2: friend list (Remove)
        
        switch refreshList {
        case 0: // pending friend request list and friend list (Accept)
            self.pageNumber = 1
            self.postGetPendingFriendsList()
            self.delegate?.refreshFriendList()
            break
        case 1: // 1: pending friend request list (Reject)
            self.pageNumber = 1
            self.postGetPendingFriendsList()
            break
        case 2: // 2: friend list (Remove)
            self.delegate?.refreshFriendList()
            break
            
        default:
            print("Switch default case")
        }
    }
}
