//
//  MyFriendsVC.swift
//  Swarm Circle
//
//  Created by Macbook on 06/07/2022.
//

import UIKit

class MyFriendsVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var interactCollectionView: UICollectionView! // drop collection view
    @IBOutlet weak var collectionView: UICollectionView! // drag collection view

    var interactCollectionItem: [(String, UIImage)] = [
        ("Invite a Friend",     UIImage(named: "inviteIcon")!),
        ("Remove Friend",       UIImage(named: "binIcon")!),
        ("Block Friend",        UIImage(named: "blockFriendIcon")!),
        ("Pending Invitations", UIImage(named: "pendingIcon")!),
        ("Block List",          UIImage(named: "blockIcon")!)
    ]
    
    var pageNumber: Int = 1
    var friendList: [FriendDM] = []

    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Friends"
    }
    
    // MARK: - Configuring UI when loading
    func initUI(){
        self.collectionView.tag = 1
        self.interactCollectionView.tag = 2
        self.collectionView.register(UINib(nibName: "FriendCell", bundle: nil), forCellWithReuseIdentifier: "FriendCell")
        self.interactCollectionView.register(UINib(nibName: "CircleOptionsCell", bundle: nil), forCellWithReuseIdentifier: "CircleOptionsCell")
        
//         Refresh Screen after circle is intersected
//        NotificationCenter.default.addObserver(self, selector: #selector(refreshScreen), name: .refreshFriendList, object: nil)
        
        self.searchTF.delegate = self
        
        self.collectionView.dragDelegate = self
        self.collectionView.dragInteractionEnabled = true
        
        self.interactCollectionView.dropDelegate = self
        
        self.scrollView.refreshControl = refreshControl
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetFriendsList()
    }
    
    // MARK: - Fetch Friend Request List
    func postGetFriendsList() {
        self.viewModel.getFriendsList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "")
    }
    
    // MARK: - Remove Friend
    func removeFriend(userId: Int, object: FriendDM) {
        self.viewModel.removeFriend(params: ["userId": userId], object: object as AnyObject)
    }
    
    // MARK: - Block Friend
    func blockFriend(userId: Int, object: FriendDM) {
        self.viewModel.blockFriend(params: ["userId": userId], object: object as AnyObject)
    }
    
    // MARK: - Invite Friend Tapped (Connect with more friends)
    @IBAction func inviteFriendTapped(_ sender: Any) {
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "ConnectWithFriendsVC") as? ConnectWithFriendsVC{
            vc.view.backgroundColor = .lightGray
            vc.view.alpha = 0.7
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: true)
        }
    }
    
    // MARK: - Search/Filter Friend List (using API)
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
            self.postGetFriendsList()
        }
        
    }
    
    // MARK: - Refresh Friend List on Pull
    @objc override func pullToRefreshActionPerformed() { 
        refreshControl.endRefreshing()
        self.refreshFriendList()
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
extension MyFriendsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == interactCollectionView ? self.interactCollectionItem.count : self.friendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 { // tag == 1 -> Drag collection view (friend list)
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FriendCell", for: indexPath) as? FriendCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(userInfo: self.friendList[indexPath.row])
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
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            if indexPath.row == self.friendList.count - 10 && self.friendList.count < self.viewModel.friendListResponse?.recordCount ?? 0 {
                self.pageNumber += 1
                self.postGetFriendsList()
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 1 {
            
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
                vc.delegate = self
                vc.sourceController = .MyFriendsVC
                vc.profileIdentifier = friendList[indexPath.row].identifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        if collectionView.tag == 2 {
            switch indexPath.row {
            case 0:
                
//                if self.friendList[indexPath.row].
                
                if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "ConnectWithFriendsVC") as? ConnectWithFriendsVC {
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            case 1:
                print("Remove Friend Cell Taped (do nothing)")
            case 2:
                print("Block Friend Cell Taped (do nothing)")
            case 3:
                
                if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "PendingFriendRequestVC") as? PendingFriendRequestVC { // pending invitation
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                
            case 4:
                if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "BlockedFriendsVC") as? BlockedFriendsVC { //block list
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            default:
                print("Default case switch collection view")
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 1{
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
extension MyFriendsVC: UICollectionViewDragDelegate {
    
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem]
    {
        self.interactCollectionView.scrollToItem(at: IndexPath(row: 2, section: 0), at: .right, animated: true) // scroll
        
        let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)

        let dropItem = ["row" : "\(indexPath.row)",
                        "object": self.friendList[indexPath.row]] as [String : Any]
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
extension MyFriendsVC: UICollectionViewDropDelegate {
    
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool{
        return session.canLoadObjects(ofClass: NSString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal{
        if collectionView === self.collectionView {
            
            if collectionView.hasActiveDrag {
                
                return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
            }
            else{
                return UICollectionViewDropProposal(operation: .forbidden)
            }
        }
        else{
            if collectionView.hasActiveDrag {
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
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator){
        
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
            
            guard let object = sourceData["object"] as? FriendDM else {
                return
            }
            
            let index = Int(sourceData["row"] as! String)!
            
                guard let userId = object.id else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    return
                }
                
                if destinationIndexPath.row == 1 { // remove cell
                    
                    self.removeFriend(userId: userId, object: object)
                    self.friendList.remove(at: index)
                    self.collectionView.reloadData()
                    self.friendList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
                    self.collectionView(self.interactCollectionView, dropPreviewParametersForItemAt: destinationIndexPath)
                    
                } else if destinationIndexPath.row == 2 { // block cell
                    
                    self.blockFriend(userId: userId, object: object)
                    self.friendList.remove(at: index)
                    self.collectionView.reloadData()
                    self.friendList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
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
                case 1:
                    cell.cardView.backgroundColor = UIColor(hexString: "#FFCDCD")
                    print("red (remove)")
                case 2:
                    cell.cardView.backgroundColor = UIColor(hexString: "#FFCDCD")
                    print("red (block)")
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

extension MyFriendsVC: NetworkResponseProtocols {
    
    // MARK: - Friend List Response
    func didGetFriendsList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.friendListResponse?.data {
            
            self.pageNumber == 1 ? self.friendList.removeAll() : ()
            
            self.friendList.append(contentsOf: unwrappedList)
            self.collectionView.reloadData()
            self.friendList.count == 0 ? self.collectionView.setEmptyView("No Data Found", "") : self.collectionView.restore()
        } else {
            self.showToast(message: viewModel.friendListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Remove Friend Response
    func didRemovedFriend(object: AnyObject) {

        if viewModel.removeFriendResponse?.data ?? false {
            self.showToast(message: viewModel.removeFriendResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: viewModel.removeFriendResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.friendList.append(object as! FriendDM)
            self.collectionView.reloadData()
            self.collectionView.restore()
        }
    }
    
    // MARK: - Block Friend Response
    func didBlockedFriend(object: AnyObject) {
        
        if viewModel.blockFriendResponse?.data ?? false {
            self.showToast(message: viewModel.blockFriendResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: viewModel.blockFriendResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.friendList.append(object as! FriendDM)
            self.collectionView.reloadData()
            self.collectionView.restore()
        }
    }
}

extension MyFriendsVC: UITextFieldDelegate {
    // MARK: - Search Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetFriendsList()
        return true
    }
}

extension MyFriendsVC: AppProtocol {
    
    // MARK: - Refresh Friend List
    func refreshFriendList() {
        self.pageNumber = 1
        self.postGetFriendsList()
    }
}
