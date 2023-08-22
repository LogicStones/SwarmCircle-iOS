//
//  FriendsListVC.swift
//  Swarm Circle
//
//  Created by Macbook on 05/07/2022.
//

import UIKit

class FriendsListVC: BaseViewController {

    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var isSingleSelection = false
    var isEmailIntent = false
    var isTransferFromCircle = false
    var isGroupCallingVideo = false
    var isGroupCallingAudio = false
    
    var pageNumber: Int = 1
    var friendsList: [FriendDM] = []

    let viewModel = ViewModel()
    
    var selectedFriends = ArrayWrapper<FriendDM>(array: [])
    
    var selectedFriend = ValueWrapper<FriendDM?>(value: nil)
    
    var selectedIndexPath = IndexPath()
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isTransferFromCircle {
            self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Circle Detail"
        }
    }
    
    // MARK: - Configuring UI when loading
    func initUI(){
        tableView.register(UINib(nibName: "FriendsListCell", bundle: nil), forCellReuseIdentifier: "FriendsListCell")
        if self.isSingleSelection {
            self.titleLBL.text = "Select a Friend"
            self.tableView.allowsMultipleSelection = false
        }
        
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.showLoader()
            self.postGetFriendsList()
        }
    }
    
    func postGetFriendsList() {
        self.viewModel.getFriendsList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "")
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismissController()
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        
        // if user is transferring to a friend, (opened from CircleDetailVC)
        if self.isTransferFromCircle {
            
            if selectedFriend.value == nil {
                self.showToast(message: "Please select a member to transfer", toastType: .red)
                return
            }
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "TransferVC") as? TransferVC {
                vc.selectedFriend = self.selectedFriend
                vc.isTransferFromCircle = self.isTransferFromCircle
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else if self.isEmailIntent {
            if selectedFriends.array.count == 0 {
                self.showToast(message: "Please select a member to send email", toastType: .red)
                return
            }
            
            self.openEmail(selectedFriends.array.map({ selectedFriend in
                return selectedFriend.email ?? ""
            }))
        }
        else if self.isGroupCallingVideo || self.isGroupCallingAudio {
            if selectedFriends.array.count == 0 {
                self.showToast(message: "Please select at least 1 member to video call", toastType: .red)
                return
            }
            
            let finalArray = selectedFriends.array.map { $0.identifier! }

            self.dismiss(animated: true) {
                self.delegate?.goToGroupCallingVC(members: Utils.convertArrayToCommaSeperatedString(finalArray), isVideoCalling: self.isGroupCallingVideo)
            }
        }
        else {
            self.dismissController()
        }
    }
    
    fileprivate func dismissController() {
        if isSingleSelection {
            self.dismiss(animated: true) {
                self.delegate?.setReceiverWalletId()
            }
        } else {
            self.dismiss(animated: true)
        }
    }
}

extension FriendsListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.friendsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell") as? FriendsListCell else {
            return UITableViewCell()
        }
        DispatchQueue.main.async {
            if !self.isSingleSelection {
                cell.configureCell(userInfo: self.friendsList[indexPath.row], isSelected: self.selectedFriends.array.contains(where: {$0.id == self.friendsList[indexPath.row].id}))
            } else {
                cell.configureCell(userInfo: self.friendsList[indexPath.row], isSelected: self.selectedFriend.value == self.friendsList[indexPath.row])
            }
        }
        cell.profilePicBtn.tag = indexPath.row
        cell.profilePicBtn.addTarget(self, action: #selector(self.profileIconTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func profileIconTapped(_ sender: UIButton) {
        
        self.searchTF.resignFirstResponder()
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            
            vc.profileIdentifier = self.friendsList[sender.tag].identifier
            vc.sourceController = .FriendsListVC
            vc.delegate = self
            self.selectedIndexPath = IndexPath(row: sender.tag, section: 0)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.isSingleSelection {
            
            if self.selectedFriend.value == self.friendsList[indexPath.row] {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            } else {
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
            
        } else {
            
            if self.selectedFriends.array.contains(where: {$0.id == self.friendsList[indexPath.row].id}){
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            } else {
                self.tableView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let id = friendsList[indexPath.row].id else {
            return
        }
        
        if self.isSingleSelection {
            self.selectedFriend.value = friendsList[indexPath.row]
            
        } else {
            
            if !self.selectedFriends.array.contains(where: {$0.id == id}) {
                
                if self.isGroupCallingVideo || self.isGroupCallingAudio {
                    if self.selectedFriends.array.count >= 5 {
                        self.showToast(message: "Only 5 members are allowed for group calling", toastType: .red)
                        self.tableView.deselectRow(at: indexPath, animated: true)
                        return
                    }
                }
                
                self.selectedFriends.array.append(friendsList[indexPath.row])
            }
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let id = self.friendsList[indexPath.row].id else {
            return
        }
        
        if self.isSingleSelection {
            self.selectedFriend.value = nil
        } else {
            
            if self.selectedFriends.array.contains(where: {$0.id == id}) {
                self.selectedFriends.array.removeAll(where: {$0.id == id})
            }
        }
    }
}

extension FriendsListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetFriendsList()
        return true
    }
}


extension FriendsListVC: NetworkResponseProtocols {
    
    func didGetFriendsList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.friendListResponse?.data {
            
            self.pageNumber == 1 ? self.friendsList.removeAll() : ()
            
            self.friendsList.append(contentsOf: unwrappedList)
            
            self.tableView.reloadData()
            
            self.friendsList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: viewModel.friendListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.friendsList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
}

import MessageUI

// MARK: - Email Intent
extension FriendsListVC: MFMailComposeViewControllerDelegate { //UINavigationControllerDelegate
    
    func openEmail(_ emailAddresses: [String]) {
        
        Utils.openEmailIntent(self, emailAddresses: emailAddresses)
//        // If user has not setup any email account in the iOS Mail app
//
//        if !MFMailComposeViewController.canSendMail() {
//            print("Mail services are not available")
//
//            UIApplication.shared.open(URL(string: "mailto:\(emailAddresses.joined(separator: "%2C"))")!)
//            return
//        }
//
//        // Use the iOS Mail app
//        let composeVC = MFMailComposeViewController()
//        composeVC.mailComposeDelegate = self
//        composeVC.setToRecipients(emailAddresses)
//        composeVC.setSubject("")
//        composeVC.setMessageBody("", isHTML: false)
//
//        composeVC.mailComposeDelegate = self
////        composeVC.delegate = self
//
//        self.present(composeVC, animated: true)
//
////        weak var pvc = self.presentingViewController
////
////        self.dismiss(animated: true, completion: {
////            pvc?.present(composeVC, animated: true) // Present the view controller modally.
////        })
    }

    // MARK: MailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        dismiss(animated: true)
    }
}

extension FriendsListVC: AppProtocol {
    
    // MARK: - Remove Friend From List in FriendsListVC After a Friend is removed in ViewProfileVC
    func removeFriendFromList() {
        
        self.delegate?.refreshCircleDetail()
        
        if self.isSingleSelection {
            if self.selectedFriend.value?.id == self.friendsList[selectedIndexPath.row].id {
                self.selectedFriend.value = nil
            }
        }
        else {
            self.selectedFriends.array = self.selectedFriends.array.filter { $0.id != self.friendsList[selectedIndexPath.row].id }
        }
        self.friendsList.remove(at: selectedIndexPath.row)
        self.friendsList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        self.tableView.reloadData()
    }
}





