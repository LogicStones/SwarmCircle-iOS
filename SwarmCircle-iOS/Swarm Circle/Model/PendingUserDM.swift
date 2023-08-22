//
//  PendingUsersDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/09/2022.
//

import Foundation

// MARK: - PendingUserDM
struct PendingUserDM: Codable {
    let id, sentFrom, sentTo: Int?
    let inviteStatus, createdOn: String?
    let userID: Int?
    let name, identifier, displayImageURL: String?
    let circleCount: Int?
    
    var isAccountVerified: Bool?

    enum CodingKeys: String, CodingKey {
        case id, sentFrom, sentTo, inviteStatus, createdOn
        case userID = "userId"
        case name, identifier
        case displayImageURL = "displayImageUrl"
        case circleCount
    }
}
