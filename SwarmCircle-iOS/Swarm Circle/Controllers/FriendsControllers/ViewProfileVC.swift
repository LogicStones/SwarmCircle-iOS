//
//  FriendsPublicProfileVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/08/2022.
//

import UIKit

enum SourceController: String {
    case MyFriendsVC
    case ConnectWithFriendsVC
    case PendingFriendRequestVC
    case FriendsListVC
    case InviteFriendsToCircleVC
}

class ViewProfileVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var profileIdentifier: String?
    var postIdentifier: String?
    var profileData: ViewProfileDM?
    
    var pageNumber: Int = 1
    
    var postList: [PostDM] = []
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    var sourceController: SourceController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Profile"
    }
    
    func initUI() {
        
        //tableView Nib registration
        self.tableView.register(UINib(nibName: "ViewProfileHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "ViewProfileHeaderView")
        self.tableView.register(UINib(nibName: "FeedsTextCell", bundle: nil), forCellReuseIdentifier: "FeedsTextCell")
        self.tableView.register(UINib(nibName: "FeedsMediaCell", bundle: nil), forCellReuseIdentifier: "FeedsMediaCell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.pauseVideo()
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        
        if self.profileIdentifier == nil && self.postIdentifier == nil {
            popOnErrorAlert("Some error occured")
            return
        }
        
        self.showLoader()
        self.getViewProfileDetails()
        self.getPostList()
    }
    
    // MARK: - Get Profile Details
    func getViewProfileDetails() {
        if self.postIdentifier == nil {
            self.viewModel.getViewProfileDetails(profileIdentifier: self.profileIdentifier!)
        }
        else {
            self.tableView.bounces = false
            // Remove space between sections.
            self.tableView.sectionHeaderHeight = 0
            self.tableView.sectionFooterHeight = 0
            
            // Remove space at top and bottom of tableView.
            self.tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: CGFloat.leastNormalMagnitude)))
            self.tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: CGFloat.leastNormalMagnitude)))
        }
    }
    
    // MARK: - Accept Friend Request
    func acceptRequest(userId: Int, requestId: Int, object: PendingUserDM) {
        showLoader()
        self.viewModel.acceptFriendInviteRequest(params: ["userId": userId, "requestId": requestId], object: object as AnyObject) // This object has no use in call back (because we are using loader)
    }
    
    // MARK: - Reject Friend Request
    func rejectRequest(id: Int, object: PendingUserDM) {
        showLoader()
        self.viewModel.rejectFriendInviteRequest(params: ["requestId": id], object: object as AnyObject)
        // This object has no use in call back (because we are using loader)
    }
    
    // MARK: - Send/Cancel Friend Request
    func sendFriendRequest(userId: Int, status: Bool) {
        self.viewModel.sentFriendRequest(params: ["userId": userId, "status": status], indexPath: IndexPath(row: 0, section: 0)) // This indexPath has no use in call back (because there is no list in this controller)
    }
    
    // MARK: - Remove Friend
    func postRemoveFriend(id: Int, object: FriendDM) {
        self.viewModel.removeFriend(params: ["userId": id], object: object as AnyObject) // This object has no use in call back (because we are using loader)
    }
    
    // MARK: - Remove Button Tapped
    @objc func removeFriendBtnTapped(_ sender: UIButton) {
        
        Alert.sharedInstance.alertWindow(title: "", message: "Are you sure you want to unfriend \(profileData?.firstName?.capitalized ?? "") \(profileData?.lastName?.capitalized ?? "")?") { result in
            if result {
                guard let id = self.profileData?.id else {
                    self.showToast(message: "Some error occured", delay: 2, toastType: .red)
                    return
                }
                self.showLoader()
                self.postRemoveFriend(id: id, object: FriendDM(id: nil, inviteID: nil, identifier: nil, name: nil, displayImageURL: nil, email: nil, circleCount: nil, walletID: nil, isOnline: nil)) // This object has no use in call back (because we are using loader)
            }
        }
    }
    
    // MARK: - Get Post List
    func getPostList() {
        self.viewModel.getPostList(pageNumber: self.pageNumber, postId: 0, postIdentifier: self.postIdentifier ?? "", profileIdentifier: self.profileIdentifier ?? "", hashtag: "")
    }
    
    // MARK: - Like Post
    func likePost(postId: Int, object: PostDM) {
        
        guard let isLiked = object.isLiked else {
            return
        }
        /*
         sourceType = 0 => Comment
         sourceType = 1 => Main Post
         sourceType = 2 => Reply
         */
        let params = [
            "sourceID": postId,
            "sourceType": 1,
            "isActive": isLiked
        ]
        as [String : Any]
        
        self.viewModel.saveLike(params: params, object: object as AnyObject, sourceType: 1, replyId: -1) // reply id is not used in this controller
    }
    
    // MARK: - Delete Post
    func deletePost(postId: Int, object: PostDM) {
        self.viewModel.deletePost(postId: postId, object: object as AnyObject)
    }
    
    // MARK: - ChildViewControllers
    private func addChildContentViewController(_ childViewController: UIViewController) {
        addChild(childViewController)
        childViewController.didMove(toParent: self)
    }
}

// MARK: - TableView Configuration
extension ViewProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ViewProfileHeaderView") as? ViewProfileHeaderView else {
            return UIView()
        }
        
        if let profileData {
            
            header.configureHeader(info: profileData)
            header.clipboardBtn.addTarget(self, action: #selector(clipboardBtnTapped(_:)), for: .touchUpInside)
            header.inviteBtn.addTarget(self, action: #selector(inviteBtnTapped(_:)), for: .touchUpInside)
            header.acceptFriendBtn.addTarget(self, action: #selector(acceptFriendBtnTapped(_:)), for: .touchUpInside)
            header.rejectFriendBtn.addTarget(self, action: #selector(rejectFriendBtnTapped(_:)), for: .touchUpInside)
            header.chatNowBtn.addTarget(self, action: #selector(chatNowBtnTapped(_:)), for: .touchUpInside)
            header.removeFriendBtn.addTarget(self, action: #selector(removeFriendBtnTapped(_:)), for: .touchUpInside)
            header.phoneNoBtn.addTarget(self, action: #selector(phoneBtnTapped(_:)), for: .touchUpInside)
            header.emailBtn.addTarget(self, action: #selector(emailBtnTapped(_:)), for: .touchUpInside)
            header.facebookBtn.addTarget(self, action: #selector(facebookBtnTapped(_:)), for: .touchUpInside)
            header.twitterBtn.addTarget(self, action: #selector(twitterBtnTapped(_:)), for: .touchUpInside)
            header.youtubeBtn.addTarget(self, action: #selector(youtubeBtnTapped(_:)), for: .touchUpInside)
            header.instagramBtn.addTarget(self, action: #selector(instagramBtnTapped(_:)), for: .touchUpInside)
            
            header.circleListBtn.addTarget(self, action: #selector(circleListBtnTapped(_:)), for: .touchUpInside)
            header.friendListBtn.addTarget(self, action: #selector(friendListBtnTapped(_:)), for: .touchUpInside)
            
            return header
        }
        return nil
    }
    
    // MARK: - Friend list button tapped
    @objc func friendListBtnTapped(_ sender: UIButton) {
        
        guard let friendList = self.profileData!.profileFriends else {
            return
        }
        
        if let vc = AppStoryboard.Posts.instance.instantiateViewController(withIdentifier: "ListVC") as? ListVC {
            
            let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
            navController.modalTransitionStyle = .crossDissolve
            navController.modalPresentationStyle  = .overFullScreen
            
            vc.listType = .friendList
            vc.friendList = friendList
            
            self.present(navController, animated: true)
        }
    }
    
    // MARK: - Circle list button tapped
        @objc func circleListBtnTapped(_ sender: UIButton) {
            
            guard let circleList = self.profileData!.profileCircles else {
                return
            }
            
            if let vc = AppStoryboard.Posts.instance.instantiateViewController(withIdentifier: "ListVC") as? ListVC {
                
                let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
                navController.modalTransitionStyle = .crossDissolve
                navController.modalPresentationStyle  = .overFullScreen
                
                vc.listType = .circleList
                vc.circleList = circleList
                
                self.present(navController, animated: true)
            }
        }
    
    // MARK: - Facebook Button Tapped
    @objc func facebookBtnTapped(_ sender: UIButton) {
        if let urlString = profileData?.facebookLink {
            
            //            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
            
            //            if urlString.isValidURLString {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
            else {
                self.showToast(message: "URL was not added", toastType: .red)
            }
            //            }
            
            //            UIApplication.shared.open(URL(string: urlString)!) // uncomment this after hide/show functionality is available
        }
        else {
            self.showToast(message: "URL was not added", toastType: .red)
        }
        
    }
    
    // MARK: - Twitter Button Tapped
    @objc func twitterBtnTapped(_ sender: UIButton) {
        if let urlString = profileData?.twitterLink {
            
            //            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
            
            //            if urlString.isValidURLString {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
            else {
                self.showToast(message: "URL was not added", toastType: .red)
            }
            //            }
            
            
            //            UIApplication.shared.open(URL(string: urlString)!) // uncomment this after hide/show functionality is available
        }
        else {
            self.showToast(message: "URL was not added", toastType: .red)
        }
    }
    
    // MARK: - Instagram Button Tapped
    @objc func instagramBtnTapped(_ sender: UIButton) {
        if let urlString = profileData?.instagramLink {
            
            //            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
            
            //            if urlString.isValidURLString {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
            else {
                self.showToast(message: "URL was not added", toastType: .red)
            }
            //            }
            
            //            UIApplication.shared.open(URL(string: urlString)!) // uncomment this after hide/show functionality is available
        }
        else {
            self.showToast(message: "URL was not added", toastType: .red)
        }
    }
    
    // MARK: - Youtube Button Tapped
    @objc func youtubeBtnTapped(_ sender: UIButton) {
        if let urlString = profileData?.youtubeLink {
            
            //            let urlString = "\(urlString.replacingOccurrences(of: "\\", with: #"/"#))"
            
            //            if urlString.isValidURLString {
            if let url = URL(string: urlString) {
                UIApplication.shared.open(url)
            }
            else {
                self.showToast(message: "URL was not added", toastType: .red)
            }
            //            }
            //            UIApplication.shared.open(URL(string: urlString)!) // uncomment this after hide/show functionality is available
        }
        else {
            self.showToast(message: "URL was not added", toastType: .red)
        }
    }
    
    // MARK: - Chat Now Button Tapped
    @objc func chatNowBtnTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
            
            vc.identifier = self.profileData?.identifier ?? ""
            vc.userName = "\(self.profileData?.firstName?.capitalized ?? "") \(self.profileData?.lastName?.capitalized ?? "")"
            vc.isCircle = false
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Email Button Tapped
    @objc func emailBtnTapped(_ sender: UIButton) {
        
        self.pauseVideo()
        
        guard let email = self.profileData?.email else {
            return
        }
        if email.isEmpty {
            return
        }
        
        Utils.openEmailIntent(self, emailAddresses: [email])
    }
    
    // MARK: - Phone Button Tapped
    @objc func phoneBtnTapped(_ sender: UIButton) {
        
        self.pauseVideo()
        
        guard let phoneNo = self.profileData?.phoneNo else {
            return
        }
        if phoneNo.isEmpty {
            return
        }
        
        Utils.callNumber(phoneNumber: phoneNo)
    }
    
    // MARK: - Accept Friend Request Button Tapped
    @objc func acceptFriendBtnTapped(_ sender: UIButton) {
        
        self.pauseVideo()
        
        guard
            let requestReceivedId = profileData?.requestRecievedID,
            let userId = profileData?.id
        else {
            return
        }
        
        self.acceptRequest(userId: userId, requestId: requestReceivedId, object: PendingUserDM(id: nil, sentFrom: nil, sentTo: nil, inviteStatus: nil, createdOn: nil, userID: nil, name: nil, identifier: nil, displayImageURL: nil, circleCount: nil)) // This object has no use in call back (because we are using loader)
    }
    
    // MARK: - Reject Friend Request Button Tapped
    @objc func rejectFriendBtnTapped(_ sender: UIButton) {
        
        self.pauseVideo()
        
        guard let requestReceivedId = profileData?.requestRecievedID else {
            return
        }
        
        self.rejectRequest(id: requestReceivedId, object: PendingUserDM(id: nil, sentFrom: nil, sentTo: nil, inviteStatus: nil, createdOn: nil, userID: nil, name: nil, identifier: nil, displayImageURL: nil, circleCount: nil)) // This object has no use in call back (because we are using loader)
    }
    
    // MARK: - Invite Button Tapped
    @objc func inviteBtnTapped(_ sender: UIButton) {
        
        self.pauseVideo()
        
        guard
            let id = profileData?.id,
            let _ = profileData?.isFriendRequestSent
        else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }
        
        if !sender.isSelected {
            self.sendFriendRequest(userId: id, status: false)
        } else {
            self.sendFriendRequest(userId: id, status: true)
        }
        
        if let header = tableView.headerView(forSection: 0) as? ViewProfileHeaderView {
            header.inviteBtn.isSelected = !header.inviteBtn.isSelected
        }
    }
    
    // MARK: -  Clipboard button tapped (Copy User Id to Clipboard)
    @objc func clipboardBtnTapped(_ sender: UIButton) {
        
        guard let userId = self.profileData?.uID else {
            return
        }
        
        UIPasteboard.general.string = "User Id: \(userId)"
        self.showToast(message: "User Id copied to clipboard", delay: 0.75, toastType: .black)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if  (postList[indexPath.row].mediaList?.count ?? 0) > 0 {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsMediaCell") as? FeedsMediaCell else {
                return UITableViewCell()
            }
            
            cell.navigationController = self.navigationController
            
            cell.feedsMediaController = AppStoryboard.Posts.instance.instantiateViewController(withIdentifier: "FeedsMediaController") as! FeedsMediaController
            
            cell.feedsMediaController.mediaArray = postList[indexPath.row].mediaList ?? []
            
            addChildContentViewController(cell.feedsMediaController)
            
            cell.hostedView = cell.feedsMediaController.view
            
            cell.configureCell(info: postList[indexPath.row])
            
            cell.readBtn.tag = indexPath.row
            cell.readBtn.addTarget(self, action: #selector(readBtnTapped(_:)), for: .touchUpInside)
            cell.menuBtn.tag = indexPath.row
            cell.menuBtn.addTarget(self, action:#selector(menuBtnTapped(_:)), for: .touchUpInside)
            cell.likeBtn.tag = indexPath.row
            cell.likeBtn.addTarget(self, action: #selector(likeBtnTapped(_:)), for: .touchUpInside)
            cell.cmtBtn.tag = indexPath.row
            cell.cmtBtn.addTarget(self, action: #selector(cmtBtnTapped(_:)), for: .touchUpInside)
            cell.shareBtn.tag = indexPath.row
            cell.shareBtn.addTarget(self, action: #selector(shareBtnTapped(_:)), for: .touchUpInside)
            
            return cell
        }
        else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsTextCell") as? FeedsTextCell else {
                return UITableViewCell()
            }
            
            cell.navigationController = self.navigationController
            
            cell.configureCell(info: postList[indexPath.row])
            
            cell.readBtn.tag = indexPath.row
            cell.readBtn.addTarget(self, action: #selector(readBtnTapped(_:)), for: .touchUpInside)
            cell.menuBtn.tag = indexPath.row
            cell.menuBtn.addTarget(self, action:#selector(menuBtnTapped(_:)), for: .touchUpInside)
            cell.likeBtn.tag = indexPath.row
            cell.likeBtn.addTarget(self, action: #selector(likeBtnTapped(_:)), for: .touchUpInside)
            cell.cmtBtn.tag = indexPath.row
            cell.cmtBtn.addTarget(self, action: #selector(cmtBtnTapped(_:)), for: .touchUpInside)
            cell.shareBtn.tag = indexPath.row
            cell.shareBtn.addTarget(self, action: #selector(shareBtnTapped(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !(postList[indexPath.row].isDeleted ?? false) {
            return tableView.rowHeight
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if self.postList.count < self.viewModel.postListResponse?.recordCount ?? 0 && indexPath.row == self.postList.count - 25 {
            self.pageNumber += 1
            self.getPostList()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? FeedsMediaCell {
            for (i, media) in cell.feedsMediaController.mediaArray.enumerated() {
                if !(media.fileType?.contains("image") ?? false) {
                    if let cell = cell.feedsMediaController.collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? MediaCell {
                        cell.videoPlayerController.avPlayer?.pause()
                    }
                }
            }
        }
    }
    
    @objc func menuBtnTapped(_ sender: UIButton) {
        
        self.pauseVideo()
        
        guard
            let postUserIdentifier = self.postList[sender.tag].userIdentifier,
            let userIdentifier = PreferencesManager.getUserModel()?.identifier
        else {
            return
        }
        
        var moreBtnActions: [(String, UIAlertAction.Style)] = [
            ("Cancel", UIAlertAction.Style.cancel)
        ]
        
        if postUserIdentifier == userIdentifier {
            moreBtnActions.insert(("Remove", UIAlertAction.Style.destructive), at: 0)
            moreBtnActions.insert(("Edit", UIAlertAction.Style.default), at: 0)
        } else {
            moreBtnActions.insert(("Report", UIAlertAction.Style.destructive), at: 0)
            //            moreBtnActions.insert(("Hide", UIAlertAction.Style.default), at: 0)
        }
        
        Alert.sharedInstance.showActionsheet(vc: self, title: "Manage Feed", message: "What do want to do?", actions: moreBtnActions) { _, title in
            
            switch title {
                
            case "Remove":
                
                guard let postId = self.postList[sender.tag].id else {
                    return
                }
                
                Alert.sharedInstance.alertWindow(title: "Warning", message: "Are you sure you want to delete this post?") { result in
                    
                    if result {
                        self.deletePost(postId: postId, object: self.postList[sender.tag])
                        
                        self.postList[sender.tag].isDeleted = true
                        self.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .fade)
                        self.checkIfPostListIsEmpty() ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                    }
                }
                print("Delete the post")
                break
                
            case "Edit":
                
                if let vc = AppStoryboard.Posts.instance.instantiateViewController(withIdentifier: "CreatePostVC") as? CreatePostVC {
                    
                    var mediaArray: [(Any, CreatePostVC.MediaType, UIImage?)] = []
                    
                    for media in self.postList[sender.tag].mediaList ?? [] {
                        
                        if let isImage = media.fileType?.contains("mage") {
                            mediaArray.append((media, isImage ? .OldImage : .OldVideo, nil))
                        } else {
                            Alert.sharedInstance.showAlert(title: "Error", message: "Some Error Occured")
                            return
                        }
                    }
                    
                    vc.postId = self.postList[sender.tag].id
                    vc.feedText = self.postList[sender.tag].content
                    vc.selectedPrivacyIndex = self.postList[sender.tag].privacy ?? 1
                    vc.mediaArray = mediaArray
                    vc.friendListSelected = self.postList[sender.tag].taggedFriends ?? []
                    vc.shareWithORExceptfriendListSelected = self.postList[sender.tag].sharedWith ?? []
                    vc.delegate = self
                    
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                print("Edit the Post")
                break
                
            case "Report":
                if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "ReportVC") as? ReportVC {
                    vc.modalPresentationStyle = .overFullScreen
                    vc.modalTransitionStyle = .crossDissolve
                    /*
                     sourceType = 0 => Comment
                     sourceType = 1 => Main Post
                     sourceType = 2 => Reply
                     */
                    vc.sourceType = 1
                    vc.sourceId = self.postList[sender.tag].id
                    self.present(vc, animated: true)
                }
                print("Report the post")
                break
                
            case "Hide":
                print("Hide the post")
                
            default :
                print("Default switch case")
            }
        }
    }
    
    // MARK: - Pause Video
    func pauseVideo() {
        
        for indexPath in self.tableView.indexPathsForVisibleRows ?? [] {
            
            if let cell = self.tableView.cellForRow(at: indexPath) as? FeedsMediaCell {
                for (i, media) in cell.feedsMediaController.mediaArray.enumerated() {
                    if !(media.fileType?.contains("mage") ?? false) {
                        if let cell = cell.feedsMediaController.collectionView.cellForItem(at: IndexPath(row: i, section: 0)) as? MediaCell {
                            cell.videoPlayerController.avPlayer?.pause()
                        }
                    }
                }
            }
        }
    }
    
    func checkIfPostListIsEmpty() -> Bool {
        let undeletedPost = self.postList.filter { !($0.isDeleted ?? false) }
        return undeletedPost.count > 0 ? false : true
    }
    
    @objc func readBtnTapped(_ sender: UIButton) {
        
        self.postList[sender.tag].isContentExpanded = !(self.postList[sender.tag].isContentExpanded ?? false)
        
        self.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: 0)], with: .fade)
    }
    
    @objc func cmtBtnTapped(_ sender: UIButton) {
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC {
            vc.postDetail = postList[sender.tag]
            vc.postIndex = sender.tag
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func likeBtnTapped(_ sender: UIButton) {
        
        guard
            let postId = self.postList[sender.tag].id,
            let _ = self.postList[sender.tag].isLiked,
            let _ = self.postList[sender.tag].likeCount
        else {
            return
        }
        
        //        self.tableView.bounces = false
        
        self.postList[sender.tag].isLikeBtnEnabled = false
        
        self.postList[sender.tag].isLiked = !self.postList[sender.tag].isLiked!
        self.postList[sender.tag].likeCount! += self.postList[sender.tag].isLiked! ? 1 : -1
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? FeedsMediaCell {
            cell.configureCell(info: postList[sender.tag])
        }
        else if let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: 0)) as? FeedsTextCell {
            cell.configureCell(info: postList[sender.tag])
        }
        
        self.likePost(postId: postId, object: self.postList[sender.tag])
    }
    
    // MARK: - Share (Post) Button Tapped
    @objc func shareBtnTapped(_ sender: UIButton) {
        
        //        guard let postIdentifier = self.postList[sender.tag].identifier else {
        //            return
        //        }
        //        let shareStringUrl = "\(AppConstants.baseURL)newsfeed?Post=\(postIdentifier)"
        
        guard let shareLink = self.postList[sender.tag].shareLink else {
            return
        }
        
        self.pauseVideo()
        
        Utils.openShareIntent(self, description: "Hey, Checkout this Post...", shareLink: shareLink)
    }
}


extension ViewProfileVC: NetworkResponseProtocols {
    
    func didGetViewProfileDetails() {
        
        if let data = self.viewModel.viewProfileDetailsResponse?.data {
            self.profileData = data
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
        }
        else {
            self.showToast(message: self.viewModel.viewProfileDetailsResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
    
    // MARK: - Accept Friend Request Response
    func didAcceptFriendInviteRequest(object: AnyObject) { // This object has no use in call back (because we are using loader)
        
        hideLoader()
        
        if self.viewModel.acceptFriendInviteRequestResponse?.data ?? false {
            
            switch sourceController {
                
            case .ConnectWithFriendsVC:
                self.delegate?.removeUserFromList()
                break
            case .PendingFriendRequestVC: // 0: pending friend request list and friend list (Accept), 1: pending friend request list (Reject), 2: friend list (Remove)
                self.delegate?.refreshPendingFriendList(refreshList: 0)
                break
                
            default:
                print("Switch default case")
            }
            
            self.profileData?.isMyFriend = true
            self.profileData?.isFriendRequestRecieved = false
            
            if let header = tableView.headerView(forSection: 0) as? ViewProfileHeaderView {
                header.hideNShowBtn(info: self.profileData!)
            }
            
            self.showLoader()
            self.pageNumber = 1
            self.getPostList()
            
            Alert.sharedInstance.showAlert(title: "Success", message: "You are now friends with \(profileData?.firstName?.capitalized ?? "") \(profileData?.lastName?.capitalized ?? "")")
            
        } else {
            self.showToast(message: viewModel.acceptFriendInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Reject Friend Request Response
    func didRejectFriendInviteRequest(object: AnyObject) { // This object has no use in call back (because we are using loader)
        
        hideLoader()
        
        if self.viewModel.rejectFriendInviteRequestResponse?.data ?? false {
            
            switch sourceController {
                
            case .PendingFriendRequestVC: // 0: pending friend request list and friend list (Accept), 1: pending friend request list (Reject), 2: friend list (Remove)
                self.delegate?.refreshPendingFriendList(refreshList: 1)
                break
                
            default:
                print("Switch default case")
            }
            
            self.profileData?.isMyFriend = false
            self.profileData?.isFriendRequestRecieved = false
            
            if let header = tableView.headerView(forSection: 0) as? ViewProfileHeaderView {
                header.hideNShowBtn(info: self.profileData!)
            }
            
            self.showToast(message: viewModel.rejectFriendInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            
        } else {
            self.showToast(message: viewModel.rejectFriendInviteRequestResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Remove Friend Response
    func didRemovedFriend(object: AnyObject) { // object is not used here because we are using loader.
        
        self.hideLoader()
        
        if (self.viewModel.removeFriendResponse?.data ?? false) {
            
            switch sourceController {
                
            case .FriendsListVC:
                self.delegate?.removeFriendFromList()
                break
            case .PendingFriendRequestVC: // 0: pending friend request list and friend list (Accept), 1: pending friend request list (Reject), 2: friend list (Remove)
                self.delegate?.refreshPendingFriendList(refreshList: 2)
                break
            case .InviteFriendsToCircleVC:
                self.delegate?.refreshInviteFriendToCircleList()
                break
                
            default:
                print("Switch default case")
            }
            
            
            self.profileData?.isMyFriend = false
            self.profileData?.isFriendRequestRecieved = false
            self.profileData?.isFriendRequestSent = false // some issue after removing a friend.
            
            if let header = tableView.headerView(forSection: 0) as? ViewProfileHeaderView {
                header.hideNShowBtn(info: self.profileData!)
            }
            
            self.showLoader()
            self.pageNumber = 1
            self.getPostList()
            
            Alert.sharedInstance.showAlert(title: "Success", message: "You are no longer friends with \(profileData?.firstName?.capitalized ?? "") \(profileData?.lastName?.capitalized ?? "")")
            
        } else {
            self.showToast(message: viewModel.removeFriendResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Post List Response
    func didGetPostList() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.postListResponse?.data {
            
            self.pageNumber == 1 ? self.postList.removeAll() : ()
            
            self.postList.append(contentsOf: unwrappedList)
            
            self.postIdentifier != nil ? (self.postList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()) : ()
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
            
        } else {
            self.showToast(message: viewModel.postListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.postIdentifier != nil ? (self.postList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()) : ()
        }
    }
    
    func didDeletePost(object: AnyObject) {
        
        if self.viewModel.deletePostResponse?.isSuccess ?? false {
            self.showToast(message: self.viewModel.deletePostResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            
        } else {
            
            if self.viewModel.deletePostResponse?.message != "no record found!" {
                self.showToast(message: self.viewModel.deletePostResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
                self.tableView.restore()
                
                if let postIndex = self.searchNGetIndexOfPostIfExist(object: object as! PostDM) {
                    self.postList[postIndex].isDeleted = false
                    self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: .fade)
                }
            }
            else {
                self.showToast(message: "Post was already Removed", delay: 2, toastType: .green)
            }
        }
    }
    
    func didSaveLike(object: AnyObject, sourceType: Int, replyId: Int) { // here we are not using sourceType because in this controller we have only one source i.e: 1 for posts.
        // Also we are not using replyId for this controller
        if self.viewModel.saveLikeResponse?.isSuccess ?? false {
            
            //            self.showToast(message: self.viewModel.saveLikeResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            
            guard let postId = (object as! PostDM).id else {
                return
            }
            self.updatePost(postId: postId)
            
        } else {
            
            self.showToast(message: self.viewModel.saveLikeResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            
            guard let postId = (object as! PostDM).id else {
                return
            }
            guard let postIndex = self.searchNGetIndexOfPostIfExist(postId: postId) else {
                return
            }
            
            self.postList[postIndex].isLiked = !self.postList[postIndex].isLiked!
            self.postList[postIndex].likeCount! += self.postList[postIndex].isLiked! ? 1 : -1
            
            self.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: .none)
            
            self.updatePost(postId: postId, index: postIndex)
        }
    }
    
    func searchNGetIndexOfPostIfExist(object: PostDM) -> Int? {
        
        guard let postId = object.id else {
            return nil
        }
        
        return self.searchNGetIndexOfPostIfExist(postId: postId)
    }
    
    func searchNGetIndexOfPostIfExist(postId: Int) -> Int? {
        
        for (index, post) in self.postList.enumerated() {
            if post.id == postId {
                return index
            }
        }
        return nil
    }
    
    // MARK: - Send/Cancel Friend Request Response
    func didSentFriendRequest(indexPath: IndexPath) { // indexPath is not used here because we don't have a list in this controller
        
        if self.viewModel.friendRequestSentResponse?.data ?? false {
            self.showToast(message: viewModel.friendRequestSentResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            self.delegate?.updateFriendRequestStatus()
        } else {
            self.showToast(message: viewModel.friendRequestSentResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            if let header = tableView.headerView(forSection: 0) as? ViewProfileHeaderView {
                header.inviteBtn.isSelected = !header.inviteBtn.isSelected
            }
        }
    }
}

extension ViewProfileVC: AppProtocol {
    
    func updatePost(postId: Int, index: Int? = nil) {
        
        var postIndex: Int?
        
        if let index {
            postIndex = index
        }
        else if let index = self.searchNGetIndexOfPostIfExist(postId: postId) {
            postIndex = index
        }
        
        guard let postIndex else {
            //            self.tableView.bounces = true
            return
        }
        
        let networkManager = APIManager()
        
        networkManager.getPostList(pageNumber: 1, pageLimit: 1, postId: postId, postIdentifier: self.postIdentifier ?? "", profileIdentifier: self.profileIdentifier ?? "", hashtag: "") { [weak self] result in
            
            //            self?.tableView.bounces = true
            
            switch result {
                
            case .success(let apiResponse):
                
                print(apiResponse)
                
                if var postDetail = apiResponse.data?.first {
                    postDetail.isContentExpanded = self?.postList[postIndex].isContentExpanded
                    
                    self?.postList[postIndex] = postDetail
                    self?.postList[postIndex].isLikeBtnEnabled = true
                    
                    if self?.checkIfPostWasEdited(oldPostIndex: postIndex, newPost: postDetail) ?? false {
                        self?.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: .none)
                        self?.showToast(message: "This Post has been Edited", delay: 1, toastType: .green)
                    } else {
                        if let cell = self?.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? FeedsMediaCell {
                            cell.configureCell(info: postDetail)
                        }
                        else if let cell = self?.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? FeedsTextCell {
                            cell.configureCell(info: postDetail)
                        }
                        
                    }
                } else {
                    self?.showToast(message: "This Post was Removed", toastType: .red)
                    self?.postList[postIndex].isDeleted = true
                    self?.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: .none)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                self?.postList[postIndex].isLikeBtnEnabled = true
                self?.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: .none)
                self?.showToast(message: error.localizedDescription, toastType: .red)
            }
        }
    }
    
    func checkIfPostWasEdited(oldPostIndex: Int, newPost: PostDM) -> Bool {
        
        if self.postList[oldPostIndex].content != newPost.content {
            return true
        }
        else if self.postList[oldPostIndex].mediaList?.count != newPost.mediaList?.count {
            return true
        }
        else {
            for (old, new) in zip(self.postList[oldPostIndex].mediaList ?? [], newPost.mediaList ?? []) {
                if old.fileURL != new.fileURL {
                    return true
                    
                }
            }
            return false
        }
    }
    
    // MARK: - Update Comment Count after a comment is added or deleted in CommentsVC
    func updateCommentCount(postIndex: Int, increment: Int) {
        
        self.postList[postIndex].commentCount! += increment
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? FeedsTextCell {
            cell.cmtCountLbl.text = "\(self.postList[postIndex].commentCount ?? 0) Comments"
        }
        else if let cell = self.tableView.cellForRow(at: IndexPath(row: postIndex, section: 0)) as? FeedsMediaCell {
            cell.cmtCountLbl.text = "\(self.postList[postIndex].commentCount ?? 0) Comments"
        }
    }
    
    // MARK: - Delete Post after a Post is found deleted in CommentVC
    func deletePost(index: Int) {
        
        self.postList[index].isDeleted = true
        self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        self.checkIfPostListIsEmpty() ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
    }
}


import MessageUI

// MARK: - Email Intent
extension ViewProfileVC: MFMailComposeViewControllerDelegate {
    
    // MARK: MailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Dismiss the mail compose view controller.
        dismiss(animated: true)
    }
    
}
