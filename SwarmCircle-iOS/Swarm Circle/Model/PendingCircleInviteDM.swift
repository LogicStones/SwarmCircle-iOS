//
//  PendingCircleInviteDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 12/09/2022.
//

import Foundation

// MARK: - PendingCircleInviteDM
struct PendingCircleInviteDM: Codable {
    let id, totalMember: Int?
    let circleImageURL: String?
    let code: Int?
    let invitedBy, circleName: String?

    enum CodingKeys: String, CodingKey {
        case id, totalMember
        case circleImageURL = "circleImageUrl"
        case code, invitedBy, circleName
    }
}

