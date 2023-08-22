//
//  ConnectWithFriendsVC.swift
//  Swarm Circle
//
//  Created by Macbook on 07/07/2022.
//

import UIKit
import Kingfisher

class ConnectWithFriendsVC: BaseViewController {
    
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedIndexPath = IndexPath()
    
    var pageNumber: Int = 1
    var userList: [UsersListDM] = []
    
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
        self.tableView.register(UINib(nibName: "InviteFriendsCell", bundle: nil), forCellReuseIdentifier: "InviteFriendsCell")
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetUsersList()
    }
    
    // MARK: - Fetch User List
    func postGetUsersList() {
        self.viewModel.getUsersList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "")
    }
    
    // MARK: - Send/Cancel Friend Request
    func sendFriendRequest(userId: Int, status: Bool, indexPath: IndexPath) {
        self.viewModel.sentFriendRequest(params: ["userId": userId, "status": status], indexPath: indexPath)
    }
    
    // MARK: - Search/Filter User List (using API)
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
            self.postGetUsersList()
        }
    }
}

// MARK: - TableView Configuration
extension ConnectWithFriendsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteFriendsCell") as? InviteFriendsCell else {
            return UITableViewCell()
        }
        
        cell.inviteBTN.isSelected = (self.userList[indexPath.row].isFriendRequestSent ?? false)
        cell.configureCell(userInfo: self.userList[indexPath.row])
        cell.inviteBTN.tag = indexPath.row
        cell.inviteBTN.addTarget(self, action: #selector(self.inviteBtnTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchTF.resignFirstResponder()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            
            vc.profileIdentifier = userList[indexPath.row].identifier
            vc.sourceController = .ConnectWithFriendsVC
            self.selectedIndexPath = indexPath
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.userList.count - 10 && self.userList.count < self.viewModel.userListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.postGetUsersList()
        }
    }
    
    // MARK: - Invite Button Tapped Action
    @objc func inviteBtnTapped(_ sender: ToggleButton) {
        
        guard
            let userId = userList[sender.tag].id,
            let isFriendRequestSent = userList[sender.tag].isFriendRequestSent
        else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }
        
        if sender.isSelected {
            self.sendFriendRequest(userId: userId, status: true, indexPath: IndexPath(row: sender.tag, section: 0))
        } else {
            self.sendFriendRequest(userId: userId, status: false, indexPath: IndexPath(row: sender.tag, section: 0))
        }
        self.userList[sender.tag].isFriendRequestSent = !isFriendRequestSent
        self.tableView.reloadData()
    }
}

extension ConnectWithFriendsVC: NetworkResponseProtocols {
    
    // MARK: - User List Response
    func didGetUsersList() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.userListResponse?.data {
            
            self.pageNumber == 1 ? self.userList.removeAll() : ()
            
            self.userList.append(contentsOf: unwrappedList)
            
            self.tableView.reloadData()
            
            self.userList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: self.viewModel.userListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.userList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
    
    // MARK: - Send/Cancel Friend Request Response
    func didSentFriendRequest(indexPath: IndexPath) {
        if viewModel.friendRequestSentResponse?.data ?? false {
            self.showToast(message: self.viewModel.friendRequestSentResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        } else {
            self.showToast(message: self.viewModel.friendRequestSentResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.userList[indexPath.row].isFriendRequestSent = !self.userList[indexPath.row].isFriendRequestSent!
            self.tableView.reloadData()
        }
    }
}

extension ConnectWithFriendsVC: UITextFieldDelegate {
    
    // MARK: - Search Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetUsersList()
        return true
    }
}

extension ConnectWithFriendsVC: AppProtocol {
    
    // MARK: - Update friend request status in ConnectWithFriendsVC, after a friend is invited/cancelled from ViewProfileVC.
    func updateFriendRequestStatus() {
        self.userList[selectedIndexPath.row].isFriendRequestSent = !self.userList[selectedIndexPath.row].isFriendRequestSent!
        self.tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
    }
    
    // MARK: - Remove User from list in ConnectWithFriendsVC after accepting Friend Request in ViewProfileVC
    func removeUserFromList() {
        self.userList.remove(at: selectedIndexPath.row)
        self.tableView.reloadData()
        self.delegate?.refreshFriendList()
    }
}

