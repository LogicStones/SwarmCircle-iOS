//
//  CreatePostVC.swift
//  Swarm Circle
//
//  Created by Macbook on 16/08/2022.
//

// post id and share type dena he kl

import UIKit
import AVKit
import Kingfisher

class CreatePostVC: BaseViewController {
    
    @IBOutlet weak var profilePicImgView: CircleImage!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var isVerifiedIcon: UIImageView!
    @IBOutlet weak var shareTypeLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var feedTextView: UITextView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoPlayerBtn: UIButton!
    @IBOutlet weak var crossBtn: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var dropShadowView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet var btnImageOL: UIButton!
    @IBOutlet var btnVideoOL: UIButton!
    @IBOutlet var constrainTagbnt: NSLayoutConstraint!
    
    let privacyOptions: [(String, UIAlertAction.Style)] = [
        ("Friends", UIAlertAction.Style.default),
        ("Public", UIAlertAction.Style.default),
        ("Share With", UIAlertAction.Style.default),
        ("Share With Except", UIAlertAction.Style.default),
        ("Cancel", UIAlertAction.Style.cancel)
    ]
    
    var selectedPrivacyIndex: Int = 1
    
    enum MediaType: String {
        case NewImage
        case NewVideo
        case OldImage
        case OldVideo
    }
    var postId: Int?
    var deletePostMediaIds: [Int] = []
    var feedText: String?
    
    var mediaArray: [(Any, MediaType, UIImage?)] = []
    
    var friendListSelected: [FriendDM] = []
    var shareWithORExceptfriendListSelected: [FriendDM] = []
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Initialization UI
    func initUI() {
        
        self.isVerifiedIcon.isHidden = !(PreferencesManager.getUserModel()?.isAccountVerified ?? false)
        
        if let imgURL = Utils.getCompleteURL(urlString: PreferencesManager.getUserModel()?.displayImageURL) {
            self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.nameLbl.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"

        if let feedText {
            self.feedTextView.text = Utils.decodeUTF(feedText)
        }

        self.shareTypeLbl.text = self.privacyOptions[self.selectedPrivacyIndex - 1].0
        
        self.collectionView.register(UINib(nibName: "MediaCell", bundle: nil), forCellWithReuseIdentifier: "MediaCell")
        
        self.collectionView.allowsMultipleSelection = false
        self.collectionView.allowsSelection = true
        
        self.isPreviewFieldsHidden(true)
        self.videoPlayerBtn.isHidden = true
        
        setToolBarOnKeyboard(textView: self.feedTextView)
        
        if !mediaArray.isEmpty {
            
            if mediaArray[mediaArray.count - 1].1 == .OldVideo {
                self.setPickedVideoOnPreview()
            }
            else if mediaArray[mediaArray.count - 1].1 == .OldImage {
                self.setPickedImageOnPreview()
            }
        }
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.getSubscriptionData()
    }
    
    func getSubscriptionData() {
        
        self.showLoader()
        self.viewModel.getSubscriptionDetails()
    }
    
    // MARK: - Save Post
    func savePost() {
        
        self.feedTextView.resignFirstResponder()
        self.feedTextView.text.removeWhiteSpacesFromStartNEnd()
        self.feedTextView.text.removeNewLinesFromStartNEnd()
        
        self.feedTextView.text = self.feedTextView.text! == "What's on your mind?" ? "" : self.feedTextView.text!
        
        if self.feedTextView.text!.isEmpty {
            self.showToast(message: "Please write something to post", toastType: .red)
            self.feedTextView.text = "What's on your mind?"
            return
        }
        
        if self.selectedPrivacyIndex > 2 { // 3 = share with, 4 = share with except
            if self.shareWithORExceptfriendListSelected.isEmpty {
                self.showToast(message: self.selectedPrivacyIndex == 3 ? "Please select friends to share your post with" : "Please exclude friends to share your post with", toastType: .red)
                return
            }
        }
        
        self.showLoader()
        let mediaDataArray = getMediaInData()
        
        let deletePostMediaIdsStringArray = deletePostMediaIds.map({ String($0) })
        
        let friendIds = self.friendListSelected.map { $0.id! }
        let shareWithORExceptIds = self.shareWithORExceptfriendListSelected.map { $0.id! }
        
        self.viewModel.savePostV2(content: Utils.encodeUTF(self.feedTextView.text!), privacyType: self.selectedPrivacyIndex, imageFiles: mediaDataArray.0, videoFiles: mediaDataArray.1, videoThumbnails: mediaDataArray.2, deletePostMediaIds: deletePostMediaIdsStringArray.joined(separator: ","), postId: self.postId ?? 0, friendIds: friendIds, shareWithFriendIds: shareWithORExceptIds)
        
//        self.viewModel.savePost(content: Utils.encodeUTF(self.feedTextView.text!), privacy: self.shareTypeLbl.text!, imageFiles: mediaDataArray.0, videoFiles: mediaDataArray.1, videoThumbnails: mediaDataArray.2, deletePostMediaIds: deletePostMediaIdsStringArray.joined(separator: ","), postId: self.postId ?? 0)
    }
    
    // MARK: - Convert Media Array to Data Array
    func getMediaInData() -> ([Data], [Data], [Data])
    {
        
        var imageDataArray: [Data] = []
        var videoDataArray: [Data] = []
        var thumbnailDataArray: [Data] = []
        
        for (media) in self.mediaArray {
            
            if media.1 == .NewVideo {
                
                if let videoURL = media.0 as? URL {
                    
                    if let videoData = try? Data(contentsOf: videoURL, options: .mappedIfSafe) {
                        
                        if let thumbnailImageData = media.2?.jpeg(.low) {
                            videoDataArray.append(videoData)
                            thumbnailDataArray.append(thumbnailImageData)
                        }
                    }
                }
            } else if media.1 == .NewImage {
                
                if let image = media.0 as? UIImage {
                    if let imageData = image.jpeg(.low) {
                        imageDataArray.append(imageData)
                    }
                }
            }
        }
        return (imageDataArray, videoDataArray, thumbnailDataArray)
    }
    
    // MARK: - Hide/Show Uploded Media Preview
    fileprivate func isPreviewFieldsHidden(_ isTrue: Bool) {
        self.videoView.isHidden = isTrue
        self.imgView.isHidden = isTrue
        self.crossBtn.isHidden = isTrue
        self.dropShadowView.isHidden = isTrue
    }
    
    // MARK: - Privacy (Share type) Button Tapped
    @IBAction func shareTypeButtonTapped(_ sender: UIButton) {
        
        self.feedTextView.resignFirstResponder()
        
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Audience", message: "Who can see your post?", actions: self.privacyOptions) { index, _ in
            if index < 4 { // Set Privacy
                self.shareTypeLbl.text = self.privacyOptions[index].0
                
                
                if self.selectedPrivacyIndex != index + 1 {
                    self.shareWithORExceptfriendListSelected = []
                }
                
                self.selectedPrivacyIndex = index + 1
                
                if index > 1 {
                    
                    if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "FriendListVC") as? FriendListVC {
                        
                        let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
                        navController.modalTransitionStyle = .crossDissolve
                        navController.modalPresentationStyle  = .overFullScreen
                        
                        if index == 1 {
                            vc.controllerTitle = .selectFriends
                        } else if index == 2 {
                            vc.controllerTitle = .shareWithFriends
                        } else if index == 3 {
                            vc.controllerTitle = .shareWithFriendsExcept
                        }
                        
                        vc.selection = .multiple
                        vc.destinationController = .createPostVC
                        vc.additionalParams = [.isUpdatingShareWithOrExceptList: true]
                        
                        vc.friendListSelected = self.shareWithORExceptfriendListSelected
                        
                        vc.delegate = self
                        
                        self.present(navController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Upload Image Button Tapped
    @IBAction func imgBtnTapped(_ sender: UIButton) {
        
        self.feedTextView.resignFirstResponder()
        
        if self.mediaArray.count >= 5 && (self.mediaArray.first?.1 == .NewImage || self.mediaArray.first?.1 == .OldImage) {
            Alert.sharedInstance.showAlert(title: "Alert", message: "Only 5 images allowed.")
            
        } else {
            if self.mediaArray.first?.1 == .NewVideo || self.mediaArray.first?.1 == .OldVideo {
                self.showWarningAlert(mediaType: "videos") { proceed in
                    if proceed {
                        self.pickImage()
                    }
                }
                return
            }
            self.pickImage()
        }
    }
    
    // MARK: - Upload Video Button Tapped
    @IBAction func videoBtnTapped(_ sender: UIButton) {
        
        self.feedTextView.resignFirstResponder()
        
        if self.mediaArray.count >= 5 && (self.mediaArray.first?.1 == .NewVideo || self.mediaArray.first?.1 == .OldVideo) {
            Alert.sharedInstance.showAlert(title: "Alert", message: "Only 5 videos allowed.")
            
        } else {
            if self.mediaArray.first?.1 == .NewImage || self.mediaArray.first?.1 == .OldImage {
                self.showWarningAlert(mediaType: "images") { proceed in
                    if proceed {
                        self.pickVideo()
                    }
                }
                return
            }
            self.pickVideo()
        }
    }
    
    // MARK: - Tag Friends Button Tapped
    @IBAction func tagBtnTapped(_ sender: UIButton) {
        
        self.feedTextView.resignFirstResponder()
        
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "FriendListVC") as? FriendListVC {

            let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
            navController.modalTransitionStyle = .crossDissolve
            navController.modalPresentationStyle  = .overFullScreen
            
            vc.controllerTitle = .tagFriends
            vc.selection = .multiple
            vc.destinationController = .createPostVC
//            vc.additionalParams = [.isUpdatingShareWithOrExceptList: true]
            
            vc.friendListSelected = self.friendListSelected

            vc.delegate = self
            
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    // MARK: - Show alert when different media type is chosen.
    func showWarningAlert(mediaType: String, proceed: @escaping(Bool)-> Void) {
        
        Alert.sharedInstance.alertWindow(title: "Warning", message: "You can either upload 5 videos or 5 images, choosing 'Yes' will remove all the currently uploaded \(mediaType)") { result in
            if result {
                
                for media in self.mediaArray {
                    if media.1 == .OldVideo || media.1 == .OldImage {
                        if let mediaId = (media.0 as? MediaDM)?.id {
                            self.deletePostMediaIds.append(mediaId)
                        }
                    }
                }
                
                self.mediaArray.removeAll()
                self.isPreviewFieldsHidden(true)
                self.videoPlayerBtn.isHidden = true
                self.collectionView.reloadData()
            }
            proceed(result)
        }
    }
    
    fileprivate func setPickedImageOnPreview() {
        
        DispatchQueue.main.async {
            
            self.collectionView.selectItem(at: IndexPath(row: self.mediaArray.count - 1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            self.collectionView(self.collectionView, didSelectItemAt: IndexPath(row: self.mediaArray.count - 1, section: 0))
        }
        
        self.isPreviewFieldsHidden(false)
        self.videoPlayerBtn.isHidden = true
    }
    
    func pickImage() {
        
        ImagePickerManager().pickImage(self) { image in
            
            self.mediaArray.append((image, .NewImage, nil)) // no thumbnail for image, that's why it's set to nil
            
            self.collectionView.reloadData()
            
            self.setPickedImageOnPreview()
            
        }
    }
    
    fileprivate func setPickedVideoOnPreview() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.collectionView.selectItem(at: IndexPath(row: self.mediaArray.count - 1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            self.collectionView(self.collectionView, didSelectItemAt: IndexPath(row: self.mediaArray.count - 1, section: 0))
        }
        
        self.isPreviewFieldsHidden(false)
        self.videoPlayerBtn.isHidden = false
    }
    
    func pickVideo() {
        VideoPickerManager().pickVideoURL(self) { videoURL in
            
            self.mediaArray.append((videoURL, .NewVideo, nil)) // thumbnail image initially set to nil, and change it in didselect method
            
            self.collectionView.reloadData()
            
            self.setPickedVideoOnPreview()
        }
    }
    
    // MARK: - Post Feed Button Tapped
    @IBAction func postBtnTapped(_ sender: UIButton) {
        self.savePost()
    }
    
    // MARK: - Cross Selected Media Tapped
    @IBAction func crossButtonTapped(_ sender: UIButton) {
        
        guard let selectedRow = self.collectionView.indexPathsForSelectedItems?.first?.row else { // if no cell is selected just return
            return
        }
        
        if self.mediaArray[selectedRow].1 == .OldVideo || self.mediaArray[selectedRow].1 == .OldImage {
            
            if let mediaId = (self.mediaArray[selectedRow].0 as? MediaDM)?.id {
                self.deletePostMediaIds.append(mediaId)
            }
        }
        
        self.mediaArray.remove(at: selectedRow)
        
        self.collectionView.reloadData()
        
        if self.mediaArray.count > 0 {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.collectionView.selectItem(at: IndexPath(row: (selectedRow - 1) >= 0 ? (selectedRow - 1) : 0, section: 0), animated: false, scrollPosition: .centeredHorizontally)
                self.collectionView(self.collectionView, didSelectItemAt: IndexPath(row: (selectedRow - 1) >= 0 ? (selectedRow - 1) : 0, section: 0))
            }
            
        } else {
            self.isPreviewFieldsHidden(true)
            self.videoPlayerBtn.isHidden = true
        }
    }
}

extension CreatePostVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.mediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as? MediaCell else {
            return UICollectionViewCell()
        }
        
        if self.mediaArray[indexPath.row].1 == .NewVideo {
            if let videoURL = self.mediaArray[indexPath.row].0 as? URL {
                cell.mediaImgView.kf.setImage(with: AVAssetImageDataProvider(assetURL: videoURL, seconds: 1)) { result in
                    switch result {
                    case .success(let thumbnailImg):
                        self.mediaArray[indexPath.row].2 = thumbnailImg.image
                    case .failure(let error):
                        self.popOnErrorAlert(error.localizedDescription)
                    }
                }
                cell.videoPlayButton.isHidden = false
            }
        }
        else if self.mediaArray[indexPath.row].1 == .OldVideo {
            if let videoURL = Utils.getCompleteURL(urlString: (self.mediaArray[indexPath.row].0 as? MediaDM)?.fileURL) {
                cell.mediaImgView.kf.setImage(with: AVAssetImageDataProvider(assetURL: videoURL, seconds: 1))
            } else {
                cell.mediaImgView.image = UIImage(named: "imagePlaceholder")!
            }
        }
        
        else if self.mediaArray[indexPath.row].1 == .NewImage {
            if let image = self.mediaArray[indexPath.row].0 as? UIImage {
                cell.mediaImgView.image = image
            }
            cell.videoPlayButton.isHidden = true
        }
        else if self.mediaArray[indexPath.row].1 == .OldImage {
            
            if let imageUrl = Utils.getCompleteURL(urlString: (self.mediaArray[indexPath.row].0 as? MediaDM)?.fileURL) {
                cell.mediaImgView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "imagePlaceholder"))
            } else {
                cell.mediaImgView.image = UIImage(named: "imagePlaceholder")!
            }
            cell.videoPlayButton.isHidden = true
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.mediaArray[indexPath.row].1 == .OldImage {
            if let imageUrl = Utils.getCompleteURL(urlString: (self.mediaArray[indexPath.row].0 as? MediaDM)?.fileURL) {
                self.imgView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "imagePlaceholder"))
            } else {
                self.imgView.image = UIImage(named: "imagePlaceholder")!
            }
        }
        
        else if self.mediaArray[indexPath.row].1 == .OldVideo {
            if let videoURL = Utils.getCompleteURL(urlString: (self.mediaArray[indexPath.row].0 as? MediaDM)?.fileURL) {
                self.imgView.kf.setImage(with: AVAssetImageDataProvider(assetURL: videoURL, seconds: 1))
            } else {
                self.imgView.image = UIImage(named: "imagePlaceholder")!
            }
        }
        else {
            if let cell = self.collectionView.cellForItem(at: indexPath) as? MediaCell {
                self.imgView.image = cell.mediaImgView.image!
            }
        }
        
        if self.mediaArray[indexPath.row].1 == .NewImage || self.mediaArray[indexPath.row].1 == .OldImage {
            self.videoPlayerBtn.isHidden = true
        } else {
            self.videoPlayerBtn.isHidden = false
        }
    }
}

extension CreatePostVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height - 10, height: collectionView.frame.height - 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}


extension CreatePostVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count + text.count > 4000 {
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "What's on your mind?" {
            textView.text = ""
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "What's on your mind?"
        }
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        let text = textView.text.replacingOccurrences(of: "\n", with: "")
//        textView.text = text
//    }
}

extension CreatePostVC: NetworkResponseProtocols {
    
//    func didAddPost() {
//
//        self.hideLoader()
//
//        if self.viewModel.addPostResponse?.isSuccess ?? false {
//
//            if let postId {
//
//                self.delegate?.updatePost(postId: postId, index: nil)
//
//                Alert.sharedInstance.alertOkWindow(title: "Success", message:  self.viewModel.addPostResponse?.message ?? "Some error occured") { result in
//                    if result {
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//
//            } else {
//
//                self.delegate?.addNewPost()
//
//                self.mediaArray = []
//                self.collectionView.reloadData()
//                self.feedTextView.text = "What's on your mind?"
//                self.isPreviewFieldsHidden(true)
//                self.videoPlayerBtn.isHidden = true
//
//                self.showToast(message: self.viewModel.addPostResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
//            }
//
//        } else {
//            self.showToast(message: self.viewModel.addPostResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
//        }
//    }
    
    func didAddPostV2() {
        
        self.hideLoader()
        
        if self.viewModel.addPostResponseV2?.isSuccess ?? false {
            
            if let postId {
                
                self.delegate?.updatePost(postId: postId, index: nil)
                
                Alert.sharedInstance.alertOkWindow(title: "Success", message:  self.viewModel.addPostResponseV2?.message ?? "Some error occured") { result in
                    if result {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                
            } else {
                
                self.delegate?.addNewPost()
                
                self.mediaArray = []
                self.collectionView.reloadData()
                self.feedTextView.text = "What's on your mind?"
                self.isPreviewFieldsHidden(true)
                self.selectedPrivacyIndex = 1
                self.shareTypeLbl.text = self.privacyOptions[self.selectedPrivacyIndex - 1].0
                self.videoPlayerBtn.isHidden = true
                
                self.showToast(message: self.viewModel.addPostResponseV2?.message ?? "Some error occured", delay: 2, toastType: .green)
            }
            
        } else {
            self.showToast(message: self.viewModel.addPostResponseV2?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    func didGetSubscriptionDetails() {
        self.hideLoader()

        if self.viewModel.getSubscriptionDetailsResponse?.isSuccess ?? false {
            if let subsdetails = self.viewModel.getSubscriptionDetailsResponse?.data
            {
                if let id = subsdetails.id, id > 1
                {
                    self.btnImageOL.isHidden = false
                    self.btnVideoOL.isHidden = false
                    self.constrainTagbnt.constant = 125
                }
                else
                {
                    self.btnImageOL.isHidden = true
                    self.btnVideoOL.isHidden = true
                    self.constrainTagbnt.constant = 15
                }
            }
            else
            {
                self.showToast(message: self.viewModel.getSubscriptionDetailsResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            }
        }
    }
}

extension CreatePostVC: AppProtocol {
    
    
    // MARK: - Update selected friend list in CreateCircleVC after done button is tapped in FriendListVC
    func updateSelectedFriendList(friendListSelected: [FriendDM]) {
        self.friendListSelected = friendListSelected
    }
    
    // MARK: - Update share with or except friend list in CreateCircleVC after done button is tapped in FriendListVC
    func updateShareWithORExceptSelectedFriendList(shareWithORExceptfriendListSelected: [FriendDM]) {
        self.shareWithORExceptfriendListSelected = shareWithORExceptfriendListSelected
    }
}
