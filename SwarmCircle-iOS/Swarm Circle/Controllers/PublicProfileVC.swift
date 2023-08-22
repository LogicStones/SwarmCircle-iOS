//
//  PublicProfileVC.swift
//  Swarm Circle
//
//  Created by Macbook on 19/08/2022.
//

import UIKit

class PublicProfileVC: BaseViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var profilePicImgView: CircleImage!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var userIdLbl: UILabel!
    @IBOutlet weak var circlesCountLbl: UILabel!
    @IBOutlet weak var friendsCountLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var phoneNumberLbl: UILabel!
    @IBOutlet weak var inviteBtn: UIButton!
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    var profileData: UsersListDM?
        
    var actions: [(String, UIAlertAction.Style)] = [
        ("Hide", UIAlertAction.Style.default),
        ("Report", UIAlertAction.Style.destructive),
        ("Cancel", UIAlertAction.Style.cancel)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        // Set profile Data
        if let profileData = self.profileData {
            
            self.profilePicImgView.kf.indicatorType = .activity
            
            if let imgURL = Utils.getCompleteURL(urlString: profileData.displayImageURL) {
                self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
            } else {
                self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
            }
            self.nameLbl.text = "\(profileData.firstName?.capitalized ?? "") \(profileData.lastName?.capitalized ?? "")"
            self.userIdLbl.text = "User id: \(profileData.id ?? 0)"
            // circle count missing from model
            // friends count missing from model
            self.emailLbl.text = profileData.email ?? ""
            self.phoneNumberLbl.text = profileData.phoneNo ?? ""
            
            self.inviteBtn.isSelected = profileData.isFriendRequestSent ?? false
        }
        
        self.tableView.register(UINib(nibName: "FeedsTextCell", bundle: nil), forCellReuseIdentifier: "FeedsTextCell")
        self.tableView.register(UINib(nibName: "FeedsMediaCell", bundle: nil), forCellReuseIdentifier: "FeedsMediaCell")
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
    }
    
    // MARK: - Send/Cancel Friend Request
    func sendFriendRequest(userId: Int, status: Bool) {
        self.viewModel.sentFriendRequest(params: ["userId": userId, "status": status], indexPath: IndexPath(row: 0, section: 0)) // This indexPath has no use in call back (because there is no list in this controller)
    }
    
    // MARK: - Invite Button Tapped
    @IBAction func inviteBtnTapped(_ sender: UIButton) {
        
        guard let id = profileData?.id, let _ = profileData?.isFriendRequestSent else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }

        if !sender.isSelected {
            self.sendFriendRequest(userId: id, status: false)
        } else {
            self.sendFriendRequest(userId: id, status: true)
        }
        self.inviteBtn.isSelected = !self.inviteBtn.isSelected
    }

    // MARK: - Facebook Button Tapped
    @IBAction func fbBtnTapped(_ sender: UIButton) {
    }
    // MARK: - Twitter Button Tapped
    @IBAction func twitterBtnTapped(_ sender: UIButton) {
    }
    // MARK: - Instagram Button Tapped
    @IBAction func instaBtnTapped(_ sender: UIButton) {
    }
    // MARK: - Youtube Button Tapped
    @IBAction func youtubeBtnTapped(_ sender: UIButton) {
    }
     
    // MARK: - ChildViewControllers
    private func addChildContentViewController(_ childViewController: UIViewController) {
        addChild(childViewController)
        childViewController.didMove(toParent: self)
    }
    
    // MARK: -  Override subview for tableView height align to scrollview
    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async {
            super.updateViewConstraints()
            self.tableViewHeightConstraint.constant = self.tableView.contentSize.height
        }
    }
}
//
//extension PublicProfileVC: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 5
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        
//        if indexPath.row % 2 != 0 {
//
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsMediaCell") as? FeedsMediaCell else {
//                return UITableViewCell()
//            }
//            
//            var feedsMediaController = FeedsMediaController()
//            feedsMediaController = AppStoryboard.Posts.instance.instantiateViewController(withIdentifier: "FeedsMediaController") as! FeedsMediaController
//            
//            addChildContentViewController(feedsMediaController)
//            cell.hostedView = feedsMediaController.view
//            
//            cell.menuBtn.addTarget(self, action:#selector(menuBtnTapped(_:)), for: .touchUpInside)
//            cell.menuBtn.tag = indexPath.row
//            
//            return cell
//        }
//        else {
//            
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "FeedsTextCell") as? FeedsTextCell else {
//                return UITableViewCell()
//            }
//            
//            cell.menuBtn.addTarget(self, action:#selector(menuBtnTapped(_:)), for: .touchUpInside)
//            cell.menuBtn.tag = indexPath.row
//            
//            return cell
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        self.viewWillLayoutSubviews()
//    }
//    
//    @objc func menuBtnTapped(_ sender: UIButton) {
//        
//        Alert.sharedInstance.showActionsheet(vc: self, title: "Manage Feed", message: "This feed belongs to \(sender.tag)", actions: actions) { index, _ in
//            switch index {
//            case 0:
//                print(self.actions[index].0)
//            case 1:
//                print(self.actions[index].0)
//            case 2:
//                print(self.actions[index].0)
//            default :
//                print(self.actions[index].0)
//            }
//        }
//    }
//}

extension PublicProfileVC: NetworkResponseProtocols {
    
    // MARK: - Send/Cancel Friend Request Response
    func didSentFriendRequest(indexPath: IndexPath) {

        // indexPath is not used here because we don't have a list in this controller
        if self.viewModel.friendRequestSentResponse?.data ?? false {
            self.showToast(message: viewModel.friendRequestSentResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            self.delegate?.updateFriendRequestStatus()
        } else {
            self.showToast(message: viewModel.friendRequestSentResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.inviteBtn.isSelected = !self.inviteBtn.isSelected
        }
    }
}
