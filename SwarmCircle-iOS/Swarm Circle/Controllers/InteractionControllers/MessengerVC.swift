//
//  MessengerVC.swift
//  Swarm Circle
//
//  Created by Macbook on 22/08/2022.
//

import UIKit

class MessengerVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTF: UITextField!
    
    var pageNumber: Int = 1
    var chatList = [MessagesListDM]()
    let viewModel = ViewModel()
    
    let chatHubConnection = SignalRService.signalRService.connection
    var myUserId = "\(PreferencesManager.getUserModel()?.id ?? 0)"
    
    var isGroupChatOpen = false
    var openedGroupChatIdentifier = ""
//    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
        self.signalRGroupChatDeletedByAdmin()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To My Chats"
        
        self.isGroupChatOpen = false //When ever user come back from Chat screen it should be false
        self.openedGroupChatIdentifier = ""
//        self.initVariable()
        
        self.pageNumber = 1
        self.showLoader()
        self.getUserChatList()
        if PreferencesManager.isCallActive() {
            self.viewModel.delegateNetworkResponse = self
            self.viewModel.callMemberStop()
        }
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        
//
//    }
    
    
    
    // MARK: - Configuring UI when loading
    func initUI(){
        self.tableView.refreshControl = refreshControl
    }

    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = nil
        self.viewModel.delegateNetworkResponse = self
//        self.showLoader()
//        self.getUserChatList()
        
    }
    
    
    // MARK: - Refresh Friend List on Pull
    @objc override func pullToRefreshActionPerformed() {
        refreshControl.endRefreshing()
        self.refreshChatList()
    }
    
    // MARK: - pull to refresh list
    func refreshChatList() {
        self.isGroupChatOpen = false //When ever user come back from Chat screen it should be false
        self.openedGroupChatIdentifier = ""
        self.showLoader()
        self.pageNumber = 1
        self.getUserChatList()
    }
    
    // MARK: - Fetch Pending Friend Request List
    func getUserChatList() {
        self.viewModel.getChatsList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "")
    }
    
    // MARK: - Delete Partial Delete
    func deleteChatMessages(identifier: String, indexPath: IndexPath) {
        
        Alert.sharedInstance.alertWindow(title: "Delete Chat", message: "Are your sure you want to delete chat with \(self.chatList[indexPath.row].firstName ?? "") \(self.chatList[indexPath.row].lastName ?? "")?\nNote: This will only delete the messages for you.") { result in
            if result{
                self.showLoader()
                self.viewModel.deleteMessages(identifier: identifier, indexPath: indexPath)
            }
        }
    }
    
    // MARK: - Create new chat
    @IBAction func createNewChat(_ sender: Any) {
        print("Button Pressed")
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "ChatFriendsListVC") as? ChatFriendsListVC {
            vc.modalTransitionStyle = .crossDissolve
            vc.modalPresentationStyle  = .overFullScreen
            vc.isSingleSelection = true
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    
    // MARK: - Signal R message send by self
    private func signalRGroupChatDeletedByAdmin(){
        
        self.chatHubConnection?.on(method: "ClientPermenantDeleteGroupChat", callback: {(circleIdentifier: String) in
            print(circleIdentifier)
            if self.isGroupChatOpen && circleIdentifier == self.openedGroupChatIdentifier{
//                self.delegate?.backToMessenger()
                NotificationCenter.default.post(name: Notification.Name.popController, object: nil)
                self.chatList = self.chatList.filter({$0.identifier != circleIdentifier})
                self.tableView.reloadData()
            } else {
                print(circleIdentifier)
                self.chatList = self.chatList.filter({$0.identifier != circleIdentifier})
                self.tableView.reloadData()
            }
            
        })
    }
    
    // MARK: - Signal R message send by self
    private func signalRDeleteGroupChat(identifier: String, indexPath: IndexPath){
        
        Alert.sharedInstance.alertWindow(title: "Delete Group Chat", message: "Are you sure you want to delete this group?") { result in
            if result{
                self.chatHubConnection?.invoke(method: "PermenantDeleteGroupChat", self.myUserId, identifier, invocationDidComplete: { error in
                
                    if let e = error {
        //                self.sendBtn.hideLoading()
                        self.showToast(message: "Error: \(e)", toastType: .red)
                    } else {
                        self.chatList.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.tableView.reloadData()
        //                self.tableView.scrollToBottom()
                    }
                })
            }
        }
    }
    
}
extension MessengerVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.chatList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MessengerCell", for: indexPath) as? MessengerCell else{
            return UITableViewCell()
        }
        
        cell.configCell(chatResponse: self.chatList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        searchTF.resignFirstResponder()
        self.tableView.deselectRow(at: indexPath, animated: true)
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
            vc.identifier = self.chatList[indexPath.row].identifier ?? ""
            vc.userName = "\(self.chatList[indexPath.row].firstName ?? "") \(self.chatList[indexPath.row].lastName ?? "")"
            vc.isCircle = self.chatList[indexPath.row].isGroup ?? false
            vc.imgUrl = self.chatList[indexPath.row].displayImageURL ?? ""
            self.isGroupChatOpen = self.chatList[indexPath.row].isGroup ?? false
            self.openedGroupChatIdentifier = self.chatList[indexPath.row].isGroup ?? false == true ? self.chatList[indexPath.row].identifier ?? "" : ""
//            vc.isThisUserVerified = self.chatList[indexPath.row].isAccountVerified ?? false
            vc.isGroup = self.chatList[indexPath.row].isGroup ?? true
            
            vc.isBlocked = self.chatList[indexPath.row].isBlocked ?? false
            
            print(vc.identifier)
            print(vc.userName)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.chatList.count - 25 && self.chatList.count < self.viewModel.chatListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.getUserChatList()
        }
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // Right Swipe
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        // Archive action
//        let report = UIContextualAction(style: .normal,
//                                        title: "Report") { [weak self] (action, view, completionHandler) in
//            self?.handleReport()
//            completionHandler(true)
//        }
//        report.backgroundColor = .systemRed
//        //            report.image = UIImage(named: "blockFriendIcon")
//        return UISwipeActionsConfiguration(actions: [report])
//    }
    
    // left Swipe
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        
        // Trash action
        let trash = UIContextualAction(style: .destructive,
                                       title: "") { [weak self] (action, view, completionHandler) in
            //Group or Individual Chat check
            if self?.chatList[indexPath.row].isGroup ?? false {
                //Group Admin check
                if self?.chatList[indexPath.row].isCircleAdmin ?? false {
                    self?.signalRDeleteGroupChat(identifier: self?.chatList[indexPath.row].identifier ?? "", indexPath: indexPath)
                } else {
                    self?.showToast(message: "Only admin can delete group chat", toastType: .red)
                }
            } else {
                // Individual Chat Delete method
                self?.deleteChatMessages(identifier: (self?.chatList[indexPath.row].identifier)!, indexPath: indexPath)
                
            }
            
            completionHandler(true)
        }
        trash.backgroundColor = UIColor(hexString: "#FFCDCD")
        trash.image = UIImage(named: "binIcon")
        let configuration = UISwipeActionsConfiguration(actions: [trash])
        // If you do not want an action to run with a full swipe
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

extension MessengerVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.searchTF.resignFirstResponder()
        self.showLoader()
        self.pageNumber = 1
        self.getUserChatList()
        return true
    }
}
extension MessengerVC: NetworkResponseProtocols{
    
    func didReceiveChatList() {
        if let chatResponse = viewModel.chatListResponse?.data{
//            self.pageNumber == 1 ? self.chatList.removeAll() : ()
            if self.pageNumber == 1 {
                self.chatList.removeAll()
                self.chatList.append(contentsOf: chatResponse)
            } else {
                self.chatList.insert(contentsOf: chatResponse, at: 0)
            }
            
            self.hideLoader()
            self.tableView.reloadData()
            self.chatList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.hideLoader()
            self.showToast(message: viewModel.chatListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.chatList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
    
    func didDeleteMessages(indexPath: IndexPath) {
        
        self.hideLoader()
        
        if self.viewModel.deleteMessagesResponse?.isSuccess ?? false {
            
            self.chatList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
//            self.tableView.scrollToBottom()
            
            self.chatList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
        else {
            self.showToast(message: viewModel.deleteMessagesResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
}

extension MessengerVC: AppProtocol{
    
    func createNewChat(friendObject: FriendDM) {
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC{
            vc.identifier = friendObject.identifier ?? ""
            vc.userName = friendObject.name ?? ""
            vc.isCircle = false
            print(vc.identifier)
            print(vc.userName)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
