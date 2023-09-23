//
//  Notification+Extension.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 30/09/2022.
//

import Foundation
import UIKit


extension Notification.Name {
    // MARK: - Refresh MyCircleVC (called in  PollIntersectionVC, after circle is intersected)
    static let refreshCircleScreen = Notification.Name("refreshCircleScreen")
    
    // MARK: - Refresh Wallet amount (called in  ConfirmTransferVC after amount is transferred, after amount is deposited in ConfirmPaymentVC)
    static let refreshWalletAmount = Notification.Name("refreshWalletAmount")
    
//    // MARK: - Refresh Friend List after a Friend is removed in ViewProfileVC, called in FriendsListVC
//    static let refreshFriendList = Notification.Name("refreshFriendList")
    
    // MARK: - Group Chat Deleted Pop Chat Controller on Fire
    static let popController = Notification.Name("popController")
    
    static let actionForVideoCall = Notification.Name("actionForVideoCall")
    
    // MARK: - Action for group (Video/Audio) call, fired after user accepts/rejects call from CallKit
    static let actionForGroupCall = Notification.Name("actionForGroupCall")
    
    // MARK: - Action for singe/group audio/video call, fired after user accepts/rejects call from CallKit
    static let actionForCall = Notification.Name("actionForCall")
    
    static let refreshSubscription = Notification.Name("refreshSubscription")
    
    static let protectedDataWillBecomeUnavailableNotification = UIApplication.protectedDataWillBecomeUnavailableNotification
    
    static let protectedDataDidBecomeAvailableNotification = UIApplication.protectedDataDidBecomeAvailableNotification
}


//NotificationCenter.default.addObserver(self, selector: #selector(myFunction), name: .circleDidIntersect, object: nil)

//@objc func myFunction(notification: Notification) {
//    print(notification.object ?? "") //myObject
//    print(notification.userInfo ?? "") //[AnyHashable("key"): "Value"]
//}
