//
//  FriendsListDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/09/2022.
//

import Foundation

// MARK: - FriendDM
struct FriendDM: Codable, Equatable {
    let id, inviteID: Int?
    let identifier, name, displayImageURL, email: String?
    let circleCount: Int?
    let walletID: String?
    let isOnline: Bool?
    var isAccountVerified: Bool?
    
    var postID: Int?
    
    var circleID: JSONNull?
    var isBlocked, isInvited, isInCall: Bool?
    
    
    // Custom keys
    var isSelected: Bool?
}
