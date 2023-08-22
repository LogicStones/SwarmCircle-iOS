//
//  CircleMembersByCircleIdListDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 14/09/2022.
//

import Foundation

// MARK: - CircleMembersByCircleIdListDM

struct CircleMembersByCircleIdDM: Codable {
    
    let id, inviteID: Int?
    let identifier, name, displayImageURL, email: String?
    let circleID, circleCount: Int?
    let walletID: String?
    let isOnline, isInvited: Bool?
}
