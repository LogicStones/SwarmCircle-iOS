//
//  BlockedFriendDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/09/2022.
//

import Foundation

// MARK: - BlockedFriendDM
struct BlockedFriendDM: Codable {
    let id, inviteID: Int?
    let identifier, name, displayImageURL: String?
    let email: String?
    let circleID: Int?
    let circleCount: Int
    let walletID: String?
    let isOnline, isInvited: Bool?
    
    var isAccountVerified: Bool?
}
