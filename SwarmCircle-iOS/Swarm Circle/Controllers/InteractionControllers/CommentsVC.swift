//
//  CommentsVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 18/08/2022.
//

import UIKit

/*
 sourceType = 0 => Comment
 sourceType = 1 => Main Post
 sourceType = 2 => Reply
 */
struct ReplyDM {
    var reply: ComRepDM
    var isDeleted = false
}

struct CommentReplyDM {
    var comment: ComRepDM
    var replies: [ReplyDM] = []
    var isDeleted: Bool = false // is comment deleted
}

class CommentsVC: BaseViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addCommentTxtView: UITextView!
    @IBOutlet weak var postBtn: LoadingButton!
    
    @IBOutlet weak var replyingToLbl: UILabel!
    @IBOutlet weak var replyingToCloseBtn: UIButton!
    
    var postDetail: PostDM?
    var postIdentifier: String?
    var postIndex: Int?
    
    var pageNumber: Int = 1
    var commentNReplyList: [CommentReplyDM] = []
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Initialization UI
    func initUI() {
        
        if self.postDetail?.id == nil && self.postIdentifier == nil {
            // Go back to previous (post list/home) screen if id doesn't exist.
            popOnErrorAlert("Some error occured")
            return
        }
        
        self.tableView.remembersLastFocusedIndexPath = true
        
        //        TableView Nib registration
        self.tableView.register(UINib(nibName: "CommentsCell", bundle: nil), forCellReuseIdentifier: "CommentsCell")
        self.tableView.register(UINib(nibName: "AddCommentsCell", bundle: nil), forCellReuseIdentifier: "AddCommentsCell")
        self.tableView.register(UINib(nibName: "CommentsHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "CommentsHeaderView")
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        self.replyingToCloseBtn.isHidden = true
        self.postBtn.isEnabled = false
        
        self.tableView.refreshControl = refreshControl
        
        // Remove space between sections.
//        tableView.sectionHeaderHeight = 0
        self.tableView.sectionFooterHeight = 0

        // Remove space at top and bottom of tableView.
        self.tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: CGFloat.leastNormalMagnitude)))
        self.tableView.tableFooterView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: CGFloat.leastNormalMagnitude)))
    }
    
    // MARK: - Load data from API
    func initVariable() {
        
        self.viewModel.delegateNetworkResponse = self
        
        self.showLoader()
        
        self.postIdentifier == nil ? self.getCommentList() : self.getPostDetail()
    }
    
    // MARK: - Get Post Detail
    func getPostDetail() {
        self.viewModel.getPostList(pageNumber: 1, pageLimit: 1, postId: 0, postIdentifier: self.postIdentifier!, profileIdentifier: "", hashtag: "")
    }
    
    // MARK: - Refresh Comment List on Pull
    override func pullToRefreshActionPerformed() {
        
        refreshControl.endRefreshing()
        
        self.replyingToLbl.text = ""
        self.replyingToCloseBtn.accessibilityElements = nil
        self.replyingToCloseBtn.isHidden = true
        DispatchQueue.main.async {
            self.addCommentTxtView.text = "Write a comment"
            self.addCommentTxtView.isScrollEnabled = false
            self.addCommentTxtView.updateConstraints()
            self.textViewDidChange(self.addCommentTxtView)
        }
        
        self.addCommentTxtView.resignFirstResponder()
        
        self.showLoader()
        
        self.pageNumber = 1
        
        self.getCommentList()
    }
    
    // MARK: - Fetch Comment List
    func getCommentList() {
        self.viewModel.getCommentList(pageNumber: self.pageNumber, postId: postDetail!.id!, commentId: 0)
    }
    
    // MARK: - Fetch Reply List
    func getReplyList(replyId: Int = 0, commentId: Int) { // Fetch individual reply (comment id: not 0, reply id: not 0, is new reply added: true) or reply list (comment id: not 0, reply id: 0, is new reply added: false)
        self.viewModel.getReplyList(pageNumber: 0, postId: postDetail!.id!, replyId: replyId, commentId: commentId)
    }
    
    // MARK: - Save Comment and Reply
    func saveCommentReply(sourceType: Int, commentId: Int) {
        
        /*
         sourceType = 0 => Comment
         sourceType = 1 => Main Post
         sourceType = 2 => Reply
         */
        let params = [
            "comment": Utils.encodeUTF(self.addCommentTxtView.text!),
            "sourceType": sourceType,
            "commentID": commentId,
            "postID": self.postDetail!.id!
        ]
        as [String : Any]
        self.viewModel.saveCommentReply(params: params)
    }
    
    // MARK: - Like Comment and Reply
    func likeCommentReply(sourceId: Int, sourceType: Int, object: ComRepDM, replyId: Int) {
        
        guard let isLiked = object.isLiked else {
            return
        }
        /*
         sourceType = 0 => Comment
         sourceType = 1 => Main Post
         sourceType = 2 => Reply
         */
        let params = [
            "sourceID": sourceId,
            "sourceType": sourceType,
            "isActive": isLiked
        ]
        as [String : Any]
        
        self.viewModel.saveLike(params: params, object: object as AnyObject, sourceType: sourceType, replyId: replyId)
    }
    
    // MARK: - Edit Comment
    func editComment(commentId: Int, originalComment: String) {
        
        let params = [
            "comment": Utils.encodeUTF(self.addCommentTxtView.text!),
            "commentID": commentId
//            "replyID": 0
        ]
        as [String : Any]
        
        self.viewModel.editComment(params: params, originalComment: originalComment)
    }
    
    // MARK: - Edit Reply
    func editReply(commentId: Int, replyId: Int, originalReply: String) {
        
        let params = [
            "comment": Utils.encodeUTF(self.addCommentTxtView.text!),
            "commentID": commentId,
            "replyID": replyId
        ]
        as [String : Any]
        
        self.viewModel.editReply(params: params, originalReply: originalReply)
    }
    
    // MARK: - Delete Comment
    func deleteComment(commentId: Int, object: ComRepDM) {
        self.viewModel.deleteComment(commentId: commentId)
    }
    
    // MARK: - Delete Reply
    func deleteReply(replyId: Int, object: CommentReplyDM) {
        self.viewModel.deleteReply(replyId: replyId, object: object as AnyObject)
    }
    
    // handling show / hide keyboard
    @objc func handleKeyboardNotification(notification: NSNotification) {
        
        if let userInfo = notification.userInfo {
            
            // get the size of keyboard
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            // checking keyboard status weather it's showing or hidden
            if isKeyboardShowing {
                print("Keyboard Showing")
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - keyboardSize.height, right: 0)
                
                self.lastBottomConstraint.constant = keyboardSize.height + 0
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            } else{
                print("Keyboard Hidden")
                
                self.lastBottomConstraint.constant = 0
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            view.layoutIfNeeded()
        }
    }
    
    // MARK: - Replying to Close Button Tapped.
    @IBAction func replyingToCloseBtnTapped(_ sender: UIButton) { // Remove all the text from chat, now posting button will post a new comment to the list.
        sender.isHidden = true
        self.replyingToLbl.text = ""
        self.replyingToLbl.accessibilityElements = nil
    }
    
    // MARK: - Post Button Tapped.
    @IBAction func postBtnPressed(_ sender: UIButton) { // Post Comment, Post Reply, Edit Comment, Edit Reply
        
        self.addCommentTxtView.resignFirstResponder()
        
        self.addCommentTxtView.text.removeWhiteSpacesFromStartNEnd()
        self.addCommentTxtView.text.removeNewLinesFromStartNEnd()
        
        if self.addCommentTxtView.text!.isEmpty {
            self.showToast(message: "Comment text cannot be empty", toastType: .red)
            return
        }
        
        if !self.replyingToLbl.text!.isEmpty { // If Replying, editing comment or editing reply.
            
            if let postingState = self.replyingToLbl.accessibilityElements?[0] as? String {
                
                if let commentId = self.replyingToLbl.accessibilityElements?[1] as? Int {
                    
                    if postingState == "replying" {
                        
                        self.replyingToCloseBtn.isEnabled = false
                        self.postBtn.showLoading()
                        self.addCommentTxtView.isUserInteractionEnabled = false
                        
                        let sourceType = 0 // Reply of comment
                        self.saveCommentReply(sourceType: sourceType, commentId: commentId)
                    }
                    else if postingState == "editingComment" {
                        
                        guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
                            return
                        }
                        
                        self.editComment(commentId: commentId, originalComment: self.commentNReplyList[commentIndex].comment.comment!)

                        self.commentNReplyList[commentIndex].comment.comment = Utils.decodeUTF(self.addCommentTxtView.text!)
                        self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
                        
                        self.replyingToLbl.accessibilityElements = nil
                        self.replyingToCloseBtn.isHidden = true
                        self.replyingToLbl.text = ""
                        self.addCommentTxtView.text = ""
//                        self.scrollToCell(section: commentIndex, row: NSNotFound)
                    }
                    else if postingState == "editingReply" {
                        if let replyId = self.replyingToLbl.accessibilityElements?[2] as? Int {

                            guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
                                return
                            }
                            guard let replyIndex = self.searchNGetIndexOfReplyIfExist(commentIndex: commentIndex, replyId: replyId) else {
                                return
                            }
                            
                            self.editReply(commentId: commentId, replyId: replyId, originalReply: self.commentNReplyList[commentIndex].replies[replyIndex].reply.comment!)
                            
                            self.commentNReplyList[commentIndex].replies[replyIndex].reply.comment = Utils.decodeUTF(self.addCommentTxtView.text!)
                            self.tableView.reloadRows(at: [IndexPath(row: replyIndex, section: commentIndex)], with: .automatic)
                            
                            self.replyingToLbl.accessibilityElements = nil
                            self.replyingToLbl.text = ""
                            self.addCommentTxtView.text = ""
                            
                            self.scrollToCell(section: commentIndex, row: replyIndex)
                        }
                    }
                }
            }
        }
        else { // If posting comment.
            
            self.replyingToCloseBtn.isEnabled = false
            self.postBtn.showLoading()
            self.addCommentTxtView.isUserInteractionEnabled = false
            
            let commentId = 0
            let sourceType = 1 // Reply of Post
            self.saveCommentReply(sourceType: sourceType, commentId: commentId)
        }
    }
}

// MARK: - TableView Configuration
extension CommentsVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return commentNReplyList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentNReplyList[section].replies.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "CommentsHeaderView") as? CommentsHeaderView else {
            return UIView()
        }

        header.connectionLine.isHidden = self.commentNReplyList[section].replies.count > 0 ? false : true
        
        header.configureHeader(info: commentNReplyList[section].comment)
        
        header.likeBtn.tag = section
        header.likeBtn.addTarget(self, action: #selector(likeCommentBtnTapped(_:)), for: .touchUpInside)
        
        header.replyBtn.tag = section
        header.replyBtn.addTarget(self, action: #selector(replyBtnTapped(_:)), for: .touchUpInside)
        
        header.repliesCountBtn.tag = section
        header.repliesCountBtn.addTarget(self, action: #selector(replyCountBtnTapped(_:)), for: .touchUpInside)
        
        header.moreBtn.tag = section
        header.moreBtn.addTarget(self, action: #selector(moreCommentBtnTapped(_:)), for: .touchUpInside)
        
        header.profilePicBtn.tag = section
        header.profilePicBtn.addTarget(self, action: #selector(self.profileIconCommentTapped(_:)), for: .touchUpInside)
        
        return header
    }
    
    @objc func profileIconCommentTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            vc.profileIdentifier = self.commentNReplyList[sender.tag].comment.userIdentifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if commentNReplyList[section].isDeleted {
            return 0.0 // deleted
        }
        else {
            return tableView.sectionHeaderHeight
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {

        if section == self.commentNReplyList.count - 10 && self.commentNReplyList.count < self.viewModel.commentListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.getCommentList()
        }
    }
    
    @objc func likeCommentBtnTapped(_ sender: UIButton) {

        guard
            let commentId = self.commentNReplyList[sender.tag].comment.id,
            let _ = self.commentNReplyList[sender.tag].comment.isLiked,
            let _ = self.commentNReplyList[sender.tag].comment.likeCount
        else {
            return
        }
        
        self.commentNReplyList[sender.tag].comment.isLiked = !self.commentNReplyList[sender.tag].comment.isLiked!
        self.commentNReplyList[sender.tag].comment.likeCount! += self.commentNReplyList[sender.tag].comment.isLiked! ? 1 : -1
        self.commentNReplyList[sender.tag].comment.isLikeBtnEnabled = false
        
        if let header = self.tableView.headerView(forSection: sender.tag) as? CommentsHeaderView {
            
            if let isLiked = self.commentNReplyList[sender.tag].comment.isLiked {
                header.likeBtn.isSelected = isLiked
                
                if !isLiked {
                    header.likeBtn.setImage(UIImage(named: "heartIcon"), for: [.disabled, .normal])
                    header.likeBtn.setTitle(" Like", for: [.disabled, .normal])
                    header.likeBtn.setTitleColor(UIColor.systemGray4, for: [.disabled, .normal])
                } else {
                    header.likeBtn.setImage(UIImage(named: "heartFillIcon"), for: [.disabled, .selected])
                    header.likeBtn.setTitle(" Like", for: [.disabled, .selected])
                    header.likeBtn.setTitleColor(UIColor.systemGray4, for: [.disabled, .selected])
                }
            }
            
            header.likeBtn.isEnabled = false
//            header.likeBtn.isSelected = self.commentNReplyList[sender.tag].comment.isLiked!
            header.likesCountLbl.text = "\(self.commentNReplyList[sender.tag].comment.likeCount!) Likes"
        }
        /*
         sourceType = 0 => Comment
         sourceType = 1 => Main Post
         sourceType = 2 => Reply
         */
        self.likeCommentReply(sourceId: commentId, sourceType: 0, object: self.commentNReplyList[sender.tag].comment, replyId: -1) // -1 = irrelevant
    }
    
    @objc func moreCommentBtnTapped(_ sender: UIButton) {
        
        guard let isMyComment = self.commentNReplyList[sender.tag].comment.isMyComment else {
            return
        }
        
        var moreBtnActions: [(String, UIAlertAction.Style)] = [
            ("Cancel", UIAlertAction.Style.cancel)
        ]
        
        if isMyComment {
            moreBtnActions.insert(("Delete", UIAlertAction.Style.destructive), at: 0)
            moreBtnActions.insert(("Edit", UIAlertAction.Style.default), at: 0)
        }
        else {
            moreBtnActions.insert(("Report", UIAlertAction.Style.destructive), at: 0)
        }
        
        Alert.sharedInstance.showActionsheet(vc: self, title: "Manage Comment", message: "What do want to do?", actions: moreBtnActions) { _, title in
            
            switch title {
                
            case "Delete":
                
                Alert.sharedInstance.alertWindow(title: "Warning", message: "Are you sure you want to delete this Comment?") { result in
                    
                    if result {
                        
                        guard let commentId = self.commentNReplyList[sender.tag].comment.id else {
                            return
                        }
                        /*
                         Clear Reply fields when deleting
                         any Comment.
                         */
                        self.replyingToLbl.text = ""
                        self.accessibilityElements = nil
                        self.replyingToCloseBtn.isHidden = true
                        self.addCommentTxtView.text = ""
                        
                        self.deleteComment(commentId: commentId, object: self.commentNReplyList[sender.tag].comment)
                        
                        self.commentNReplyList[sender.tag].isDeleted = true
                        
                        for i in stride(from: 0, to: self.commentNReplyList[sender.tag].replies.count, by: 1) {
                            self.commentNReplyList[sender.tag].replies[i].isDeleted = true
                        }
                        self.tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
                        self.tableView.layoutSubviews()
                        self.checkIfCommentListIsEmpty() ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                    }
                }
                
                break
                
            case "Edit":
                
                guard let commentId = self.commentNReplyList[sender.tag].comment.id else {
                    return
                }
                self.replyingToCloseBtn.isHidden = false
                self.replyingToLbl.text = "Editing Comment"
                self.replyingToLbl.accessibilityElements = ["editingComment", commentId, -1, self.commentNReplyList[sender.tag].comment]
                self.addCommentTxtView.text = Utils.decodeUTF(self.commentNReplyList[sender.tag].comment.comment ?? "")
                
                print("Edit the Comment")
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
                    vc.sourceType = 0
                    vc.sourceId = self.commentNReplyList[sender.tag].comment.id
                    self.present(vc, animated: true)
                }
                
                print("Report the comment")
                break
                
            default :
                print("Default switch case")
            }
        }
    }
    
    // MARK: - Reply Button Tapped
    @objc func replyBtnTapped(_ sender: UIButton) {
        /*
         This functionality will add a reply cell to the section and scroll to that reply cell.
         */
        if self.isReplyCellHidden(index: sender.tag) {
            self.addReplyCell(index: sender.tag)
            self.tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
        }
        self.scrollToCell(section: sender.tag, row: self.commentNReplyList[sender.tag].replies.count - 1)
    }
    
    func isReplyCellHidden(index: Int) -> Bool {
        
        if self.commentNReplyList[index].replies.isEmpty {
            return true
        }
        return self.commentNReplyList[index].replies[self.commentNReplyList[index].replies.count - 1].reply.id == nil ? false : true
    }
    
    // MARK: - Check if comment list is empty because we are hiding the comment on delete action
    func checkIfCommentListIsEmpty() -> Bool {
        let undeletedPost = self.commentNReplyList.filter { !($0.isDeleted) }
        return undeletedPost.count > 0 ? false : true
    }
    
    // MARK: - Get Actual Comment Count because we are hiding the comment on delete action
    func getActualCommentCount() -> Int {
        let undeletedPost = self.commentNReplyList.filter { !($0.isDeleted) }
        return undeletedPost.count
    }
    
    func addReplyCell(index: Int) {
        self.commentNReplyList[index].replies.append(ReplyDM(reply: ComRepDM(firstName: nil, id: nil, isLiked: nil, sourceType: nil, lastName: nil, commentID: nil, displayImageURL: nil, comment: nil, createdBy: nil, isActive: nil, isMyComment: nil, userIdentifier: nil, modifiedOn: nil, replyCount: nil, durationAgo: nil, recordCount: nil, postID: nil, likeCount: nil, createdOn: nil, isAccountVerified: nil)))
    }
    
//    func removeReplyCell(index: Int) {
//        self.commentNReplyList[index].replies.remove(at: self.commentNReplyList[index].replies.count - 1) // Comment this if you don't want to hide the reply cell on second tap
//    }
    
    func scrollToCell(section: Int, row: Int) {
        
        DispatchQueue.main.async {
            let indexPath = IndexPath(row: row, section: section)
            self.tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        }
    }
    
//    fileprivate func removeAllFetchedReplies(_ sender: LoadingButton) {
//        let isReplyCellHidden = self.isReplyCellHidden(index: sender.tag)
//        self.commentNReplyList[sender.tag].replies.removeAll()
//        isReplyCellHidden ? () : self.addReplyCell(index: sender.tag)
//        self.tableView.reloadSections(IndexSet(integer: sender.tag), with: .automatic)
//    }
    
    
    @objc func replyCountBtnTapped(_ sender: LoadingButton) {
        
        if self.commentNReplyList[sender.tag].comment.replyCount == 0 {
            return
        }
        guard let commentId = self.commentNReplyList[sender.tag].comment.id else {
            return
        }
        
        sender.showLoading()
        self.getReplyList(commentId: commentId)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == self.commentNReplyList[indexPath.section].replies.count - 1 && !self.isReplyCellHidden(index: indexPath.section) {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentsCell") as? AddCommentsCell else {
                return UITableViewCell()
            }
            cell.configureCell()
            cell.writeReplyBtn.tag = indexPath.section
            cell.writeReplyBtn.addTarget(self, action: #selector(replyCellTapped(_:)), for: .touchUpInside)
            cell.profilePicBtn.addTarget(self, action: #selector(profilePicAddReplyTapped), for: .touchUpInside)
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentsCell") as? CommentsCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(info: commentNReplyList[indexPath.section].replies[indexPath.row].reply)
        
        cell.hideLine(((self.isReplyCellHidden(index: indexPath.section)) && (self.commentNReplyList[indexPath.section].replies.count - 1 == indexPath.row)) ? true : false)
        
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(likeReplyBtnTapped(_:)), for: .touchUpInside)
        cell.likeBtn.accessibilityValue = "\(indexPath.section)"
        
        cell.replyBtn.tag = indexPath.section
        cell.replyBtn.addTarget(self, action: #selector(replyBtnTapped(_:)), for: .touchUpInside)
        
        cell.moreBtn.tag = indexPath.row
        cell.moreBtn.accessibilityValue = "\(indexPath.section)"
        cell.moreBtn.addTarget(self, action: #selector(moreReplyBtnTapped(_:)), for: .touchUpInside)
        
        cell.profilePicBtn.tag = indexPath.row
        cell.profilePicBtn.accessibilityValue = "\(indexPath.section)"
        cell.profilePicBtn.addTarget(self, action: #selector(self.profileIconReplyTapped(_:)), for: .touchUpInside)
        
        cell.clipsToBounds = true
        
        return cell
    }
    
    @objc func profilePicAddReplyTapped() {

        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            vc.profileIdentifier = PreferencesManager.getUserModel()?.identifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func profileIconReplyTapped(_ sender: UIButton) {
        
        let section = Int(sender.accessibilityValue!)!
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            vc.profileIdentifier = self.commentNReplyList[section].replies[sender.tag].reply.userIdentifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if !(commentNReplyList[indexPath.section].replies[indexPath.row].isDeleted) {
            return tableView.rowHeight
        }
        return 0
    }
    
    @objc func replyCellTapped(_ sender: UIButton) {
        
        guard let commentId = commentNReplyList[sender.tag].comment.id else {
            return
        }
        
        self.replyingToCloseBtn.isHidden = false
        self.replyingToLbl.text = "Replying to \(commentNReplyList[sender.tag].comment.firstName?.capitalized ?? "") \(commentNReplyList[sender.tag].comment.lastName?.capitalized ?? "")"
        self.replyingToLbl.accessibilityElements = ["replying", commentId]
        self.addCommentTxtView.becomeFirstResponder()
    }
    
    @objc func likeReplyBtnTapped(_ sender: UIButton) {
        
        let section = Int(sender.accessibilityValue!)!
        
        guard
            let replyId = self.commentNReplyList[section].replies[sender.tag].reply.id,
            let _ = self.commentNReplyList[section].replies[sender.tag].reply.isLiked,
            let _ = self.commentNReplyList[section].replies[sender.tag].reply.likeCount
        else {
            return
        }
        
        self.commentNReplyList[section].replies[sender.tag].reply.isLiked = !self.commentNReplyList[section].replies[sender.tag].reply.isLiked!
        self.commentNReplyList[section].replies[sender.tag].reply.likeCount! += self.commentNReplyList[section].replies[sender.tag].reply.isLiked! ? 1 : -1
        self.commentNReplyList[section].replies[sender.tag].reply.isLikeBtnEnabled = false
        
        if let cell = self.tableView.cellForRow(at: IndexPath(row: sender.tag, section: section)) as? CommentsCell {
//            cell.likeBtn.isSelected = self.commentNReplyList[section].replies[sender.tag].reply.isLiked!
            
            if let isLiked = self.commentNReplyList[section].replies[sender.tag].reply.isLiked {
                cell.likeBtn.isSelected = isLiked
                
                if !isLiked {
                    cell.likeBtn.setImage(UIImage(named: "heartIcon"), for: [.disabled, .normal])
                    cell.likeBtn.setTitle(" Like", for: [.disabled, .normal])
                    cell.likeBtn.setTitleColor(UIColor.systemGray4, for: [.normal, .disabled])
                } else {
                    cell.likeBtn.setImage(UIImage(named: "heartFillIcon"), for: [.disabled, .selected])
                    cell.likeBtn.setTitle(" Like", for: [.disabled, .selected])
                    cell.likeBtn.setTitleColor(UIColor.systemGray4, for: [.disabled, .selected])
                }
            }
            
            cell.likesCountLbl.text = "\(self.commentNReplyList[section].replies[sender.tag].reply.likeCount!) Likes"
            cell.likeBtn.isEnabled = false
            
        }
        /*
         sourceType = 0 => Comment
         sourceType = 1 => Main Post
         sourceType = 2 => Reply
         */
        self.likeCommentReply(sourceId: replyId, sourceType: 2, object: self.commentNReplyList[section].comment, replyId: replyId)
    }
    
    @objc func moreReplyBtnTapped(_ sender: UIButton) {
        
        let section = Int(sender.accessibilityValue!)!
        
        guard let isMyReply = self.commentNReplyList[section].replies[sender.tag].reply.isMyComment else {
            return
        }
        
        var moreBtnActions: [(String, UIAlertAction.Style)] = [
            ("Cancel", UIAlertAction.Style.cancel)
        ]
        
        if isMyReply {
            moreBtnActions.insert(("Delete", UIAlertAction.Style.destructive), at: 0)
            moreBtnActions.insert(("Edit", UIAlertAction.Style.default), at: 0)
            
        } else {
            moreBtnActions.insert(("Report", UIAlertAction.Style.destructive), at: 0)
        }
        
        Alert.sharedInstance.showActionsheet(vc: self, title: "Manage Reply", message: "What do want to do?", actions: moreBtnActions) { _, title in
            
            switch title {
                
            case "Delete":
                
                Alert.sharedInstance.alertWindow(title: "Warning", message: "Are you sure you want to delete this Reply?") { result in
                    
                    if result {
                        
                        guard let replyId = self.commentNReplyList[section].replies[sender.tag].reply.id else {
                            return
                        }
                        /*
                         Clear Reply fields when deleting
                         any Reply.
                         */
                        self.replyingToLbl.text = ""
                        self.accessibilityElements = nil
                        self.replyingToCloseBtn.isHidden = true
                        self.addCommentTxtView.text = ""
                        
                        self.deleteReply(replyId: replyId, object: self.commentNReplyList[section])
                        self.commentNReplyList[section].replies[sender.tag].isDeleted = true
                        self.commentNReplyList[section].comment.replyCount! -= 1
                        self.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
//                        self.tableView.reloadRows(at: [IndexPath(row: sender.tag, section: section)], with: .automatic)
                        self.scrollToCell(section: section, row: sender.tag)
                        print("Delete the Reply")
                    }
                }
                break
                
            case "Edit":
                
                guard
                    let commentId = self.commentNReplyList[section].comment.id,
                    let replyId = self.commentNReplyList[section].replies[sender.tag].reply.id
                else {
                    return
                }
                self.replyingToCloseBtn.isHidden = false
                self.replyingToLbl.text = "Editing Reply"
                self.replyingToLbl.accessibilityElements = ["editingReply", commentId, replyId, self.commentNReplyList[section].replies[sender.tag]]
                self.addCommentTxtView.text = Utils.decodeUTF(self.commentNReplyList[section].replies[sender.tag].reply.comment ?? "")
                
                print("Edit the Reply")
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
                    vc.sourceType = 2
                    vc.sourceId = self.commentNReplyList[section].replies[sender.tag].reply.id
                    self.present(vc, animated: true)
                }
                print("Report the Reply")
                    break
                
            case "Hide":
                print("Hide the Reply")
                
            default:
                print("Default switch case")
                break
                
            }
        }
    }
}

extension CommentsVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        //        scrollViewScrollToBottom(scrollView)
        
        if textView.text == "Write a comment" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            textView.text = "Write a comment"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count <= 255 {
            return true
        }
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        
        if textView.text.count == 0 || textView.text == "Write a comment" {
            self.postBtn.isEnabled = false
        }  else {
            self.postBtn.isEnabled = true
        }
        
        if validate(textView: textView) {
            self.addCommentTxtView.isScrollEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        let text = textView.text.replacingOccurrences(of: "\n", with: "")
        textView.text = text
        
        if textView.text.count < 2 {
            self.addCommentTxtView.updateConstraints()
            print("\nUpdate constraint called\n")
        }
        postBtn.isEnabled = textView.text.count == 0 ? false : true
        scrollViewScrollToBottom(scrollView)
        
        let numberOfLines = textView.layoutManager.numberOfLines
        
        if numberOfLines >= 3 {
            addCommentTxtView.isScrollEnabled = true
        } else {
            addCommentTxtView.isScrollEnabled = false
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

extension CommentsVC: NetworkResponseProtocols {
    
    // MARK: - Post Detail Response
    func didGetPostList() {
        
        self.hideLoader()
        
        if let postDetail = self.viewModel.postListResponse?.data?.first {
            self.postDetail = postDetail
            self.showLoader()
            self.getCommentList()
            
        } else {
            Alert.sharedInstance.alertOkWindow(title: "Error", message: self.viewModel.postListResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Comment List Response
    func didGetCommentList() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.commentListResponse?.data {
            
            self.pageNumber == 1 ? self.commentNReplyList.removeAll() : ()
            
            for comment in unwrappedList {
                self.commentNReplyList.append(CommentReplyDM(comment: comment))
            }
            
            self.tableView.reloadData()
            
            self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            
        } else {
            
            self.checkIfPostExistsOnServer { isSuccess in
                if isSuccess {
                    self.showToast(message: self.viewModel.commentListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
                    self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                }
            }
        }
    }
    
    // MARK: - Save Comment and Save Reply Response
    func didSaveCommentReply() {
        
        self.replyingToCloseBtn.isEnabled = true
        self.addCommentTxtView.isUserInteractionEnabled = true
        self.postBtn.hideLoading()
        
        if self.viewModel.saveCommentReplyResponse?.isSuccess ?? false {
            
            if self.replyingToLbl.accessibilityElements?[0] != nil { // replying to a comment
                
                guard let commentId = self.replyingToLbl.accessibilityElements?[1] as? Int else {
                    return
                }
                
                if (self.tableView.refreshControl?.isRefreshing ?? true) == false {
                    
                    guard let replyId = self.viewModel.saveCommentReplyResponse?.data?.commentID else {
                        return
                    }
                    
                    self.addReplyInList(commentId: commentId, replyId: replyId)
                    self.showToast(message: self.viewModel.saveCommentReplyResponse?.message ?? "Some error occured", toastType: .green)
                }
            }
            else { // commenting to a post
                
                if (self.tableView.refreshControl?.isRefreshing ?? true) == false {
                    
                    guard let commentId = self.viewModel.saveCommentReplyResponse?.data?.commentID else {
                        return
                    }
                    self.addCommentInList(commentId: commentId)
                    if let postIndex {
                        self.delegate?.updateCommentCount(postIndex: postIndex, increment: 1)
                    }
                    self.showToast(message: self.viewModel.saveCommentReplyResponse?.message ?? "Some error occured", toastType: .green)
                    self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                }
            }
            self.replyingToLbl.text = ""
            self.replyingToLbl.accessibilityElements = nil
            self.replyingToCloseBtn.isHidden = true
            DispatchQueue.main.async {
                self.addCommentTxtView.text = ""
                self.addCommentTxtView.isScrollEnabled = false
                self.addCommentTxtView.updateConstraints()
                self.textViewDidChange(self.addCommentTxtView)
            }
        }
        else {
            
            if self.replyingToLbl.accessibilityElements?[0] != nil { // replying to a comment
                
                guard let commentId = self.replyingToLbl.accessibilityElements?[1] as? Int else {
                    return
                }
                guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
                    return
                }
                
                self.checkIfCommentExistsOnServer(commentId: commentId) { isSuccess in
                    if isSuccess {
                        self.showToast(message: self.viewModel.saveCommentReplyResponse?.message ?? "Some error occured", toastType: .red)
                    }
                    else {
                        self.checkIfPostExistsOnServer { isSuccess in
                            if isSuccess {
                                self.commentNReplyList[commentIndex].isDeleted = true
                                self.tableView.reloadSections(IndexSet(integer: commentIndex) , with: .automatic)
                                self.checkIfCommentListIsEmpty() ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                                self.showToast(message: "The Comment for this Reply was Removed", delay: 2, toastType: .red)
                                self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                            }
                        }
                    }
                }
            }
            
            else { // commenting to a post
                self.checkIfPostExistsOnServer { isSuccess in
                    if isSuccess {
                        self.showToast(message: self.viewModel.saveCommentReplyResponse?.message ?? "Some error occured", toastType: .red)
                        self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                    }
                }
            }
        }
    }
    
    // MARK: - Add Newly Added Reply to the List
    func addReplyInList(commentId: Int, replyId: Int) {
        
        guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else { // get comment index based on comment id
            return
        }
        
        self.commentNReplyList[commentIndex].comment.replyCount! += 1
        
        guard let userModel = PreferencesManager.getUserModel() else { // get user details
            return
        }

        /*
         sourceType = 0 => Comment
         sourceType = 1 => Main Post
         sourceType = 2 => Reply
         */
        self.commentNReplyList[commentIndex].replies.insert(ReplyDM(reply: ComRepDM(firstName: userModel.firstName, id: replyId, isLiked: false, sourceType: 2, lastName: userModel.lastName, commentID: 0, displayImageURL: userModel.displayImageURL, comment: Utils.encodeUTF(self.addCommentTxtView.text!), createdBy: userModel.id, isActive: true, isMyComment: true, userIdentifier: userModel.identifier, modifiedOn: Utils.getCurrentDateTime(), replyCount: 0, durationAgo: "now", recordCount: 0, postID: self.postDetail?.id, likeCount: 0, createdOn: Utils.getCurrentDateTime(), isAccountVerified: PreferencesManager.getUserModel()?.isAccountVerified)), at: 0)
        
        self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
        
        self.scrollToCell(section: commentIndex, row: 0)
    }
    
    // MARK: - Add Newly Added Reply to Top of List
    func addCommentInList(commentId: Int) {
        
        guard let userModel = PreferencesManager.getUserModel() else { // get user details
            return
        }
        /*
         sourceType = 0 => Comment
         sourceType = 1 => Main Post
         sourceType = 2 => Reply
         */
        
        self.commentNReplyList.insert(CommentReplyDM(comment: ComRepDM(firstName: userModel.firstName, id: commentId, isLiked: false, sourceType: 0, lastName: userModel.lastName, commentID: 0, displayImageURL: userModel.displayImageURL, comment: Utils.encodeUTF(self.addCommentTxtView.text!), createdBy: userModel.id, isActive: true, isMyComment: true, userIdentifier: userModel.identifier, modifiedOn: Utils.getCurrentDateTime(), replyCount: 0, durationAgo: "now", recordCount: 0, postID: self.postDetail?.id, likeCount: 0, createdOn: Utils.getCurrentDateTime(), isAccountVerified: PreferencesManager.getUserModel()?.isAccountVerified)), at: 0)
        
        self.tableView.reloadData()
    }
    
    // MARK: - Reply List Response
    func didGetReplyList(commentId: Int) {
        
        guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
            return
        }
        
        if let unwrappedList = self.viewModel.replyListResponse?.data {
            
            if let headerView = tableView.headerView(forSection: commentIndex) as? CommentsHeaderView {
                headerView.repliesCountBtn.hideLoading()
            }
            
            self.commentNReplyList[commentIndex].replies.removeAll()
            
            for reply in unwrappedList {
                self.commentNReplyList[commentIndex].replies.append(ReplyDM(reply: reply))
            }
            
            self.commentNReplyList[commentIndex].comment.replyCount = unwrappedList.count
            
            self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
            
            if self.isReplyCellHidden(index: commentIndex) {
                self.addReplyCell(index: commentIndex)
                self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
            }
            
            self.scrollToCell(section: commentIndex, row: 0)
            
        } else {
            
            self.checkIfCommentExistsOnServer(commentId: commentId) { isSuccess in
                if isSuccess {
                    self.showToast(message: self.viewModel.replyListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
                }
                else {
                    self.checkIfPostExistsOnServer { isSuccess in
                        if isSuccess {
                            self.commentNReplyList[commentIndex].isDeleted = true
                            self.tableView.reloadSections(IndexSet(integer: commentIndex) , with: .automatic)
                            self.showToast(message: "The Comment for this Reply was Removed", delay: 2, toastType: .red)
                            self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Comment Response
    func didDeleteComment(commentId: Int) {
        
        if self.viewModel.deleteCommentResponse?.isSuccess ?? false {
            
            if let postIndex {
                self.delegate?.updateCommentCount(postIndex: postIndex, increment: -1)
            }
            self.showToast(message: self.viewModel.deleteCommentResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            
//            guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
//                return
//            }
//            if let header = self.tableView.headerView(forSection: commentIndex) as? CommentsHeaderView {
//                header.
//            }
//            self.commentNReplyList.remove(at: commentIndex)
//            self.tableView.deleteSections(IndexSet(integer: commentIndex), with: .automatic)
//            self.tableView.reloadData()
        }
        
        else {
            
            self.tableView.restore()
            
            guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
                return
            }
            
            self.checkIfCommentExistsOnServer(commentId: commentId) { isSuccess in
                
                if isSuccess {
                    
                    self.commentNReplyList[commentIndex].isDeleted = false
                    for i in stride(from: 0, to: self.commentNReplyList[commentIndex].replies.count, by: 1) {
                        self.commentNReplyList[commentIndex].replies[i].isDeleted = false
                    }
                    self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
                    self.showToast(message: self.viewModel.deleteCommentResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
                }
                else {
                    self.checkIfPostExistsOnServer { isSuccess in
                        if isSuccess {
                            self.commentNReplyList[commentIndex].isDeleted = true
                            self.tableView.reloadSections(IndexSet(integer: commentIndex) , with: .automatic)
                            self.showToast(message: "This Comment was already Removed", delay: 2, toastType: .red)
                            self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Delete Reply Response
    func didDeleteReply(replyId: Int, object: AnyObject) {
        
        if self.viewModel.deleteReplyResponse?.isSuccess ?? false {
            
            self.showToast(message: self.viewModel.deleteReplyResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        }
        else {
            
            guard let commentId = (object as! CommentReplyDM).comment.id else {
                return
            }
            
            guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
                return
            }
            guard let replyIndex = self.searchNGetIndexOfReplyIfExist(commentIndex: commentIndex, replyId: replyId) else {
                return
            }
            
            self.checkIfReplyExistOnServer(commentId: commentId, replyId: replyId) { isSuccess in
                if isSuccess {
                    self.commentNReplyList[commentIndex].replies[replyIndex].isDeleted = false
                    self.tableView.reloadRows(at: [IndexPath(row: replyIndex, section: commentIndex)], with: .automatic)
                    self.showToast(message: self.viewModel.deleteReplyResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
                    self.commentNReplyList[commentIndex].comment.replyCount! += 1
                }
                else {
                    self.checkIfCommentExistsOnServer(commentId: commentId) { isSuccess in
                        if isSuccess {
                            self.commentNReplyList[commentIndex].replies[replyIndex].isDeleted = true
                            self.tableView.reloadRows(at: [IndexPath(row: replyIndex, section: commentIndex)], with: .automatic)
                            self.showToast(message: "This Reply was already Removed", delay: 2, toastType: .red)
                        }
                        else {
                            self.checkIfPostExistsOnServer { isSuccess in
                                if isSuccess {
                                    self.commentNReplyList[commentIndex].isDeleted = true
                                    self.tableView.reloadSections(IndexSet(integer: commentIndex) , with: .automatic)
                                    self.showToast(message: "The Comment for this Reply was Removed", delay: 2, toastType: .red)
                                    self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func didEditComment(commentId: Int, originalComment: String) {
        
        guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
            return
        }
        
        if self.viewModel.editCommentResponse?.isSuccess ?? false {
            
            self.commentNReplyList[commentIndex].comment.likeCount = self.viewModel.editCommentResponse?.data?.likeCount ?? 0
            self.commentNReplyList[commentIndex].comment.replyCount = self.viewModel.editCommentResponse?.data?.replyCount ?? 0
            
            self.showToast(message: self.viewModel.editCommentResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        }
        else {
            
            self.checkIfCommentExistsOnServer(commentId: commentId) { isSuccess in
                if isSuccess {
                    self.commentNReplyList[commentIndex].comment.comment = Utils.decodeUTF(originalComment)
                    self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
                    self.showToast(message: self.viewModel.editCommentResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
                }
                else {
                    self.checkIfPostExistsOnServer { isSuccess in
                        if isSuccess {
                            self.commentNReplyList[commentIndex].isDeleted = true
                            self.tableView.reloadSections(IndexSet(integer: commentIndex) , with: .automatic)
                            self.showToast(message: "This Comment was Removed", delay: 2, toastType: .red)
                            self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                        }
                    }
                }
            }
        }
    }
    
    func didEditReply(commentId: Int, replyId: Int, originalReply: String) {
        
        guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
            return
        }
        guard let replyIndex = self.searchNGetIndexOfReplyIfExist(commentIndex: commentIndex, replyId: replyId) else {
            return
        }
        
        if self.viewModel.editReplyResponse?.isSuccess ?? false {
            
            self.commentNReplyList[commentIndex].comment.likeCount = self.viewModel.editReplyResponse?.data?.commentLikeCount ?? 0
            self.commentNReplyList[commentIndex].comment.replyCount = self.viewModel.editReplyResponse?.data?.commentReplyCount ?? 0
            self.commentNReplyList[commentIndex].replies[replyIndex].reply.likeCount = self.viewModel.editReplyResponse?.data?.sourceLikeCount ?? 0
            
            self.showToast(message: self.viewModel.editReplyResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        }
        else {
            
            self.checkIfReplyExistOnServer(commentId: commentId, replyId: replyId) { isSuccess in
                if isSuccess {
                    self.commentNReplyList[commentIndex].comment.comment = Utils.decodeUTF(originalReply)
                    self.tableView.reloadRows(at: [IndexPath(row: replyIndex, section: commentIndex)], with: .automatic)
                    self.showToast(message: self.viewModel.editCommentResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
                }
                else {
                    self.checkIfCommentExistsOnServer(commentId: commentId) { isSuccess in
                        if isSuccess {
                            self.commentNReplyList[commentIndex].replies[replyIndex].isDeleted = true
                            self.tableView.reloadRows(at: [IndexPath(row: replyIndex, section: commentIndex)], with: .automatic)
                            self.showToast(message: "This Reply was Removed", delay: 2, toastType: .red)
                        }
                        else {
                            self.checkIfPostExistsOnServer { isSuccess in
                                if isSuccess {
                                    self.commentNReplyList[commentIndex].isDeleted = true
                                    self.tableView.reloadSections(IndexSet(integer: commentIndex) , with: .automatic)
                                    self.showToast(message: "The Comment for this Reply was Removed", delay: 2, toastType: .red)
                                    self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func didSaveLike(object: AnyObject, sourceType: Int, replyId: Int) { // reply id will only be used when a reply is liked
        
        let commentId = (object as! ComRepDM).id!
        
        guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
            return
        }
        /*
         sourceType = 0 => Comment
         sourceType = 1 => Main Post
         sourceType = 2 => Reply
         */
        if self.viewModel.saveLikeResponse?.isSuccess ?? false {
            
            self.commentNReplyList[commentIndex].comment.replyCount = self.viewModel.saveLikeResponse?.data?.commentReplyCount ?? 0
            
            if sourceType == 2 { // reply
            
                guard let replyIndex = self.searchNGetIndexOfReplyIfExist(commentIndex: commentIndex, replyId: replyId) else {
                    return
                }
                
                self.commentNReplyList[commentIndex].replies[replyIndex].reply.isLikeBtnEnabled = true
                self.commentNReplyList[commentIndex].replies[replyIndex].reply.likeCount = self.viewModel.saveLikeResponse?.data?.sourceLikeCount ?? 0
                self.commentNReplyList[commentIndex].comment.likeCount = self.viewModel.saveLikeResponse?.data?.commentLikeCount ?? 0
                
                if let cell = self.tableView.cellForRow(at: IndexPath(row: replyIndex, section: commentIndex)) as? CommentsCell {
                    cell.likeBtn.isEnabled = true
                    cell.likesCountLbl.text = "\(self.commentNReplyList[commentIndex].replies[replyIndex].reply.likeCount ?? 0) Likes"
                }
                if let header = self.tableView.headerView(forSection: commentIndex) as? CommentsHeaderView {
                    header.likesCountLbl.text = "\(self.commentNReplyList[commentIndex].comment.likeCount ?? 0) Likes"
                }
                
            }
            else {
                
                self.commentNReplyList[commentIndex].comment.isLikeBtnEnabled = true
                self.commentNReplyList[commentIndex].comment.likeCount = self.viewModel.saveLikeResponse?.data?.sourceLikeCount ?? 0
                
                if let header = self.tableView.headerView(forSection: commentIndex) as? CommentsHeaderView {
                    header.likeBtn.isEnabled = true
                    header.likesCountLbl.text = "\(self.commentNReplyList[commentIndex].comment.likeCount ?? 0) Likes"
                }
                
            }
//            self.showToast(message: self.viewModel.saveLikeResponse?.message ?? "Some error occured", toastType: .green)
        }
        else {
            
            if sourceType == 0 { // comment
                
                self.commentNReplyList[commentIndex].comment.isLikeBtnEnabled = true

                self.checkIfCommentExistsOnServer(commentId: commentId) { isSuccess in
                    
                    if isSuccess {
                        
                        self.showToast(message: self.viewModel.saveLikeResponse?.message ?? "Some error occured", toastType: .red)
                        
                        self.commentNReplyList[commentIndex].comment.isLiked = !self.commentNReplyList[commentIndex].comment.isLiked!
                        self.commentNReplyList[commentIndex].comment.likeCount! += self.commentNReplyList[commentIndex].comment.isLiked! ? 1 : -1
                        self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
                        
                    }
                    else {
                        self.checkIfPostExistsOnServer { isSuccess in
                            
                            if isSuccess {
                                
                                self.showToast(message: "This Comment was Removed", toastType: .red)
                                
                                self.commentNReplyList[commentIndex].isDeleted = true
                                self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
                                self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                            }
                        }
                    }
                }
            }
            else if sourceType == 2 { // reply
                
                self.checkIfReplyExistOnServer(commentId: commentId, replyId: replyId) { isSuccess in
                    
                    if isSuccess {
                        
                        guard let replyIndex = self.searchNGetIndexOfReplyIfExist(commentIndex: commentIndex, replyId: replyId) else {
                            return
                        }
                        
                        self.commentNReplyList[commentIndex].replies[replyIndex].reply.isLikeBtnEnabled = true
                        
                        self.showToast(message: self.viewModel.saveLikeResponse?.message ?? "Some error occured", toastType: .red)
                        
                        self.commentNReplyList[commentIndex].replies[replyIndex].reply.isLiked = !self.commentNReplyList[commentIndex].replies[replyIndex].reply.isLiked!
                        self.commentNReplyList[commentIndex].replies[replyIndex].reply.likeCount! += self.commentNReplyList[commentIndex].replies[replyIndex].reply.isLiked! ? 1 : -1
                        self.tableView.reloadRows(at: [IndexPath(row: replyIndex, section: commentIndex)], with: .automatic)
                        
                    }
                    else {
                        self.checkIfCommentExistsOnServer(commentId: commentId) { isSuccess in
                            
                            if isSuccess {
                                
                                self.showToast(message: "This Reply was Removed", toastType: .red)
                                
                                guard let replyIndex = self.searchNGetIndexOfReplyIfExist(commentIndex: commentIndex, replyId: replyId) else {
                                    return
                                }
//                                self.commentNReplyList[commentIndex].replies[replyIndex].reply.isLikeBtnEnabled = true
                                self.commentNReplyList[commentIndex].replies[replyIndex].isDeleted = true
                                self.commentNReplyList[commentIndex].comment.replyCount! -= 1
                                self.tableView.reloadRows(at: [IndexPath(row: replyIndex, section: commentIndex)], with: .automatic)
                            }
                            else {
                                self.checkIfPostExistsOnServer { isSuccess in
                                    
                                    if isSuccess {
                                        
                                        self.showToast(message: "This Comment for this Reply was Removed", toastType: .red)
                                        self.commentNReplyList[commentIndex].isDeleted = true
                                        self.getActualCommentCount() == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
                                        self.tableView.reloadSections(IndexSet(integer: commentIndex), with: .automatic)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func checkIfReplyExistOnServer(commentId: Int, replyId: Int, completion: @escaping(Bool) -> Void) {
        
        self.showLoader()
        
        let networkManager = APIManager()
        
        networkManager.getReplyList(pageNumber: 0, postId: self.postDetail!.id!, replyId: replyId, commentId: commentId) { [weak self] result in
            
            self?.hideLoader()
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                if let _ = apiResponse.data?.first {
                    completion(true)
                } else {
                    completion(false)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                Alert.sharedInstance.alertOkWindow(title: "Error", message: error.localizedDescription) { result in
                    if result {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    fileprivate func checkIfCommentExistsOnServer(commentId: Int, completion: @escaping(Bool) -> Void) {
        
        self.showLoader()
        
        let networkManager = APIManager()
        
        networkManager.getCommentList(pageNumber: 0, postId: self.postDetail!.id!, commentId: commentId) { [weak self] result in
            
            self?.hideLoader()
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                if let _ = apiResponse.data?.first {
                    completion(true)
                } else {
                    completion(false)
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                Alert.sharedInstance.alertOkWindow(title: "Error", message: error.localizedDescription) { result in
                    if result {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    fileprivate func checkIfPostExistsOnServer(completion: @escaping(Bool) -> Void) {
        
        self.showLoader()

        let networkManager = APIManager()
        
        networkManager.getPostList(pageNumber: 0, pageLimit: 1, postId: self.postDetail!.id!, profileIdentifier: self.postDetail!.userIdentifier!, hashtag: "") { [weak self] result in
            
            self?.hideLoader()
            
            switch result {
                
            case .success(let apiResponse):
                print(apiResponse)
                if let _ = apiResponse.data?.first {
                    completion(true)
                } else {
                    if let postIndex = self?.postIndex {
                        self?.delegate?.deletePost(index: postIndex)
                    }
                    Alert.sharedInstance.alertOkWindow(title: "Error", message: "This Post was Deleted") { result in
                        if result {
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
                
            case .failure(let error):
                print(error.localizedDescription)
                Alert.sharedInstance.alertOkWindow(title: "Error", message: error.localizedDescription) { result in
                    if result {
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
//    // MARK: - Search and Get Index of Comment if comment exist using object.
//    func searchNGetIndexOfCommentIfExist(commentObject: ComRepDM) -> Int? {
//
//        guard let commentId = commentObject.id else {
//            return nil
//        }
//
//        return self.searchNGetIndexOfCommentIfExist(commentId: commentId)
//    }
    
    // MARK: - Search and Get Index of Comment if comment exist using comment id.
    func searchNGetIndexOfCommentIfExist(commentId: Int) -> Int? {
        
        for (index, commentObject) in self.commentNReplyList.enumerated() {
            if commentObject.comment.id == commentId {
                return index
            }
        }
        return nil
    }
    
//    // MARK: - Search and Get Index of Reply if comment and reply exist using comment object and reply object.
//    func searchNGetIndexOfReplyIfExist(commentObject: ComRepDM, replyObject: ComRepDM) -> Int? {
//
//        guard
//            let commentId = commentObject.id,
//            let replyId = replyObject.id
//        else {
//            return nil
//        }
//
//        return self.searchNGetIndexOfReplyIfExist(commentId: commentId, replyId: replyId)
//    }
    
//    // MARK: - Search and Get Index of Reply if comment and reply exist using comment id and reply id.
//    func searchNGetIndexOfReplyIfExist(commentId: Int, replyId: Int) -> Int? {
//
//        guard let commentIndex = self.searchNGetIndexOfCommentIfExist(commentId: commentId) else {
//            return nil
//        }
//
//        for (index, replyObject) in self.commentNReplyList[commentIndex].replies.enumerated() {
//            if replyObject.reply.id == replyId {
//                return index
//            }
//        }
//        return nil
//    }
    
    // MARK: - Search and Get Index of Reply if reply exist using comment index and reply id.
    func searchNGetIndexOfReplyIfExist(commentIndex: Int, replyId: Int) -> Int? {
        
        for (index, replyObject) in self.commentNReplyList[commentIndex].replies.enumerated() {
            if replyObject.reply.id == replyId {
                return index
            }
        }
        return nil
    }
}
