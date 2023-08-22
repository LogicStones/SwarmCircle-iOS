//
//  BlockedFriendsVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 18/08/2022.
//

import UIKit

class BlockedFriendsVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    
    var pageNumber: Int = 1
    var blockedFriendList: [BlockedFriendDM] = []
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        self.tableView.register(UINib(nibName: "BlockedFriendsCell", bundle: nil), forCellReuseIdentifier: "BlockedFriendsCell")
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetBlockedFriendList()
    }
    
    // MARK: - Fetch Blocked Friend List
    func postGetBlockedFriendList() {
        self.viewModel.getBlockFriendsList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "")
    }

    // MARK: - Unblock Friend
    func unblockFriend(userId: Int, object: BlockedFriendDM) {
        self.viewModel.unblockFriend(params: ["userId": userId], object: object as AnyObject)
    }

    // MARK: - Search/Filter Blocked User List (using API)
    @IBAction func searchNCloseBtnPressed(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.searchTF.becomeFirstResponder()
            self.searchTF.isHidden = false
        } else {
            self.searchTF.resignFirstResponder()
            self.searchTF.isHidden = true
            
            self.searchTF.text = ""
            self.pageNumber = 1
            self.postGetBlockedFriendList()
        }
        
    }
}

// MARK: - TableView Configuration
extension BlockedFriendsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.blockedFriendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BlockedFriendsCell") as? BlockedFriendsCell else {
            return UITableViewCell()
        }
        cell.unblockBtn.tag = indexPath.row
        cell.configureCell(userInfo: self.blockedFriendList[indexPath.row])
        cell.unblockBtn.addTarget(self, action: #selector(self.unblockBtnTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchTF.resignFirstResponder()
        tableView.deselectRow(at: indexPath, animated: true)
        
//        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
//            
//            vc.profileIdentifier = blockedFriendList[indexPath.row].identifier
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.blockedFriendList.count - 10 && self.blockedFriendList.count < self.viewModel.getBlockFriendListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.postGetBlockedFriendList()
        }
    }
    
    // MARK: - Unblock Button Tapped
    @objc func unblockBtnTapped(_ sender: ToggleButton) {
        
//        Alert.sharedInstance.alertWindow(title: "", message: "Are you sure you want to unblock \(self.blockedFriendList[sender.tag].name?.capitalized ?? "")?") { result in
//            if result {
                guard let userId = self.blockedFriendList[sender.tag].id else {
                    
                    // This alert can be removed, because id is a primary key and it will always exist, infact we can entirely remove guard statement.
                    Alert.sharedInstance.alertOkWindow(title: "", message: "Some error occured, please try again later") { _ in
                        self.navigationController?.popViewController(animated: true)
                    }
                    return
                }
                self.unblockFriend(userId: userId, object: self.blockedFriendList[sender.tag])
                self.blockedFriendList.remove(at: sender.tag)
                self.blockedFriendList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                self.tableView.reloadData()
//            }
//        }
    }
}

extension BlockedFriendsVC: NetworkResponseProtocols {
    
    // MARK: - Block Friend(User) List Response
    func didGetBlockFriendList() {
        
        self.hideLoader()
        
        if let unwrappedBlockedFriendsList = viewModel.getBlockFriendListResponse?.data {
            
            self.pageNumber == 1 ? self.blockedFriendList.removeAll() : ()
            
            self.blockedFriendList.append(contentsOf: unwrappedBlockedFriendsList)
            self.tableView.reloadData()
            self.blockedFriendList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: viewModel.getBlockFriendListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Unblock Friend(User) Response
    func didUnblockFriend(object: AnyObject) {
        if viewModel.unblockFriendResponse?.data ?? false {
            self.showToast(message: viewModel.unblockFriendResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: viewModel.unblockFriendResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.blockedFriendList.append(object as! BlockedFriendDM)
            self.tableView.restore()
            self.tableView.reloadData()
        }
    }
}

extension BlockedFriendsVC: UITextFieldDelegate {
    
    // MARK: - Search Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetBlockedFriendList()
        return true
    }
}
