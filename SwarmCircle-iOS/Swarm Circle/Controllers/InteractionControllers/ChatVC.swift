//
//  ChatVC.swift
//  Swarm Circle
//
//  Created by Macbook on 22/08/2022.
//

import UIKit
import SwiftSignalRClient
import CallKit

class ChatVC: BaseViewController {
    
    @IBOutlet weak var chatView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatTextView: UITextView!
    @IBOutlet weak var sendBtn: LoadingButton!
    @IBOutlet weak var nameLBL: UILabel!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    
    var userName: String = ""
    var identifier: String = ""
    var isCircle = false
    var myUserId = "\(PreferencesManager.getUserModel()?.id ?? 0)"
    var pageNumber = 1
    var messagesCount: Int = 0
    let viewModel = ViewModel()
    var imgUrl: String = ""
    var isGroup = false
//    var isThisUserVerified: Bool = false
    var isBlocked: Bool = false
    
    var msgs: [MessagesRecordDM] = []
    
    var currentMessage: ChatList?
    
    //    var chatHubConnection: HubConnection?
    //
    //    var chatHubConnectionDelegate: HubConnectionDelegate?
    
    let chatHubConnection = SignalRService.signalRService.connection
    
    var isLoading: Bool = true
    //    var chatHubConnectionDelegate = SignalRService.signalRService.chatHubConnectionDelegate
    
    var actions: [(String, UIAlertAction.Style)] = [
        ("Take My Message Back", UIAlertAction.Style.destructive),
        ("Cancel", UIAlertAction.Style.cancel)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.createSignalRConnections()
        self.initUI()
        self.initVariable()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        NotificationCenter.default.addObserver(self, selector: #selector(handleCallsChangedNotification(notification:)), name: SpeakerboxCallManager.CallsChangedNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
//    @objc func handleCallsChangedNotification(notification: NSNotification) {
//
//        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
//
//            print("appdelegate is missing")
//            return
//        }
//
//        if (appdelegate.callManager.calls.count > 0)
//        {
//            let call = appdelegate.callManager.calls[0]
//            if call.isOnHold {
////                callButton.setTitle(unholdCallText, for: .normal)
//            } else if call.session != nil {
////                callButton.setTitle(endCallText, for: .normal)
////                callButton.setTitleColor(.red, for: .normal)
//            }
//
//            if let hasVideo = notification.userInfo?["hasVideo"] as? Bool{
//                if hasVideo{
//                    if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "GroupCallingVC") as? GroupCallingVC {
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                } else {
//
//                }
//            }
//
//            if let action = notification.userInfo?["action"] as? String, action == SpeakerboxCallManager.Call.end.rawValue {
////                callButton.setTitle(makeACallText, for: .normal)
////                callButton.setTitleColor(.white, for: .normal)
////                callButton.isEnabled = true
////                simulateCallButton.setTitle(simulateIncomingCallText, for: .normal)
////                simulateCallButton.setTitleColor(.white, for: .normal)
////                simulateCallButton.isEnabled = true
////                simulateCallButton2.setTitle(simulateIncomingCallThreeSecondsText, for: .normal)
////                simulateCallButton2.setTitleColor(.white, for: .normal)
////                simulateCallButton2.isEnabled = true
//            }
//        }
//    }
    
    // MARK: - Initialization UI
    func initUI() {
        
        self.audioCallButton.isHidden = self.isGroup
        self.videoCallButton.isHidden = self.isGroup
        
        if self.isBlocked {
            self.audioCallButton.isHidden = true
            self.videoCallButton.isHidden = true
            self.chatTextView.isUserInteractionEnabled = false
            self.chatTextView.text = "You can't reply to this conversation anymore"
        } else {
            self.audioCallButton.isHidden = false
            self.videoCallButton.isHidden = false
            self.chatTextView.isUserInteractionEnabled = true
            self.chatTextView.text = "Write a reply"
        }

        self.nameLBL.text = self.userName.capitalized
        
//        self.isVerifiedIcon.isHidden = !self.isThisUserVerified
        //        self.tableView.translatesAutoresizingMaskIntoConstraints = true
        //        TableView Nib registration
        self.tableView.register(UINib(nibName: "ChatDateHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ChatDateHeaderView")
        tableView.register(UINib(nibName: "SendTextCell", bundle: nil), forCellReuseIdentifier: "SendTextCell")
        tableView.register(UINib(nibName: "ReceivedTextCell", bundle: nil), forCellReuseIdentifier: "ReceivedTextCell")
        
        addDismissKeyboardOnTapGesture(scrollView: self.tableView)
        
        
        self.sendBtn.isEnabled = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(backToMessenger), name: Notification.Name.popController, object: nil)
    }
    
    // MARK: - Load data from API
    private func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.getChat()
    }
    
    // MARK: - Fetch Messages List
    private func getChat() {
        self.viewModel.getChat(pageNumber: self.pageNumber, identifier: self.identifier, isCircle: self.isCircle)
    }
    
    // MARK: - Signal R Configuration
    private func createSignalRConnections() {
        
        self.signalRChatSeen()
        self.signalRMessageReceive()
        self.signalRSeenSendMessage()
        self.signalRDeleteReceiveMessage()
    }
    
    // MARK: - Signal R Handle Message
    private func handleMessage(_ args1: String, from user: String, _ args3: ChatList, _ args4: String ) {
        // Do something with the message.
        self.currentMessage = args3
        //        self.msgs[self.msgs.count - 1].chatList?.append(self.currentMessage!)
        
        if self.msgs.count < 1 {
            let message = MessagesRecordDM()
            message.date = "Today"
            var chatMessage = ChatList()
            chatMessage = self.currentMessage!
            message.chatList = [chatMessage]
            self.msgs.append(message)
            self.tableView.reloadData()
            //                    self.tableView.scrollToBottom()
            self.sendBtn.hideLoading()
        } else {
            // If there is header and is current date then appending msg
            if Utils.getChatHeaderDate(dateString: self.msgs[self.msgs.count > 0 ? self.msgs.count - 1 : 0].date ?? "").isInToday || self.msgs[self.msgs.count > 0 ? self.msgs.count - 1 : 0].date == "Today" {
                self.msgs[self.msgs.count > 0 ? self.msgs.count - 1 : 0].chatList?.append(self.currentMessage!)
            } else {
                // If there is header and is not current date then appending msg in new header
                let message = MessagesRecordDM()
                message.date = "Today"
                var chatMessage = ChatList()
                chatMessage = self.currentMessage!
                message.chatList = [chatMessage]
                self.msgs.append(message)
            }
        }
        self.messagesCount += 1
        self.tableView.reloadData()
        self.tableView.scrollToBottom()
        self.signalRChatSeen()
    }
    
    // MARK: - Signal R Chat Seen by self
    private func signalRChatSeen() {
        self.chatHubConnection?.send(method: "ChatIsSeen", "\(PreferencesManager.getUserModel()?.identifier ?? "")", "\(self.identifier)", "\(self.isCircle)"){ error in
            print(error)
            if let e = error {
                self.showToast(message: "Error: \(e)", toastType: .red)
            }
        }
    }
    
    // MARK: - Signal R Message Receive
    private func signalRMessageReceive(){
        self.chatHubConnection?.on(method: "ReceiveMessage", callback: {(user: String, message: String, chat: ChatList, circle: String) in
            print(user)
            print(message)
            print(chat)
            print(circle)
            
            if self.identifier == chat.identifier {
                do {
                    var receiveMsg = chat
                    receiveMsg.isMine = false
                    self.handleMessage(user, from: message, receiveMsg, circle)
                    self.signalRChatSeen()
                    self.messagesCount += 1
                } catch {
                    print(error)
                    self.showToast(message: "Error: \(error)", toastType: .red)
                }
            }
        })
    }
    
    // MARK: - Signal R Chat Seen by Other
    private func signalRSeenSendMessage(){
        self.chatHubConnection?.on(method: "ReceiveChatSeen", callback: { (isSuccess: Bool) in
            
            self.msgs.indices.forEach { self.msgs[$0].chatList?.map({$0.isSeen = true})}
            self.tableView.reloadData()
            
            print(isSuccess)
        })
    }
    
    // MARK: - Signal R message send by self
    private func signalRSendMessage(message: String) {
        
        chatHubConnection?.invoke(method: "SendMessage", self.myUserId, self.identifier, message, "\(self.isCircle)", resultType: SocketChat.self, invocationDidComplete: { result, error in
            
            if let e = error {
                self.sendBtn.hideLoading()
                self.showToast(message: "Error: \(e)", toastType: .red)
            } else {
                // If there is no header then adding header of date then appending message
                if self.msgs.count < 1 {
                    let message = MessagesRecordDM()
                    message.date = "Today"
                    var chatMessage = ChatList()
                    chatMessage = (result?.data)!
                    message.chatList = [chatMessage]
                    self.msgs.append(message)
                    self.tableView.reloadData()
                    //                    self.tableView.scrollToBottom()
                    self.sendBtn.hideLoading()
                } else {
                    // If there is header and is current date then appending msg
                    if Utils.getChatHeaderDate(dateString: self.msgs[self.msgs.count > 0 ? self.msgs.count - 1 : 0].date ?? "").isInToday || self.msgs[self.msgs.count > 0 ? self.msgs.count - 1 : 0].date == "Today" {
                        self.msgs[self.msgs.count > 0 ? self.msgs.count - 1 : 0].chatList?.append((result?.data)!)
                    } else {
                        // If there is header and is not current date then appending msg in new header
                        let message = MessagesRecordDM()
                        message.date = "Today"
                        var chatMessage = ChatList()
                        chatMessage = (result?.data)!
                        message.chatList = [chatMessage]
                        self.msgs.append(message)
                    }
                    
                    
                    self.tableView.reloadData()
                    self.tableView.scrollToBottom()
                    self.sendBtn.hideLoading()
                }
                self.messagesCount += 1
                
            }
        })
    }
    
    // MARK: - Signal R Take My Message Back
    private func signalRDeleteSendMessage(chatId: Int, userIdentifier: String, isCircle: Bool, section: Int, index: Int) {
        chatHubConnection?.invoke(method: "UndoChatMessage", userIdentifier, chatId, "\(isCircle)", invocationDidComplete: { error in
            
            if let e = error {
                self.showToast(message: "Error: \(e)", toastType: .red)
            } else {
                self.deleteMessage(section: section, index: index)
            }
        })
    }
    
    // MARK: - Signal R Take Message Back
    private func signalRDeleteReceiveMessage() {
        
        self.chatHubConnection?.on(method: "ClientUndoChatMessage", callback: { (user: String, chatID: Int, isCircle: String) in
            
            for i in stride(from: 0, to: self.msgs.count, by: 1) {
                print(i)
                for j in stride(from: 0, to: self.msgs[i].chatList?.count ?? 0, by: 1) {
                    print(j)
                    if self.msgs[i].chatList?[j].id ?? 0 == chatID{
                        if self.msgs[i].chatList?.count ?? 0 > 1 {
                            self.msgs[i].chatList?.remove(at: j)
                            break
                        } else {
                            self.msgs.remove(at: i)
                            break
                        }
                    }
                    
                }
            }
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
        })
    }
    
    // MARK: - Get call details (session id etc)
    func getCallDetails(callType: Int) {
        self.showLoader()
        self.viewModel.startCallSession(callTo: self.identifier, callType: callType)
        
    }
    
    // MARK: - Audio call button tapped
    @IBAction func audioCallButtonTapped(_ sender: UIButton) {
        self.goToSingleCallingVC(callType: .audioSingle)
    }
        
    // MARK: - Video call button tapped
    @IBAction func videoCallButtonTapped(_ sender: UIButton) {
        self.goToSingleCallingVC(callType: .videoSingle)
    }
    
    // MARK: - Go to SingleAVCallingVC after user tapped audio/video calling button
    func goToSingleCallingVC(callType: CallType) {
        
        if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "SingleAVCallingVC") as? SingleAVCallingVC {
            let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
            navController.modalTransitionStyle = .crossDissolve
            navController.modalPresentationStyle  = .overFullScreen
            
            vc.callType = callType // used to start call session & ...
         
            vc.isCallInitiater = true
            
            vc.userInfo = [
                .userName: "\(self.userName)",
                .displayURL: "\(self.imgUrl)",
                .callToIdentifier: self.identifier
            ]
            
            self.present(navController, animated: true)
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        // configure audio session
        action.fulfill()
    }
    
    // MARK: - Send Button Pressed
    @IBAction func sendBtnPressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            
            self.chatTextView.text.removeNewLinesFromStartNEnd()
            self.chatTextView.text.removeWhiteSpacesFromStartNEnd()
            

            if self.chatTextView.text.isEmpty {
                self.sendBtn.isEnabled = false
                return
            }
            
            self.sendBtn.showLoading()
            self.sendBtn.isEnabled = false
            self.signalRSendMessage(message: Utils.encodeUTF(self.chatTextView.text!))
            print(self.chatTextView.text!)
            self.chatTextView.text = ""
            self.chatTextView.isScrollEnabled = false
            self.chatTextView.updateConstraints()
            self.chatView.updateConstraints()
            self.textViewDidChange(self.chatTextView)
        }
    }

    // MARK: - handling show / hide keyboard
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            
            // get the size of keyboard
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            // checking keyboard status weather it's showing or hidden
            if isKeyboardShowing {
                print("Keyboard Showing")
                self.lastBottomConstraint.constant = keyboardSize.height
   
            } else {
                print("Keyboard Hidden")
                self.lastBottomConstraint.constant = 0
            }
            
            view.layoutIfNeeded()
            self.tableView.scrollToBottom()
            
        }
    }


    
}
extension ChatVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self.msgs.count > 0{
            self.tableView.restore()
        }
        return self.msgs.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ChatDateHeaderView") as? ChatDateHeaderView else {
            return UIView()
        }
        header.configureHeader(info: self.msgs[section].date ?? "")
        header.backgroundView = UIView()
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.msgs[section].chatList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if self.msgs[indexPath.section].chatList?[indexPath.row].isMine ?? false {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "SendTextCell", for: indexPath) as? SendTextCell else{
                return UITableViewCell()
            }
            
            cell.optionsButton.tag = indexPath.row
            cell.optionsButton.accessibilityValue = "\(indexPath.section)"
            cell.optionsButton.addTarget(self, action: #selector(showOptions), for: .touchUpInside)
            cell.configureCell(info: self.msgs[indexPath.section].chatList?[indexPath.row], isGroupChat: self.isCircle)
            print("Total Msgs Count \(self.messagesCount)")
            return cell
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedTextCell", for: indexPath) as? ReceivedTextCell else{
                return UITableViewCell()
            }
            cell.configureCell(info: self.msgs[indexPath.section].chatList?[indexPath.row])
            return cell
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        if indexPath.row == self.msgs.count - 10 && self.msgs.count < self.viewModel.chatResponse?.recordCount ?? 0 {
//            self.pageNumber += 1
//            self.getChat()
//        }
        print("Current :\(indexPath.row)")
        print("Scrolling \(self.messagesCount)")
        if self.messagesCount < self.viewModel.chatResponse?.recordCount ?? 0 && self.isLoading == false && indexPath.row == 10{
            self.isLoading = true
            self.pageNumber += 1
            self.getChat()
        }else{
            print("Scrolling \(self.messagesCount)")
        }
        
    }
    
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if indexPath.row == self.msgs.count{
//            self.isLoading = false
//        }
        
    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if ((tableView.contentOffset.y + tableView.frame.size.height) >= tableView.contentSize.height){
//            print("Scrolling Bottom")
//        } else {
//            print("Scrolling Top")
//            if self.messagesCount < self.viewModel.chatResponse?.recordCount ?? 0 {
//                self.pageNumber += 1
//                self.getChat()
//            }else{
//                print("Scrolling \(self.messagesCount)")
//            }
//        }
//    }
    
    @objc func showOptions(sender: UIButton){
        let section = Int(sender.accessibilityValue!)!
        print(section)
        print(sender.tag)
        Alert.sharedInstance.showActionsheet(vc: self, title: "Manage Message", message: "", actions: actions) { index, _ in
            switch index {
            case 0:
                print(self.actions[index].0)
                print(self.msgs[section].chatList?[sender.tag])
                
                self.signalRDeleteSendMessage(chatId: self.msgs[section].chatList?[sender.tag].id ?? 0, userIdentifier: self.identifier, isCircle: self.isCircle, section: section, index: sender.tag)
            default :
                print(self.actions[index].0)
                print(self.msgs[section].chatList?[sender.tag])
            }
        }
    }
    
    
    // MARK: - Delete Message From List & Server
    func deleteMessage(section: Int, index: Int){
        if self.msgs[section].chatList?.count ?? 0 > 1{
            self.msgs[section].chatList?.remove(at: index)
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
            self.msgs.count == 0 ? self.tableView.setEmptyView("No Chat Found", "") : self.tableView.restore()
        } else {
            self.msgs.remove(at: section)
            self.tableView.reloadData()
            self.tableView.scrollToBottom()
            self.msgs.count == 0 ? self.tableView.setEmptyView("No Chat Found", "") : self.tableView.restore()
        }
    }
}

extension ChatVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        textView.text.removeNewLinesFromStartNEnd()
        textView.text.removeWhiteSpacesFromStartNEnd()
        
        if textView.text == "Write a reply" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        textView.text.removeNewLinesFromStartNEnd()
        textView.text.removeWhiteSpacesFromStartNEnd()
        
        if textView.text == "" {
            textView.text = "Write a reply"
            self.sendBtn.isEnabled = false
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        var text = chatTextView.text!
        text.removeNewLinesFromStartNEnd()
        text.removeWhiteSpacesFromStartNEnd()
        
        if textView.text.count < 2 {
            self.chatTextView.updateConstraints()
            print("\nUpdate constraint called\n")
        }
        
        self.sendBtn.isEnabled = textView.text.count == 0 ? false : true
        if validate(textView: textView) {
            chatTextView.isScrollEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        var text = chatTextView.text!
        text.removeNewLinesFromStartNEnd()
        text.removeWhiteSpacesFromStartNEnd()
        
        text = textView.text.replacingOccurrences(of: "\n", with: "")
        textView.text = text
        
        sendBtn.isEnabled = text.count == 0 ? false : true
        
        let numberOfLines = textView.layoutManager.numberOfLines
        
        if numberOfLines >= 3 {
            chatTextView.isScrollEnabled = true
        } else {
            chatTextView.isScrollEnabled = false
        }
    }
    
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
              !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            // this will be reached if the text is nil (unlikely)
            // or if the text only contains white spaces
            // or no text at all
            return false
        }
        return true
    }
    
//    func removeTextFromTextView(textView: UITextView) {
//        textView.selectAll(textView.text)
//        if let range = textView.selectedTextRange { textView.replace(range, withText: "") }
//    }
}
extension ChatVC: NetworkResponseProtocols{
    func didReceiveChat() {
        self.hideLoader()
        if let unwrappedList = self.viewModel.chatResponse?.data {
            
            self.pageNumber == 1 ? self.msgs.removeAll() : ()
            
//            self.msgs.append(contentsOf: unwrappedList)
//            self.tableView.beginUpdates()
            self.msgs.insert(contentsOf: unwrappedList, at: 0)
            if unwrappedList.count > 0 {
                for each in unwrappedList{
                    self.messagesCount = self.messagesCount + each.chatList!.count
                }
                self.msgs.count == 0 ? self.tableView.setEmptyView("No Chat Found", "") : self.tableView.restore()
                self.tableView.reloadData()
                if self.pageNumber == 1 { self.tableView.scrollToBottom()  }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                    self.isLoading = false
                })
               
                

            } else {
                self.msgs.count == 0 ? self.tableView.setEmptyView("No Chat Found", "") : self.tableView.restore()

            }
        } else {
            self.showToast(message: self.viewModel.chatResponse?.message ?? "Some error occured", toastType: .red)
        }
        
    }
    
    func didSendMessage(){
        print(self.viewModel.sendMessageResponse)
        self.currentMessage = self.viewModel.sendMessageResponse?.data
        chatHubConnection?.invoke(method: "SendMessage", "\(PreferencesManager.getUserModel()!.id!)", self.identifier, self.currentMessage?.messageText ?? "", "\(self.isCircle)") { error in
            if let e = error {
//                self.appendMessage(message: "Error: \(e)")
                self.showToast(message: "Error: \(e)", toastType: .red)
            } else {
                self.msgs[self.msgs.count - 1].chatList?.append(self.currentMessage!)
                self.tableView.reloadData()
                self.tableView.scrollToBottom()
                self.sendBtn.hideLoading()
            }
        }
    }
    
    

    func didStartCallSession() {
        self.hideLoader()
        
        if let data = self.viewModel.startCallSessionResponse?.data {
            
            if let sessionID = data.sessionID,  let tokenID = data.tokenID, let apiKeyId = data.apiKey {
                sessionId = sessionID
                tokenId = tokenID
                apiKey = apiKeyId
                
                guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                    print("appdelegate is missing")
                    return
                }
                
                if
                    let joinLink = self.viewModel.startCallSessionResponse?.data?.joinLink,
                    let displayURL = self.viewModel.startCallSessionResponse?.data?.displayURL,
                    let name = self.viewModel.startCallSessionResponse?.data?.name,
                    let identifier = self.viewModel.startCallSessionResponse?.data?.identifier,
                    let callerIdentifier = self.viewModel.startCallSessionResponse?.data?.callerIdentifier,
                    let callType = self.viewModel.startCallSessionResponse?.data?.callType
                {
                    let params = [
                        "JoinLink": joinLink,
                        "DisplayURL": displayURL,
                        "Name": name,
                        "Identifier": identifier,
                        "CallerIdentifier": callerIdentifier,
                        "CallType": callType == 1 ? "Video" : "Audio"
                    ] as [String: Any]
                    
                    self.chatHubConnection?.send(method: "SendNotification", identifier, "\(params)") { error in

                        if let e = error {
                            self.showToast(message: "Error: \(e)", toastType: .red)
                        }
                    }
                }
                else {
                    self.showToast(message: self.viewModel.startCallSessionResponse?.message ?? "Something went wrong", toastType: .red)
                }
        
                if data.callType == 2 {
                    
                    appdelegate.callManager.startCalling(with: UUID(), calleeID: self.userName, hasVideo: data.callType == 2 ? false : true)
                    
                    
                    
                    if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "AudioCallVC") as? AudioCallVC {
                        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
                        navController.modalTransitionStyle = .crossDissolve
                        navController.modalPresentationStyle  = .overFullScreen
                        vc.callName = self.userName
                        vc.identifier = self.identifier
                        vc.callImage = self.imgUrl
//                        vc.username = self.userName
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.present(navController, animated: true)
                        }
                    }
                } else {
                    if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "OneToOneVideoVC") as? OneToOneVideoVC {
                        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
                        navController.modalTransitionStyle = .crossDissolve
                        navController.modalPresentationStyle  = .overFullScreen
                     
                        vc.isCaller = true
                        vc.identifier = self.identifier
                        vc.userName = self.userName
                        vc.imgUrl = self.imgUrl
                        self.present(navController, animated: true)
                    }
                }
                    
//                }
                
//                      sender.setTitle(endCallText, for: .normal)
//                      sender.setTitleColor(.red, for: .normal)
//                      simulateCallButton.isEnabled = false
//                      simulateCallButton2.isEnabled = false
//                    } else if sender.titleLabel?.text == unholdCallText { // This state set when user receives another call
//                      appdelegate.callManager.setHeld(call: appdelegate.callManager.calls[0], onHold: false)
//                    }
//                    else {
//                      endCall()
//                      sender.setTitle(makeACallText, for: .normal)
//                      sender.setTitleColor(.white, for: .normal)
//                      simulateCallButton.isEnabled = true
//                      simulateCallButton2.isEnabled = true
//                    }
            }
        }
        else {
            self.showToast(message: self.viewModel.startCallSessionResponse?.message ?? "Something went wrong", toastType: .red)
        }
    }
}

// MARK: - Extension For Delete which will be fired when admin delete group char.
extension ChatVC{
    @objc func backToMessenger() {
        Alert.sharedInstance.alertOkWindow(title: "Chat Deleted", message: "This chat has been deleted by Admin") { result in
            if result{
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
//extension ChatVC: HubConnectionDelegate{
//
//    func connectionDidOpen(hubConnection: SwiftSignalRClient.HubConnection) {
//        print(hubConnection.connectionId)
////        self.signalRRegisterUser()
//        self.signalRChatSeen()
//    }
//
//    func connectionDidFailToOpen(error: Error) {
//        print(error)
//    }
//
//    func connectionDidClose(error: Error?) {
//        print(error)
//    }
//
//
//}
