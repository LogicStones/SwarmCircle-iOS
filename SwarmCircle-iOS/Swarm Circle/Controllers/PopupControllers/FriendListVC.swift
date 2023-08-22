//
//  FriendListVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 27/12/2022.
//

import UIKit

class FriendListVC: BaseViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var actIndView: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!
    
    enum ControllerTitle: String {
        case addFriends = "Add Friends"
        case tagFriends = "Tag Friends"
        case selectFriends = "Select Friends"
        case shareWithFriends = "Share With Friends"
        case shareWithFriendsExcept = "Share With Friends Except"
    }
    
    enum SelectionType: String { // tableView selection (multiple/single)
        case single
        case multiple
    }
    
    enum DestinationController: String { // next action/controller after pressing done button
        case createCircleVC
        case transferVC
        case createPostVC
    }
    
    enum AdditionalParamsKey: String { // any other params
        case isUpdatingShareWithOrExceptList
    }
    
    var controllerTitle: ControllerTitle?
    var selection: SelectionType? // tableView selection (multiple/single)
    var destinationController: DestinationController? // next action/controller after pressing done button
    var additionalParams:[AdditionalParamsKey: Any?] = [:] // any other params
    
    var pageNumber: Int = 1
    var friendList: [FriendDM] = [] // array to hold fetched friend list
    var friendListSelected: [FriendDM] = [] // array to hold selected friend list this will only be altered when user selects/deselects a row.
    var friendListSelectedFiltered: [FriendDM] = []
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configure UI when loading
    func initUI() {

        guard let controllerTitle = self.controllerTitle?.rawValue else {
            self.dismissOnErrorAlert("Controller title missing")
            return
        }
        guard let _ = selection else {
            self.dismissOnErrorAlert("Selection type (single/multiple) missing")
            return
        }
        guard let _ = destinationController else {
            self.dismissOnErrorAlert("Destination action/controller missing")
            return
        }
        
        self.titleLbl.text = controllerTitle
        
        self.tableView.register(UINib(nibName: "FriendsListCell", bundle: nil), forCellReuseIdentifier: "FriendsListCell")
        self.tableView.allowsMultipleSelection = self.selection == .multiple ? true : false
    }
    
    // MARK: - Load Data
    func initVariable() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // put delay in loader, to avoid UI glitch, (because loader is displayed before this controller is properly presented)
            
            self.viewModel.delegateNetworkResponse = self
            self.showLoader()
            self.fetchFriendList()
        }
    }
    
    // MARK: - Fetch friend list
    func fetchFriendList() {
        
        self.friendListSelectedFiltered = self.friendListSelected
        
        self.viewModel.getFriendsList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "")
    }
    
    // MARK: - Cross Button Tapped
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Done Button Tapped
    @IBAction func doneTapped(_ sender: UIButton) {
        
        switch destinationController {
            
        case .createCircleVC:
            
            if self.friendListSelected.isEmpty {
                self.showToast(message: "Atleast 1 member is required to create circle", toastType: .red)
                return
            }
            
            self.dismiss(animated: true) {
                self.delegate?.updateSelectedFriendList(friendListSelected: self.friendListSelected)
            }
            
        case .transferVC:
            
            if self.friendListSelected.isEmpty {
                self.showToast(message: "Please select a friend to transfer", toastType: .red)
                return
            }
            
            self.dismiss(animated: true) {
                self.delegate?.setReceiverWalletId(selectedFriend: self.friendListSelected.first)
            }
            
        case .createPostVC:
            
            self.dismiss(animated: true) {
                
                (self.additionalParams[.isUpdatingShareWithOrExceptList] as? Bool == true) ? self.delegate?.updateShareWithORExceptSelectedFriendList(shareWithORExceptfriendListSelected: self.friendListSelected) : self.delegate?.updateSelectedFriendList(friendListSelected: self.friendListSelected)
            }
            
        case .none:
            print("No value selected for destination controller in CircleMemberListVC")
        }
    }
}

// MARK: - TableView Configuration
extension FriendListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell") as? FriendsListCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(self.friendList[indexPath.row])
        
        if self.friendList[indexPath.row].isSelected ?? false {
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        cell.profilePicBtn.tag = indexPath.row
        cell.profilePicBtn.addTarget(self, action: #selector(self.profileIconTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == self.friendList.count - 10 && self.friendList.count < self.viewModel.friendListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.fetchFriendList()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        if self.destinationController == .groupAVCallingVC { // restrict selected member to 5 when calling.
//
//            if self.memberListFiltered[indexPath.row].IsInCall ?? false {
//
//                self.tableView.deselectRow(at: indexPath, animated: false)
//
//                return
//            }
//
//            if self.selectionCount == 5 {
//
//                self.tableView.deselectRow(at: indexPath, animated: false)
//
//                guard let callType = self.additionalParams[.callType] as? CallType else {
//                    dismissOnErrorAlert("Call type missing")
//                    return
//                }
//                self.showToast(message: "Only 5 members are allowed for group \(callType == .videoGroup ? "video" : "audio") calling", toastType: .red)
//                return
//            }
//
//        }
        
        self.friendList[indexPath.row].isSelected = true
        
        self.insertObjectInFriendListSelected(object: self.friendList[indexPath.row])
    }
    
    // MARK: - Insert select object in correct(sorted) position.
    func insertObjectInFriendListSelected(object: FriendDM) {
        
        guard let id = object.id else { return }
        
        var indexToInsert: Int?
        
        for (i, selectedFriend) in self.friendListSelected.enumerated() {
            
            if let selectedFriendId = selectedFriend.id {
                
                if id > selectedFriendId { continue }
                
                if id < selectedFriendId {
                    indexToInsert = i
                    break
                }
            }
        }
        
        if let indexToInsert {
            self.friendListSelected.insert(object, at: indexToInsert)
        } else {
            self.friendListSelected.insert(object, at: self.friendListSelected.count)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.friendList[indexPath.row].isSelected = false
        
        if let index = getIndexOfObjectInList(list: self.friendListSelected, object: self.friendList[indexPath.row]) {
            
            if let index = getIndexOfObjectInList(list: self.friendListSelectedFiltered, object: self.friendList[indexPath.row]) {
                
                self.friendListSelectedFiltered.remove(at: index)
            }
            
            self.friendListSelected.remove(at: index)
        }
    }
    
    // MARK: - Member Profile Icon Tapped
    @objc func profileIconTapped(_ sender: UIButton) {
        
        self.searchTF.resignFirstResponder()
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            
            vc.profileIdentifier = self.friendList[sender.tag].identifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension FriendListVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.isSearching(true)
        
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.fetchFriendList()
        return true
    }
    
    func isSearching(_ flag: Bool) {
        
        if flag {
            self.searchBtn.isHidden = true
            self.actIndView.startAnimating()
            self.searchTF.isEnabled = false
        } else {
            self.searchBtn.isHidden = false
            self.actIndView.stopAnimating()
            self.searchTF.isEnabled = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            textField.text!.removeLast()
        }
        
        if textField.text!.isEmpty && string.isEmpty {
            
            self.isSearching(true)
            
            self.searchTF.resignFirstResponder()
            self.pageNumber = 1
            self.fetchFriendList()
        }
        
        if string.isEmpty {
            return false
        }
        
        return true
    }
}

extension FriendListVC: NetworkResponseProtocols {
    
    // MARK: - Friend List Response
    func didGetFriendsList() {
        
        DispatchQueue.main.async {
            self.tableView.flashScrollIndicators()
        }
        
        self.hideLoader()
        
        self.isSearching(false)
        
        if let unwrappedList = self.viewModel.friendListResponse?.data {
            
            self.pageNumber == 1 ? self.friendList.removeAll() : ()
            
            let syncedList = self.syncSelectionInFetchedList(fetchedList: unwrappedList)
            
            self.friendList.append(contentsOf: syncedList)
            
            self.friendList.isEmpty ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            
            self.tableView.reloadData()
            
        } else {
            self.dismissOnErrorAlert("\(self.viewModel.friendListResponse?.message ?? "Something went wrong")")
        }
    }
    
    // MARK: Sync selection in current fetched list and return that list.
    func syncSelectionInFetchedList(fetchedList: [FriendDM]) -> [FriendDM] {
        
        var fetchedList = fetchedList
        
//        fetchedList.sort { a, b in // remove this if array is already sorted
//            a.id! < b.id!
//        }

        /*
         If fetched list is greater than 'friend list selected filtered' then:
         loop on 'friend list selected filtered' and search in fetched list, and vice versa.
         */

        if fetchedList.count > self.friendListSelectedFiltered.count {
            
            var indicesToDelete: [Int] = [] // to delete object in friendListSelectedFiltered if they are already found, this will reduce number of iterations below when api is hit with next page number.
            
            for (i, selectedFriend) in self.friendListSelectedFiltered.enumerated() {
                if let index = self.getIndexOfObjectInList(list: fetchedList, object: selectedFriend) {
                    fetchedList[index].isSelected = true
                    indicesToDelete.append(i)
                }
            }
            
            for i in stride(from: indicesToDelete.count - 1, to: 0, by: -1) {
                self.friendListSelectedFiltered.remove(at: indicesToDelete[i])
            }

        } else {
            for (i, friend) in fetchedList.enumerated() {
                if let index = self.getIndexOfObjectInList(list: self.friendListSelectedFiltered, object: friend) {
                    fetchedList[i].isSelected = true
                    self.friendListSelectedFiltered.remove(at: index)
                    
                    if self.friendListSelectedFiltered.isEmpty {
                        break
                    }
                }
            }
        }
        
        return fetchedList
    }
    
    func getIndexOfObjectInList(list: [FriendDM], object: FriendDM) -> Int? {
        
        if list.isEmpty {
            return nil
        }
        
        guard let id = object.id else { return nil }
        
        var lowerIndex = 0
        var upperIndex = list.count - 1
        
        while (true) { // using binary search algorithm for faster search.
            
            let currentIndex = (lowerIndex + upperIndex)/2
            
            if(list[currentIndex].id == id) {
                return currentIndex
                
            } else if (lowerIndex > upperIndex) {
                return nil
                
            } else {
                
                if ((list[currentIndex].id ?? -1) > id) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    
    
}



//
//extension FriendsListVC: AppProtocol {
//    
//    // MARK: - Remove Friend From List in FriendsListVC After a Friend is removed in ViewProfileVC
//    func removeFriendFromList() {
//        
//        self.delegate?.refreshCircleDetail()
//        
//        if self.isSingleSelection {
//            if self.selectedFriend.value?.id == self.friendsList[selectedIndexPath.row].id {
//                self.selectedFriend.value = nil
//            }
//        }
//        else {
//            self.selectedFriends.array = self.selectedFriends.array.filter { $0.id != self.friendsList[selectedIndexPath.row].id }
//        }
//        self.friendsList.remove(at: selectedIndexPath.row)
//        self.friendsList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
//        self.tableView.reloadData()
//    }
//}

