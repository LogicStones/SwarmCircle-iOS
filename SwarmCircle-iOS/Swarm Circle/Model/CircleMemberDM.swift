//
//  CircleMemberListDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 16/09/2022.
//

import Foundation

// MARK: - Datum
struct CircleMemberDM: Codable {
    let id, inviteID: Int?
    let identifier, name, displayImageURL, email: String?
    let circleID: JSONNull?
    let circleCount: Int?
    let walletID: String?
    let isOnline, isBlocked, isInvited: Bool?
    let IsInCall: Bool?
    
    var isAccountVerified: Bool?
    
    // Custom keys
    var isSelected: Bool?
    
}
