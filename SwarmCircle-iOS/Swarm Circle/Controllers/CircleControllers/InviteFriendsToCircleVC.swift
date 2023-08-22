//
//  InviteFriendsToCircleVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 14/09/2022.
//

import UIKit

class InviteFriendsToCircleVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = ViewModel()
    
    var friendList: [GetFriendListToInviteToCircleDM] = []
    var friendListFiltered: [GetFriendListToInviteToCircleDM] = []
    
    var circleId: Int?
    
    var delegate: AppProtocol?
    
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI(){
        
        tableView.register(UINib(nibName: "InviteFriendsCell", bundle: nil), forCellReuseIdentifier: "InviteFriendsCell")
//        tableView.refreshControl = refreshControl
//        tableView.prefetchDataSource = self
    }
    
//    @objc override func refreshActionPerformed() {
//        refreshControl.endRefreshing()
////        self.showLoader() // Weird behaviour when commenting this line.
////        viewModel.getUsersList()
//    }
    
    // MARK: - Load data from API
    func initVariable() {
        
        self.viewModel.delegateNetworkResponse = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showLoader()
            self.postGetFriendsToInviteToCircleList()
        }
    }

    @IBAction func crossBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func postGetFriendsToInviteToCircleList() {

        guard let circleId else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }

        self.viewModel.getFriendsToInviteToCircleList(circleId: circleId)
    }
    
    func sendFriendRequest(userId: Int, status: Bool, circleId: Int, indexPath: IndexPath, isInvitedInitialState: Bool) {
        self.viewModel.inviteFriendToCircle(status: status, toUserId: userId, circleId: circleId, indexPath: indexPath, isInvitedInitialState: isInvitedInitialState)
    }
    @IBAction func searchBtnTapped(_ sender: UIButton) {
        self.searchTextField.becomeFirstResponder()
    }
    
    // MARK: - Touch anywhere to dismiss
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchTextField.resignFirstResponder()
    }
}
extension InviteFriendsToCircleVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "InviteFriendsCell") as? InviteFriendsCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.inviteBTN.isSelected = (self.friendList[indexPath.row].isInvited ?? false)
        cell.configureCell(userInfo: self.friendList[indexPath.row])
        cell.inviteBTN.tag = indexPath.row
        cell.inviteBTN.addTarget(self, action: #selector(self.inviteBtnTapped(_:)), for: .touchUpInside)

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchTextField.resignFirstResponder()
          
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            
            vc.profileIdentifier = self.friendList[indexPath.row].identifier
            vc.sourceController = .InviteFriendsToCircleVC
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    // MARK: - Invite Button Tapped Action
    @objc func inviteBtnTapped(_ sender: ToggleButton) {
        
        guard
            let userId = self.friendList[sender.tag].id,
            let circleId = self.circleId
        else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }
        
        if sender.isSelected {
            
            sendFriendRequest(userId: userId, status: false, circleId: circleId, indexPath: IndexPath(row: sender.tag, section: 0), isInvitedInitialState: true)
        } else {
            sendFriendRequest(userId: userId, status: true, circleId: circleId, indexPath: IndexPath(row: sender.tag, section: 0), isInvitedInitialState: false)
        }
        sender.isSelected = !sender.isSelected
    }
}

//extension ConnectWithFriendsVC: UITableViewDataSourcePrefetching {
//    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
//        print(indexPaths)
//
//    }
//}

extension InviteFriendsToCircleVC: NetworkResponseProtocols {
    
    func didGetFriendsToInviteToCircleList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.getFriendsToInviteToCircleListResponse?.data {
            
            self.friendList.removeAll()
            self.friendListFiltered.removeAll()
            
            self.friendList.append(contentsOf: unwrappedList)
            self.friendListFiltered.append(contentsOf: unwrappedList)
            self.tableView.reloadData()
            self.friendList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: viewModel.userListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.friendList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
    
    func didInviteFriendToCircle(indexPath: IndexPath, isInvitedInitialState: Bool) {
        
        if viewModel.inviteFriendToCircleResponse?.data ?? false {
            
            self.showToast(message: viewModel.inviteFriendToCircleResponse?.message ?? "Some error occured", delay: 2, toastType: .green)

        } else {
            self.friendList[indexPath.row].isInvited = isInvitedInitialState
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            self.showToast(message: viewModel.inviteFriendToCircleResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }

    
//    func didCancelFriendRequest() {
////        self.hideLoader()
//        btnReference?.isEnabled = true
//        if viewModel.friendRequestCancelResponse?.data ?? false {
//
//            if let btnReference = btnReference {
//                self.usersList[btnReference.tag].isFriendRequestSent = false
//
//                DispatchQueue.main.async {
//                    self.tableView.reloadRows(at: [IndexPath(row: btnReference.tag, section: 0)], with: .none)
////                    self.tableView.reloadData()
//                }
//
//
//                self.btnReference = nil
//            }
//        }
//    }
}

extension InviteFriendsToCircleVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        return true
    }
    
   // MARK: - TextField Delegate Fires on Less than and greater than 3 text Values

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (self.searchTextField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if text.count > 0 {

          self.friendList = textField.text!.isEmpty ? self.friendListFiltered : self.friendListFiltered.filter { friend in

              return friend.name?.range(of: textField.text!, options: .caseInsensitive) != nil
          }
        } else {
          self.friendList = self.friendListFiltered
        }
        self.tableView.reloadData()
        return true
      }
}

extension InviteFriendsToCircleVC: AppProtocol {
    
    // MARK: - Refresh Invite Friends To Circle List after a Friend is removed in ViewProfileVC
    func refreshInviteFriendToCircleList() {
        self.postGetFriendsToInviteToCircleList()
        self.delegate?.refreshCircleDetail()
    }
}

