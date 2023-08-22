//
//  NotificationVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/09/2022.
//

import UIKit

class NotificationVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var pageNumber: Int = 1
    var notificationList: [NotificationDM] = []
    
    let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Notifications"
    }
    
    // MARK: - Configuring UI when loading
    func initUI(){
        self.tableView.register(UINib(nibName: "NotificationCell", bundle: nil), forCellReuseIdentifier: "NotificationCell")
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetNotificationList()
        UserDefaults.standard.removeObject(forKey: "notificationExist")
    }
    
    // MARK: - Fetch Notification List
    func postGetNotificationList() {
        self.viewModel.getNotificationList(pageNumber: self.pageNumber)
    }
    
}

// MARK: - TableView Configuration
extension NotificationVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notificationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationCell") as? NotificationCell else {
            return UITableViewCell()
        }
        cell.configureCell(info: self.notificationList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        guard let notificationType = notificationList[indexPath.row].notificationTypeName else {
            self.showToast(message: "Some error occured", toastType: .red)
            return
        }
        
        switch notificationType {
            
        case "InviteFriend":
            if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "PendingFriendRequestVC") as? PendingFriendRequestVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "AcceptFriendRequest":
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
                vc.profileIdentifier = notificationList[indexPath.row].userIdentifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "CircleMember", "CircleInviteAccepted", "CircleJoinRequestAccepted", "CircleJoinRequest":
            if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CircleDetailVC") as? CircleDetailVC {
                vc.circleIdentifier = notificationList[indexPath.row].circleIdentifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "PollCreated":
            if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "NewPollVC") as? NewPollVC {
                vc.circleIdentifier = notificationList[indexPath.row].circleIdentifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "InviteToCircle":
            if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CircleInvitationVC") as? CircleInvitationVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "Transfer":
            if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "TransactionsVC") as? TransactionsVC {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "NewsfeedLikePost", "NewsfeedTagged":
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
                vc.postIdentifier = self.notificationList[indexPath.row].newsfeedIdentifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
        case "NewsfeedLikeComment", "NewsfeedLikeReply", "NewsfeedComment", "NewsfeedReply":
            if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "CommentsVC") as? CommentsVC {
                vc.postIdentifier = notificationList[indexPath.row].newsfeedIdentifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        default:
            print("Default Case")
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.notificationList.count - 10 && self.notificationList.count < self.viewModel.notificationListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.postGetNotificationList()
        }
    }
}

extension NotificationVC: NetworkResponseProtocols {
    
    func didGetNotificationList() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.notificationListResponse?.data {
            
            self.pageNumber == 1 ? self.notificationList.removeAll() : ()
            
            self.notificationList.append(contentsOf: unwrappedList)
            
            self.tableView.reloadData()
            
            self.notificationList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: viewModel.notificationListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.notificationList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
}
