//
//  GetFriendsToInviteInCircleDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 13/09/2022.
//

import Foundation

// MARK: - GetFriendsToInviteInCircleDM
struct GetFriendListToInviteToCircleDM: Codable {
    let id, inviteID: Int?
    let identifier, name, displayImageURL: String?
    let email: JSONNull?
    let circleID, circleCount: Int?
    let walletID: JSONNull?
    let isOnline: Bool
    var isInvited: Bool?
    
    var isAccountVerified: Bool?
}
