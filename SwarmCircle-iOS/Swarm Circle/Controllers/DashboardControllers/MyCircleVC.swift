//
//  MyCircleVC.swift
//  Swarm Circle
//
//  Created by Macbook on 05/07/2022.
//

import UIKit

class MyCircleVC: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var totalCircleCountLbl: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var discoverableImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tagCollectionView: UICollectionView!
    @IBOutlet weak var tagCollectionViewBaseHeightConstraint: NSLayoutConstraint!
    
    var circleOptions = [
        "Create a Circle",
        "Explore Circle",
        "Circle Invitations",
        "Circles Intersection"
    ]
    var iconsList = [
        "create_circle",
        "exploreCircle",
        "circle_invitations",
        "circleIntersection"
    ]
    
    var pageNumber: Int = 1
    var myCircleList: [JoinedCircleDM] = []
    
    var tagList: [TagDM] = []
    var tagListSelected: [TagDM] = []
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To My Circles"
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        self.tableView.bounces = false
        
        self.collectionView.register(UINib(nibName: "CircleOptionsCell", bundle: nil), forCellWithReuseIdentifier: "CircleOptionsCell")
        self.collectionView.register(UINib(nibName: "CircleIntersectionCell", bundle: nil), forCellWithReuseIdentifier: "CircleIntersectionCell")
        self.tableView.register(UINib(nibName: "CirclesInfoCell", bundle: nil), forCellReuseIdentifier: "CirclesInfoCell")
        self.tagCollectionView.register(UINib(nibName: "InterestsTagCell", bundle: nil), forCellWithReuseIdentifier: "InterestsTagCell")
        
        // Refresh Screen after circle is intersected
        NotificationCenter.default.addObserver(self, selector: #selector(refreshScreen), name: .refreshCircleScreen, object: nil)
        
        self.setupLongGestureRecognizerOnCollection()
        
        self.setDiscoverableImage()
        
        self.searchTF.delegate = self
        
        self.tableView.dragDelegate = self
        self.tableView.dragInteractionEnabled = true
        
        self.collectionView.dropDelegate = self
        
        self.scrollView.refreshControl = refreshControl
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetJoinedCircleList()
    }
    
    // MARK: - Fetch Joined Circle List
    func postGetJoinedCircleList() {
        
        let categoryNameArray = self.tagListSelected.map { $0.name ?? "" }
        
        self.viewModel.getJoinedCircleList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "", category: Utils.convertArrayToCommaSeperatedString(categoryNameArray))
    }
    
    // MARK: - Change Discoverable State
    func changeDiscoverableState(state: Bool = true) {
        self.showLoader()
        self.viewModel.changeDiscoveryState()
    }
    
    // MARK: - Change Discoverable Image
    fileprivate func setDiscoverableImage() {
        if PreferencesManager.getDiscoverableState() {
            self.discoverableImage.image = UIImage(named: "discoverable")
        }  else {
            self.discoverableImage.image = UIImage(named: "undiscoverable")
        }
    }
    
    // MARK: - Assigning long gesture to image
    private func setupLongGestureRecognizerOnCollection() {
    
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTap))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.discoverableImage.isUserInteractionEnabled = true
        self.discoverableImage.addGestureRecognizer(lpgr)
    }
    
    // MARK: - Action for long  pressed
    @objc func handleLongTap(gestureReconizer: UILongPressGestureRecognizer){
        print(gestureReconizer.state.rawValue)
        guard gestureReconizer.state == .began else { return }
        
        self.changeDiscoverableState()
    }
    
    // MARK: - Search/Filter Joined Circle List (using API)
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
            self.postGetJoinedCircleList()
        }
    }
    
    // MARK: - Filter Button Tapped
    @IBAction func filterBtnTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "TagListVC") as? TagListVC {
            
            let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
            navController.modalTransitionStyle = .coverVertical
            navController.modalPresentationStyle  = .overFullScreen
            
            vc.tagListSelected = self.tagListSelected
            
            vc.delegate = self

            self.present(navController, animated: true)
        }
    }
    
    // MARK: - Refresh Screen on Pull
    override func pullToRefreshActionPerformed() {
        
        refreshControl.endRefreshing()
        self.removeAllCirclesFromCircleIntersectionCell()
    
        self.refreshCircleList()
        
//        self.tagCollectionView.reloadData()
    }
    
    // MARK: - Remove All Circles from Circle Intersection Cell
    func removeAllCirclesFromCircleIntersectionCell() {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: 3, section: 0)) as? CircleIntersectionCell {
            cell.myCircleList.removeAll()
            cell.iconImage.isHidden = false
            cell.titleLBL.text = "Circle Intersection"
            cell.collectionView.reloadData()
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
extension MyCircleVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        self.tagCollectionViewBaseHeightConstraint.constant = self.tagListSelected.count > 0 ? 81 : 0
        
        return collectionView == self.collectionView ? self.circleOptions.count : self.tagListSelected.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == self.collectionView {
            
            if indexPath.item == 3 { // last cell (intersect circle cell)
                
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircleIntersectionCell", for: indexPath) as? CircleIntersectionCell else {
                    return UICollectionViewCell()
                }
                
                self.circleOptions[3] = cell.myCircleList.isEmpty ? "Circles Intersection" : "Drop Another Circle"
                
                cell.titleLBL.text = self.circleOptions[indexPath.row]
                cell.cardView.backgroundColor = .systemBackground
                cell.delegate = self
                return cell
                
            } else {
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircleOptionsCell", for: indexPath) as? CircleOptionsCell else {
                    return UICollectionViewCell()
                }
                
                cell.titleLBL.text = self.circleOptions[indexPath.row]
                cell.featureIcon.image = UIImage(named: self.iconsList[indexPath.row])
                //            cell.cardView.backgroundColor = .systemBackground
                return cell
            }
            
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InterestsTagCell", for: indexPath) as? InterestsTagCell else {
                return UICollectionViewCell()
            }
            cell.configureCell(self.tagListSelected[indexPath.row])
            cell.cellTapBtn.tag = indexPath.row
            cell.cellTapBtn.addTarget(self, action: #selector(self.removeTag(_:)), for: .touchUpInside)
            return cell
        }
    }
    
    @objc func removeTag(_ sender: UIButton) {
        self.tagListSelected.remove(at: sender.tag)
        self.tagCollectionViewBaseHeightConstraint.constant = self.tagListSelected.isEmpty ? 0 : 81
        self.tagCollectionView.reloadData()
        self.showLoader()
        self.postGetJoinedCircleList()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView == self.collectionView {
            
            self.collectionView.deselectItem(at: indexPath, animated: true)
            
            if indexPath.item == 3 { // last cell (intersect circle cell)
                self.tapCircleIntersectionCell()
                return
            }
            
            self.resetIntersectionCell()
            
            if indexPath.item == 0 {
                if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "CreateCircleVC") as? CreateCircleVC {
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            else if indexPath.item == 1 {
                if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "ExploreCircleVC") as? ExploreCircleVC {
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
            
            else if indexPath.item == 2 {
                if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CircleInvitationVC") as? CircleInvitationVC {
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == self.collectionView {
            return CGSize(width: self.collectionView.frame.width / 2, height: 180)
        }
        return CGSize(width: self.tagCollectionView.frame.width, height: self.tagCollectionView.frame.height)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView == self.collectionView {
            return 0
        }
        return 5
    }
}

// MARK: - TableView Configuration - Dropping
extension MyCircleVC: UICollectionViewDropDelegate {
    
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
        print(destinationIndexPath)
        switch coordinator.proposal.operation {
            
        case .move:
            
            if let cell = collectionView.cellForItem(at: destinationIndexPath) as? CircleIntersectionCell {
                
                guard let sourceData = coordinator.items[0].dragItem.localObject as? JoinedCircleDM else  {
                    return
                }
                
                if sourceData.isAdmin == false {
                    self.showToast(message: "You don't have Admin's rights", toastType: .black)
                    return
                }
                
                cell.iconImage.isHidden = true
                cell.myCircleList.append(sourceData)

//                if cell.myCircleList.count > 0 {
//                    self.circleOptions[3] = "Drop Another Circle"
//                } else {
//                    self.circleOptions[3] = "Circles Intersection"
//                }
                
                cell.collectionView.reloadData()
                self.myCircleList = self.myCircleList.filter { //Removing  Dropped circle from list
                    $0.circleID != sourceData.circleID
                }
                
            }
            self.tableView.reloadData()
            print("Moved")
            break
            
        case .copy:
            print("Copy")
            let cell = collectionView.cellForItem(at: destinationIndexPath) as! CircleIntersectionCell
            
            guard let sourceData = coordinator.items[0].dragItem.localObject as? JoinedCircleDM else  {
                return
            }
            
            if sourceData.isAdmin == false {
                self.showToast(message: "You don't have Admin's rights", toastType: .black)
                return
            }
            
            cell.iconImage.isHidden = true
            cell.myCircleList.append(sourceData)
            
            cell.collectionView.reloadData()
            
            self.myCircleList = self.myCircleList.filter { // Removing Dropped circle from list
                $0.circleID != sourceData.circleID
            }
            self.tableView.reloadData()
            break
        case .cancel:
            print("Cancelled Called")
        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidExit session: UIDropSession) {
//        self.interactCollectionView.reloadData()
        print("Called")
    }
    
    func collectionView(_ collectionView: UICollectionView, dropPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        return previewParameters(forItemAt:indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        self.collectionView.reloadData()
        print("Called Did End")
//        self.interactCollectionView.reloadData()
    }
    
    private func previewParameters(forItemAt indexPath:IndexPath) -> UIDragPreviewParameters? {
        
        if let cell = self.collectionView!.cellForItem(at: indexPath) as? CircleIntersectionCell {
            
            let previewParameters = UIDragPreviewParameters()
            
            cell.cardView.backgroundColor = UIColor(hexString: "#CCECFD")
            
            //        for cellItem in self.collectionView.visibleCells as! [CircleIntersectionCell] {
            //
            //            if cellItem == cell {
            //
            //                switch indexPath.row {
            //                case 0:
            //                    cell.cardView.backgroundColor = UIColor(hexString: "#D6E6FA")
            //
            //                    print("Blue")
            //                case 1:
            //                    cell.cardView.backgroundColor = UIColor(hexString: "#FFCDCD")
            //                    print("red")
            //                default:
            //                    cell.cardView.backgroundColor = .systemBackground
            //                    print("default called")
            //                }
            //                cell.cardView.backgroundColor = .systemBackground
            //            } else  {
            //                cell.cardView.backgroundColor = .systemBackground
            //            }
            //
            //        }
            previewParameters.visiblePath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: CGFloat(self.collectionView.cellForItem(at: indexPath)?.frame.width ??  120), height: CGFloat(self.collectionView.cellForItem(at: indexPath)?.frame.height ?? 120)))
            return previewParameters
        }
        return nil
    }
}

// MARK: - TableView Configuration
extension MyCircleVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.myCircleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CirclesInfoCell") as? CirclesInfoCell else {
            return UITableViewCell()
        }
        cell.configureCell(circleInfo: myCircleList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.myCircleList.count - 10 && self.myCircleList.count < self.viewModel.joinedCircleListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.postGetJoinedCircleList()
        }
        
        if indexPath.row + 2 == self.myCircleList.count {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 185), animated: true)
        } else if indexPath.row == 0 {
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        self.resetIntersectionCell()
        
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CircleDetailVC") as? CircleDetailVC {
            vc.circleIdentifier = myCircleList[indexPath.row].identifier
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Reset Intersection cell (Remove circle from intersection cell and append it back to tableview)
    fileprivate func resetIntersectionCell() {
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: 3, section: 0)) as? CircleIntersectionCell {
            
            if cell.myCircleList.isEmpty {
                return
            }
            
            for circle in cell.myCircleList {
                self.moveCircleBackToList(circleInfo: circle)
            }
            cell.myCircleList.removeAll()
            cell.iconImage.isHidden = false
            cell.titleLBL.text = "Circle Intersection"
            cell.collectionView.reloadData()
        }
    }

}

// MARK: - TableView Configuration - Dragging/Dropping
extension MyCircleVC: UITableViewDragDelegate, UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        print("Nothing")
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        self.collectionView.scrollToItem(at: IndexPath(row: 3, section: 0), at: .right, animated: true) // scroll
//        let itemProvider = NSItemProvider(object: "\(indexPath.row)" as NSString)
        let itemProvider = NSItemProvider(object: "Move" as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)

        let dropItem = self.myCircleList[indexPath.row]
        dragItem.localObject = dropItem
        
        self.scrollView.scrollToTop()
        
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
    
    func tableView(_ tableView: UITableView, dragSessionAllowsMoveOperation session: UIDragSession) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
}



// MARK: - Long Tap Gesture Configuration
extension MyCircleVC: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {

        return true
    }
}

extension MyCircleVC: NetworkResponseProtocols {
    
    // MARK: - Joined Circle List Response
    func didGetJoinedCircleList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.joinedCircleListResponse?.data {
            
            self.pageNumber == 1 ? self.myCircleList.removeAll() : ()
            
            self.myCircleList.append(contentsOf: unwrappedList)
            
            self.totalCircleCountLbl.text = "Total No. Of Circles: \(self.viewModel.joinedCircleListResponse?.recordCount ?? 0)"
            
            self.tableView.reloadData()
            
            self.myCircleList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            
        } else {
            self.showToast(message: self.viewModel.joinedCircleListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            
            self.myCircleList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }

    // MARK: - Change Discoverable State Response
    func didChangeDiscoverableState() {
        self.hideLoader()
        
        if self.viewModel.discoveryStateChangeResponse?.isSuccess ?? false {
 
            PreferencesManager.changeDiscoverableState()
            
            self.setDiscoverableImage()
            
        } else {
            self.showToast(message: viewModel.discoveryStateChangeResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}

extension MyCircleVC: UITextFieldDelegate {
    // MARK: - Search Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetJoinedCircleList()
        return true
    }
}

// MARK: - Observers
extension MyCircleVC {
    // MARK: - Refresh My Circle Screen after circle is intersected
    @objc func refreshScreen(notification: Notification) {
        self.refreshCircleList()
        self.removeAllCirclesFromCircleIntersectionCell()
    }
}

// MARK: - Protocols
extension MyCircleVC: AppProtocol {
    // MARK: - Refresh Circle List
    func refreshCircleList() {
        
        self.searchBtn.isSelected = false
        self.searchTF.resignFirstResponder()
        self.searchTF.isHidden = true
        self.searchTF.text = ""
        
        self.pageNumber = 1
        self.postGetJoinedCircleList()
    }
    
    // MARK: - Move Circle back to list (after cross button is clicked on circle intersection cell)
    func moveCircleBackToList(circleInfo: JoinedCircleDM) {
        self.myCircleList.insert(circleInfo, at: 0)
//        self.myCircleList.append(circleInfo)
        self.tableView.reloadData()
    }
    
    // MARK: - Remove Circle from circle intersection cell (after it is removed from intersection table view in CreateCircleIntersectionVC)
    func removeCircleFromIntersectionCell(circleInfo: JoinedCircleDM) {
        
        if let cell = self.collectionView?.cellForItem(at: IndexPath(row: 3, section: 0)) as? CircleIntersectionCell {
            cell.myCircleList = cell.myCircleList.filter { //Removing  Dropped circle from list
                $0.circleID != circleInfo.circleID
            }
            cell.collectionView.reloadData()
        }
    }
    
    // MARK: - Tap Circle Intersection cell when circle intersection collection view (contained with in circle intersection cell) is tapped.
    func tapCircleIntersectionCell() {
        
        let cell = self.collectionView.cellForItem(at: IndexPath(row: 3, section: 0)) as! CircleIntersectionCell
        
        if cell.myCircleList.count >= 2 {
            
            if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CreateCircleIntersectionVC") as? CreateCircleIntersectionVC {
                
                vc.circleList = cell.myCircleList
                vc.delegate = self
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            self.showToast(message: "Please add minimum 2 Circles", toastType: .black)
        }
    }
    
    // MARK: - Set selected tags in MyCircleVC's tagCollectionView.
    func setAndApplySelectedFilter(tagListSelected: [TagDM]) {
        
        self.tagListSelected = tagListSelected
        self.tagCollectionView.reloadData()
        
        self.showLoader()
        self.myCircleList = []
        self.postGetJoinedCircleList()
    }
}
