//
//  PendingCirclesVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/08/2022.
//

import UIKit

class PendingCirclesVC: BaseViewController {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var interactCollectionView: UICollectionView! // drop collection view
    @IBOutlet weak var collectionView: UICollectionView! // drag collection view

    var interactCollectionItem: [(String, UIImage)] = [
        ("Accept", UIImage(named: "acceptIcon")!),
        ("Reject", UIImage(named: "rejectIcon")!)
    ]
    
    var pageNumber: Int = 1
    var pendingCircleJoinList: [PendingCircleJoinDM] = []
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    var circleIdentifier: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
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
        
        guard let circleIdentifier = circleIdentifier else {
            Alert.sharedInstance.alertOkWindow(title: "", message: "Some Error Occured, please try again later") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            return
        }
        
        self.showLoader()
        self.postGetPendingCircleJoinList(circleIdentifier: circleIdentifier)
    }
    
    // MARK: - Fetch Pending Circle Join List
    func postGetPendingCircleJoinList(circleIdentifier: String) {
        self.viewModel.getPendingCircleJoinList(circleIdentifier: circleIdentifier, pageNumber: pageNumber, searchText: searchTF.text!)
    }
    
    // MARK: - Accept Circle Join Request
    func acceptCircleRequest(inviteId: Int, object: PendingCircleJoinDM) {
        self.viewModel.acceptCircleJoinRequest(inviteId: inviteId, object: object as AnyObject)
    }
    
    // MARK: - Reject Circle Join Request
    func rejectCircleRequest(inviteId: Int, object: PendingCircleJoinDM) {
        self.viewModel.rejectCircleJoinRequest(inviteId: inviteId, object: object as AnyObject)
    }
    
    // MARK: - Search/Filter Pending Circle Join List (using API)
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
            self.postGetPendingCircleJoinList(circleIdentifier: self.circleIdentifier!)
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
extension PendingCirclesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == interactCollectionView ? self.interactCollectionItem.count : self.pendingCircleJoinList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 { // tag == 1 -> Drag collection view (pending join circle list)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as? FriendCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(userInfo: self.pendingCircleJoinList[indexPath.row])
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
        
        if collectionView.tag == 1 {
            self.searchTF.resignFirstResponder()
            
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
                
                vc.profileIdentifier = self.pendingCircleJoinList[indexPath.row].identifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            if indexPath.row == self.pendingCircleJoinList.count - 10 && self.pendingCircleJoinList.count < self.viewModel.pendingCircleJoinListResponse?.recordCount ?? 0 {
                self.pageNumber += 1
                self.postGetPendingCircleJoinList(circleIdentifier: circleIdentifier!)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1 { // tag == 1 -> Drag collection view (pending join circle list)
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
extension PendingCirclesVC: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        
        let dropItem = ["row" : "\(indexPath.row)",
                        "object": self.pendingCircleJoinList[indexPath.row]] as [String : Any]
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
extension PendingCirclesVC: UICollectionViewDropDelegate {
    
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
            
            guard let object = sourceData["object"] as? PendingCircleJoinDM else {
                return
            }

            let index = Int(sourceData["row"] as! String)!
            
            if destinationIndexPath.row == 0 { // accept cell
                
                guard let inviteId = object.inviteID else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    return
                }
                self.acceptCircleRequest(inviteId: inviteId, object: object)
                self.pendingCircleJoinList.remove(at: index)
                self.collectionView.reloadData()
                self.pendingCircleJoinList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
                self.collectionView(self.interactCollectionView, dropPreviewParametersForItemAt: destinationIndexPath)
                
            } else if destinationIndexPath.row == 1 { // reject cell
                
                guard let inviteId = object.inviteID else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    return
                }
                self.rejectCircleRequest(inviteId: inviteId, object: object)
                self.pendingCircleJoinList.remove(at: index)
                self.collectionView.reloadData()
                self.pendingCircleJoinList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
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



extension PendingCirclesVC: NetworkResponseProtocols {
    
    // MARK: - Pending Circle Join List Response
    func didGetPendingCircleJoinList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.pendingCircleJoinListResponse?.data {
            
            self.pageNumber == 1 ? self.pendingCircleJoinList.removeAll() : ()
            
            self.pendingCircleJoinList.append(contentsOf: unwrappedList)
            
            self.collectionView.reloadData()
            
            self.pendingCircleJoinList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
        } else {
            self.showToast(message: viewModel.pendingCircleJoinListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingCircleJoinList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
        }
    }
    
    // MARK: - Accept Circle Join Request Response
    func didAcceptCircleJoinRequest(object: AnyObject) {

        if viewModel.acceptCircleJoinRequestResponse?.data ?? false {
            self.delegate?.refreshCircleDetail()
            self.showToast(message: viewModel.acceptCircleJoinRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: viewModel.acceptCircleJoinRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingCircleJoinList.append(object as! PendingCircleJoinDM)
            self.collectionView.reloadData()
            self.collectionView.restore()
        }
    }
    
    // MARK: - Reject Circle Join Request Response
    func didRejectCircleJoinRequest(object: AnyObject) {
        
        if viewModel.rejectCircleJoinRequestResponse?.data ?? false {
            self.showToast(message: viewModel.rejectCircleJoinRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: viewModel.rejectCircleJoinRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pendingCircleJoinList.append(object as! PendingCircleJoinDM)
            self.collectionView.reloadData()
            self.collectionView.restore()
        }
    }
}

extension PendingCirclesVC: UITextFieldDelegate {
    
    // MARK: - Search Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetPendingCircleJoinList(circleIdentifier: circleIdentifier!)
        return true
    }
}
