//
//  PendingCircleDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 12/09/2022.
//

import Foundation

// MARK: - PendingCircleDM
struct PendingCircleJoinDM: Codable {
    let id, inviteID: Int?
    let identifier, name, displayImageURL, email: String?
    let circleCount: Int?
    let walletID: JSONNull?
    let isOnline: Bool?
}
