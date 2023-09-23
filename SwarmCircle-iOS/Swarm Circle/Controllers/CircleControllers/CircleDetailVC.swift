//
//  CircleDetailVC.swift
//  Swarm Circle
//
//  Created by Macbook on 07/07/2022.
//

import UIKit
import CallKit

class CircleDetailVC: BaseViewController {
    
    @IBOutlet weak var notifPopUpView: UIView!
    @IBOutlet weak var notifBtn: UIButton!
    @IBOutlet weak var circleNameLbl: UILabel!
    @IBOutlet weak var circleMemberCountLbl: UILabel!
    @IBOutlet weak var newPollCountLbl: UILabel!
    @IBOutlet weak var circleImgView: UIImageView!
    @IBOutlet weak var pendingCircleRequestCountView: UIView!
    @IBOutlet weak var pendingCircleRequestCountLbl: UILabel!
    @IBOutlet var circleMemberImgViewCollection: [UIImageView]!
    @IBOutlet weak var circlePrivacyView: UIView!
    @IBOutlet weak var circlePrivacyLbl: UILabel!
    @IBOutlet var btnAudioOL: UIButton!
    @IBOutlet var btnVideoOL: UIButton!
    
    let viewModel = ViewModel()
    
    var circleIdentifier: String? // To hit circle detail Api
    
    var circleDetails: CircleDetailDM?
    
    var circleMemberList: [CircleMemberDM] = []
    
    var delegate: AppProtocol?
    
    var subscriptionDetails:SubscriptionListDM?
    
    let chatHubConnection = SignalRService.signalRService.connection
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To My Circle"
        
        if circleDetails?.isAdmin ?? false {
            self.animatePendingRequestBanner()
        }
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        self.notifPopUpView.isHidden = true
        self.notifBtn.isHidden = true
        self.pendingCircleRequestCountView.isHidden = true
    }
    
    // MARK: - Load data from API
    func initVariable() {
        
        self.viewModel.delegateNetworkResponse = self
        
        guard let identifier = circleIdentifier else {
            Alert.sharedInstance.alertRedWindow(title: "", message: "Some error occured, please try again later") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            return
        }
        self.showLoader()
        self.postGetCircleDetails(identifier: identifier)
        self.signalRGroupChatDeletedByAdmin()
        self.getSubscriptionData()
    }
    
    func getSubscriptionData() {
        self.viewModel.getSubscriptionDetails()
    }
    
    // MARK: - Circle member button tapped
    @IBAction func circleMemberBtnTapped(_ sender: UIButton) {
        self.openCircleMemberListVC(controllerTitle: .circleMembers, destinationController: .circleDetailVC, selection: .none, additionalParameters: [.circleId: self.circleDetails?.circleID], provideMemberList: true, delegate: false)
    }
    
     // MARK: - Signal R message send by self
     private func signalRGroupChatDeletedByAdmin() {
    
         self.chatHubConnection?.on(method: "ClientPermenantDeleteGroupChat", callback: {(circleIdentifier: String) in
             print(circleIdentifier)
             NotificationCenter.default.post(name: Notification.Name.popController, object: nil)
         })
     }
    
    // MARK: - Get Circle Details
    func postGetCircleDetails(identifier: String) {
        self.viewModel.getCircleDetails(identifier: identifier)
    }
    
    // MARK: - Fetch Circle Member List
    func fetchCircleMemberList() {
        
        guard let circleId = self.circleDetails?.circleID else {
            dismissOnErrorAlert("Circle ID missing")
            return
        }
        self.viewModel.getCircleMemberList(circleId: circleId, pageNumber: 0, searchText: "")
    }
    
    @IBAction func inviteFriendBtnTapped(_ sender: UIButton) {
        
        guard let circleId = circleDetails?.circleID else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }
        
        if circleDetails?.isAdmin ?? false {
            
            if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "InviteFriendsToCircleVC") as? InviteFriendsToCircleVC {
                let navigationController = UINavigationController(rootViewController: vc)
                navigationController.modalPresentationStyle = .overFullScreen
                navigationController.modalTransitionStyle = .crossDissolve
                vc.circleId = circleId
                vc.modalPresentationStyle = .overCurrentContext
                vc.modalTransitionStyle = .crossDissolve
                vc.delegate = self
                self.present(navigationController, animated: true)
            }
        } else {
            self.showToast(message: "You don't have Admin's rights", delay: 2, toastType: .black)
        }
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "ChatVC") as? ChatVC {
            vc.identifier = self.circleDetails?.identifier ?? "" //self.chatList[indexPath.row].identifier ?? ""
            vc.userName = self.circleDetails?.circleName ?? ""
            vc.isCircle = true
            print(vc.identifier)
            print(vc.userName)
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func newPollsTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "NewPollVC") as? NewPollVC {
            //                vc.pollType = "New Polls"
            vc.circleIdentifier = self.circleDetails?.identifier ?? self.circleIdentifier
            vc.delegate =  self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func viewPastPollTapped(_ sender: UIButton) {
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "PastPollVController") as? PastPollVC {
            vc.circleIdentifier = self.circleDetails?.identifier ?? self.circleIdentifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func createNewPollPressed(_ sender: Any) {
        
        guard let circleId = circleDetails?.circleID else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CreatePollVC") as? CreatePollVC {
            vc.circleId = circleId
            vc.delegate =  self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func pendingRequestPressed(_ sender: UIButton) {
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "PendingCirclesVC") as? PendingCirclesVC {
            vc.circleIdentifier = self.circleDetails?.identifier ?? self.circleIdentifier
            vc.delegate =  self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Transfer Button Tapped
    @IBAction func transferBtnTapped(_ sender: UIButton) {
        
//        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "EnterOTPVC") as? EnterOTPVC {
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        
        self.openCircleMemberListVC(controllerTitle: .selectAMember, destinationController: .transferVC, selection: .single, additionalParameters: [.circleId: self.circleDetails?.circleID], provideMemberList: true, delegate: false)
    }
    
    // MARK: - Email Button Tapped
    @IBAction func emailBtnTapped(_ sender: UIButton) {
        
        self.openCircleMemberListVC(destinationController: .emailIntent, selection: .multiple, additionalParameters: [.circleId: self.circleDetails?.circleID], provideMemberList: true, delegate: false)
    }
    
    // MARK: - Video Call Button Tapped
    @IBAction func videoCallBtnTapped(_ sender: UIButton) {
        if self.subscriptionDetails?.remainingAudioCallMinutes ?? 0 <= 0
        {
            Alert.sharedInstance.alertOkWindow(title: "Alert!", message: "Exceeded daily limit", completion: { result in
            })
        }
        else
        {
            self.openCircleMemberListVC(destinationController: .groupAVCallingVC, selection: .multiple, additionalParameters: [.circleId: self.circleDetails?.circleID, .callType: CallType.videoGroup], provideMemberList: false, delegate: true)
        }
    }
    
    // MARK: - Audio Call Button Tapped
    @IBAction func audioCallBtnTapped(_ sender: UIButton) {
        if self.subscriptionDetails?.remainingAudioCallMinutes ?? 0 <= 0
        {
            Alert.sharedInstance.alertOkWindow(title: "Alert!", message: "Exceeded daily limit", completion: { result in
            })
        }
        else
        {
            self.openCircleMemberListVC(destinationController: .groupAVCallingVC, selection: .multiple, additionalParameters: [.circleId: self.circleDetails?.circleID, .callType: CallType.audioGroup], provideMemberList: false, delegate: true)
        }
    }
    
    func openCircleMemberListVC(controllerTitle: CircleMemberListVC.ControllerTitle = .selectMembers, destinationController: CircleMemberListVC.DestinationController, selection: CircleMemberListVC.SelectionType, additionalParameters: [CircleMemberListVC.AdditionalParamsKey: Any?], provideMemberList: Bool, delegate: Bool) {
        
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CircleMemberListVC") as? CircleMemberListVC {

            let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
            navController.modalTransitionStyle = .crossDissolve
            navController.modalPresentationStyle  = .overFullScreen
            
            vc.controllerTitle = controllerTitle
            vc.selection = selection
            vc.destinationController = destinationController
            vc.additionalParams = additionalParameters
            
            if provideMemberList {
                vc.memberList = self.circleMemberList
            }
            
            if delegate {
                vc.delegate = self
            }
            
            self.present(navController, animated: true, completion: nil)
        }
    }
    
//        return
//
//        let provider = CXProvider(configuration: CXProviderConfiguration(localizedName: "My App"))
//        provider.setDelegate(self, queue: nil)
//        let controller = CXCallController()
//        let transaction = CXTransaction(action: CXStartCallAction(call: UUID(), handle: CXHandle(type: .generic, value: "New Call!")))
//        controller.request(transaction, completion: { error in })
    
    @IBAction func shareBtnTapped(_ sender: UIButton) {
        
        guard let shareLink = circleDetails?.shareLink else {
            self.showToast(message: "Share link was not received", toastType: .red)
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        Utils.openShareIntent(self, description: "Hey, Checkout this Circle...", shareLink: shareLink)
        
//        // Setting description
//        let firstActivityItem = "Hey, Checkout my Circle.."
//
//        // Setting url
//        let secondActivityItem : NSURL = NSURL(string: shareLink)!
//
//        // If you want to use an image
//        let image : UIImage = UIImage(named: "send")!
//        let activityViewController : UIActivityViewController = UIActivityViewController(
//            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
//
//        // This lines is for the popover you need to show in iPad
//        activityViewController.popoverPresentationController?.sourceView = (sender)
//
//        // This line remove the arrow of the popover to show in iPad
//        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
//        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
//
//        // Pre-configuring activity items
//        activityViewController.activityItemsConfiguration = [
//        UIActivity.ActivityType.message
//        ] as? UIActivityItemsConfigurationReading
//
//        // Anything you want to exclude
//        activityViewController.excludedActivityTypes = [
//            UIActivity.ActivityType.postToWeibo,
//            UIActivity.ActivityType.print,
//            UIActivity.ActivityType.assignToContact,
//            UIActivity.ActivityType.saveToCameraRoll,
//            UIActivity.ActivityType.addToReadingList,
//            UIActivity.ActivityType.postToFlickr,
//            UIActivity.ActivityType.postToVimeo,
//            UIActivity.ActivityType.postToTencentWeibo,
//            UIActivity.ActivityType.postToFacebook
//        ]
//
//        activityViewController.isModalInPresentation = true
//        self.present(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - Animation for Pending Request banner
    private func animatePendingRequestBanner() {
        DispatchQueue.main.async {
            self.notifPopUpView.isHidden = false
            UIView.animate(withDuration: 3, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.notifPopUpView.alpha = 0
            }, completion: { finished in
                self.notifPopUpView.isHidden = true
                self.notifPopUpView.alpha = 1
            })
        }
    }
}

extension CircleDetailVC: NetworkResponseProtocols {
    
    func didGetCircleDetails() {
        
        self.hideLoader()
        
        if let circleDetails = viewModel.circleDetailsResponse?.data {
            
            self.circleDetails = circleDetails
            
            self.fetchCircleMemberList()
            
            for (i, imgView) in circleMemberImgViewCollection.enumerated() {
                
                if i < viewModel.circleDetailsResponse?.data?.membersInfo?.count ?? 0 {
                    
                    imgView.isHidden = false
                    
                    if let imgURL = Utils.getCompleteURL(urlString: self.viewModel.circleDetailsResponse?.data?.membersInfo?[i].displayImageURL) {
                        imgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
                    } else {
                        imgView.image = UIImage(named: "defaultProfileImage")!
                    }
                } else {
                    imgView.isHidden = true
                }
            }
            
            if self.circleDetails?.isAdmin ?? false {
                
                self.navigationItem.rightBarButtonItem  = UIBarButtonItem(image: UIImage(named: "editIcon")!.withRenderingMode(.alwaysOriginal), style: .done, target: self, action: #selector(editCircleBtnTapped))
                
                self.notifBtn.isHidden = false
                
                self.pendingCircleRequestCountView.isHidden = false
                
                self.pendingCircleRequestCountLbl.text = "\(self.circleDetails!.pendingCircleRequestsCount!)"
                self.notifPopUpView.isHidden = false
                self.animatePendingRequestBanner()
                
            }
            self.circleNameLbl.text = Utils.decodeUTF(self.circleDetails?.circleName ?? "")
            self.circleMemberCountLbl.text = "\(self.circleDetails?.totalMember ?? 0) Members"
            self.newPollCountLbl.text = "\(self.circleDetails?.newPollsCount ?? 0)"
            
            self.circleImgView.kf.indicatorType = .activity
            
            if let imgURL = Utils.getCompleteURL(urlString: self.circleDetails?.circleImageURL) {
                self.circleImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
            } else {
                self.circleImgView.image = UIImage(named: "defaultProfileImage")!
            }
            
            if let privacy = self.circleDetails?.privacy {
                
                self.circlePrivacyView.isHidden = false
                
                if privacy == 1 {
                    self.circlePrivacyLbl.text = "Public"
                    
                } else if privacy == 2 {
                    self.circlePrivacyLbl.text = "Friends"
                    
                } else if privacy == 3 {
                    self.circlePrivacyLbl.text = "Only Members"
                }
            }
            
        } else {
            //                self.viewModel.circleDetailsResponse?.message ??
            Alert.sharedInstance.alertOkWindow(title: "", message: "Some error occured, please try again later") { result in
                if result {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    // MARK: - Edit circle button tapped
    @objc func editCircleBtnTapped() {
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "EditCircleVC") as? EditCircleVC {
            vc.circleDetail = self.circleDetails
            vc.memberList = self.circleMemberList
            vc.delegate = self
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Circle Member List Response
    func didGetCircleMemberList() {
    
        if let unwrappedList = self.viewModel.circleMemberListResponse?.data {
            self.circleMemberList = unwrappedList
        } else {
            print("\(self.viewModel.circleMemberListResponse?.message ?? "Something went wrong")")
        }
    }
    
    func didGetGroupCallSession(isVideoCalling: Bool) {
        
        self.hideLoader()
        
        if let data = self.viewModel.groupCallSessionResponse?.data {
            
            guard let session = data.sessionID, let token = data.tokenID, let apiKEYID = data.apiKey else { return }
            
            sessionId = session
            tokenId = token
            apiKey = apiKEYID
            
//            if isVideoCalling {
//                
//                if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "GroupAVCallingVC") as? GroupAVCallingVC {
//                    let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
//                    navController.modalTransitionStyle = .crossDissolve
//                    navController.modalPresentationStyle  = .overFullScreen
//                    vc.callIdentifier = data.identifier
//                    vc.circleIdentifier = self.circleDetails?.identifier
//                    self.present(navController, animated: true)
//                }
//            }
//            else {
//                
//                if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "GroupAVCallingVC") as? GroupAVCallingVC {
//                    let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
//                    navController.modalTransitionStyle = .crossDissolve
//                    navController.modalPresentationStyle  = .overFullScreen
//                    vc.callIdentifier = data.identifier
//                    vc.circleIdentifier = self.circleDetails?.identifier
////                    vc.callName = self.circleDetails?.circleName
////                    vc.callImage = self.circleDetails?.circleImageURL
//                    self.present(navController, animated: true)
//                }
//                
//            }
        }
        else {
            self.showToast(message: self.viewModel.groupCallSessionResponse?.message ?? "Something went wrong", toastType: .red)
        }
    }
    
    func didGetSubscriptionDetails() {
        self.hideLoader()

        if self.viewModel.getSubscriptionDetailsResponse?.isSuccess ?? false
        {
            if let subsdetails = self.viewModel.getSubscriptionDetailsResponse?.data
            {
                self.subscriptionDetails = subsdetails
            }
            else
            {
                self.showToast(message: self.viewModel.getSubscriptionDetailsResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            }
        }
    }
}

extension CircleDetailVC: AppProtocol {
    // MARK: - Refresh Circle Detail
    func refreshCircleDetail() {
        
        guard let circleIdentifier else {
            return
        }
        
        self.postGetCircleDetails(identifier: circleIdentifier)
        self.delegate?.refreshCircleList()
    }
    
    func updateNewPollsCount(_ count: Int) {
        
        guard let _ = circleDetails?.newPollsCount else {
            return
        }
        self.circleDetails?.newPollsCount! += count
        self.newPollCountLbl.text = "\(self.circleDetails!.newPollsCount!)"
    }
    
    // MARK: - Go To GroupAVCallingVC after circle members are selected in FriendsListVC
    func goToGroupCallingVC(members: String, isVideoCalling: Bool) {
        
        if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "GroupAVCallingVC") as? GroupAVCallingVC {
            let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
            navController.modalTransitionStyle = .crossDissolve
            navController.modalPresentationStyle  = .overFullScreen
            
            vc.callType = isVideoCalling ? .videoGroup : .audioGroup // used to start call session & ...
            vc.callMembers = members // used to start call session
            
            vc.circleIdentifier = self.circleDetails?.identifier // used to broadcast call
            vc.isCallInitiater = true // used to broadcast call

            self.present(navController, animated: true)
        }
    }
}


//extension CircleDetailVC: CXProviderDelegate {
//    func providerDidReset(_ provider: CXProvider) {
//
//    }
//
//
//}

