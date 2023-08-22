//
//  HomeVC.swift
//  Swarm Circle
//
//  Created by Macbook on 04/07/2022.
//

import UIKit
import SwiftSignalRClient

class HomeVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pageNumber: Int = 2 // because we are fetching initial 50 on landing page
    
    var postList: [PostDM] = []
    
    let viewModel = ViewModel()
    
    var connection: HubConnection?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        self.initUI()
        self.initVariable()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)

        self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        
        if PreferencesManager.isCallActive() {
            self.viewModel.delegateNetworkResponse = self
            self.viewModel.callMemberStop()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Home"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.pauseVideo()
    }
    
    // MARK: - Initialization UI
    func initUI() {
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Home"
        
        //tableView Nib registration
        self.tableView.register(UINib(nibName: "PostsHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PostsHeaderView")
        self.tableView.register(UINib(nibName: "FeedsTextCell", bundle: nil), forCellReuseIdentifier: "FeedsTextCell")
        self.tableView.register(UINib(nibName: "FeedsMediaCell", bundle: nil), forCellReuseIdentifier: "FeedsMediaCell")
        
        self.tableView.refreshControl = refreshControl
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0, execute: {
//            if UserDefaults.standard.bool(forKey: "notificationExist") == true {
//
//                self.showToast(message: "Method Called", toastType: .red)
//                if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
//                    self.navigationController?.pushViewController(vc, animated: true)
//            http://216.108.238.109:7927/Swagger/index.html        //                    UserDefaults.standard.removeObject(forKey: "notificationExist")
//                }
//
//
//            } else {
////                self.showToast(message: "Method Not Called", toastType: .red)
//            }
//        })
    }
    
    // MARK: - Load data from API
    func initVariable() {
        
        self.configureSignalR()
        if let initialPostList = PreferencesManager.getInitial50Feeds() {
            self.postList.append(contentsOf: initialPostList)
            self.tableView.reloadData()
        } else {
            self.showLoader()
            self.pageNumber = 1
        }
        
        self.viewModel.delegateNetworkResponse = self
        self.getPostList()
    }
    
    // MARK: - Refresh Post List on Pull
    override func pullToRefreshActionPerformed() {
        
        refreshControl.endRefreshing()
        self.pageNumber = 1
        self.getPostList()
    }
    
    // MARK: - Get Post List
    func getPostList() {
        self.viewModel.getPostList(pageNumber: self.pageNumber, postId: 0, profileIdentifier: "", hashtag: "")
    }
    
    // MARK: - Delete Post
    func deletePost(postId: Int, object: PostDM) {
        self.viewModel.deletePost(postId: postId, object: object as AnyObject)
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
        
        self.viewModel.saveLike(params: params, object: object as AnyObject, sourceType: 1, replyId: -1)
    }
    
    // MARK: - ChildViewControllers
    private func addChildContentViewController(_ childViewController: UIViewController) {
        addChild(childViewController)
        childViewController.didMove(toParent: self)
    }
}

extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PostsHeaderView") as? PostsHeaderView else {
            return UIView()
        }
        
        header.configureHeader()
        header.createPostBtn.addTarget(self, action: #selector(createPostTapped(_:)), for: .touchUpInside)
        header.clipboardBtn.addTarget(self, action: #selector(clipboardBtnTapped(_:)), for: .touchUpInside)
        header.profilePicBtn.addTarget(self, action: #selector(self.profileIconTappedHeader), for: .touchUpInside)
        return header
    }
    
    @objc func profileIconTappedHeader() {
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            vc.profileIdentifier = PreferencesManager.getUserModel()?.identifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: -  What's on your mind tapped
    @objc func createPostTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Posts.instance.instantiateViewController(withIdentifier: "CreatePostVC") as? CreatePostVC {
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: -  Clipboard button tapped (Copy User Id to Clipboard)
    @objc func clipboardBtnTapped(_ sender: UIButton) {
        UIPasteboard.general.string = "\(PreferencesManager.getUserModel()?.userID ?? "")"
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
            cell.profilePicBtn.tag = indexPath.row
            cell.profilePicBtn.addTarget(self, action: #selector(self.profileIconTapped(_:)), for: .touchUpInside)
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
            cell.profilePicBtn.tag = indexPath.row
            cell.profilePicBtn.addTarget(self, action: #selector(self.profileIconTapped(_:)), for: .touchUpInside)
            
            return cell
        }
    }
    
    @objc func profileIconTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            vc.profileIdentifier = self.postList[sender.tag].userIdentifier
            self.navigationController?.pushViewController(vc, animated: true)
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
                if !(media.fileType?.contains("mage") ?? false) {
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

extension HomeVC: NetworkResponseProtocols {
    
    // MARK: - Post List Response
    func didGetPostList() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.postListResponse?.data {
            
            self.pageNumber == 1 ? self.postList.removeAll() : ()
            
            self.postList.append(contentsOf: unwrappedList)
            
            self.tableView.reloadData()
            
            self.postList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: viewModel.postListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.postList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
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
}

extension HomeVC: AppProtocol {
    
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
        
        networkManager.getPostList(pageNumber: 1, pageLimit: 1, postId: postId, profileIdentifier: "", hashtag: "") { [weak self] result in
            
//            self?.tableView.bounces = true
            
            switch result {
                
            case .success(let apiResponse):
                
                print(apiResponse)
                
                if var postDetail = apiResponse.data?.first {
                    
                    postDetail.isContentExpanded = self?.postList[postIndex].isContentExpanded
                    self?.postList[postIndex].isLikeBtnEnabled = true
                    
                    if self?.checkIfPostWasEdited(oldPostIndex: postIndex, newPost: postDetail) ?? false {
                        self?.postList[postIndex] = postDetail
                        self?.tableView.reloadRows(at: [IndexPath(row: postIndex, section: 0)], with: .none)
                        self?.showToast(message: "This Post has been Edited", delay: 1.5, toastType: .green)
                    } else {
                        self?.postList[postIndex] = postDetail
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
        if self.postList[oldPostIndex].mediaList?.count != newPost.mediaList?.count {
            return true
        }
        for (old, new) in zip(self.postList[oldPostIndex].mediaList ?? [], newPost.mediaList ?? []) {
            if old.fileURL != new.fileURL {
                return true
                
            }
        }
        return false
    }
    
    func addNewPost() {
        
        let networkManager = APIManager()
        
        networkManager.getPostList(pageNumber: 1, pageLimit: 1, postId: 0, profileIdentifier: "", hashtag: "") { [weak self] result in
            
            switch result {
                
            case .success(let apiResponse):
                
                print(apiResponse)
                
                if let postDetail = apiResponse.data?.first {
                    self?.postList.insert(postDetail, at: 0)
                    self?.tableView.reloadData()
                } else {
                    print("Recently added post couldn't be fetched.")
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                self?.showToast(message: error.localizedDescription, toastType: .red)
            }
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

//Mark:- Configuration For Signal R
extension HomeVC: HubConnectionDelegate{
    
    // MARK: - Signal R Configuration with singleton
    
    func configureSignalR(){
        SignalRService.signalRService.chatHubConnectionDelegate = self
        SignalRService.signalRService.initializeSignalR { connection in
            self.connection = connection
            
       
//                AppDelegate().signalRCallDropByCallerOnReceive()
            
            
        }
    }
    
    
    
    func connectionDidOpen(hubConnection: HubConnection) {
//        print("Connection Id: \(hubConnection.connectionId)")
        self.signalRRegisterUser()
    }
    
    func connectionDidFailToOpen(error: Error) {
        self.showToast(message: "\(error)", toastType: .red)
    }
    
    func connectionDidClose(error: Error?) {
        self.showToast(message: "\(error)", toastType: .red)
    }
    
    func connectionWillReconnect(error: Error?) {
        self.showToast(message: "\(error)", toastType: .red)
    }
    
    func connectionDidReconnect() {
        print("Connection Reconnected")
        self.connection = SignalRService.signalRService.connection
    }
    
    // MARK: - Signal R Register Users For Signal R
    private func signalRRegisterUser() {
        let params = ["Identifier": "\(PreferencesManager.getUserModel()?.identifier ?? "")",
                      "UserName": "\(PreferencesManager.getUserModel()?.firstName ?? "") \(PreferencesManager.getUserModel()?.firstName ?? "")",
                      "Role":"User",
                      "DeviceType":"iOS"]
        
        self.connection?.send(method: "joinedUser", arguments: [params]) { error in
            print(error)
            if let e = error {
                print("Something went wrong \(e)")
            }
        }
    }
}
