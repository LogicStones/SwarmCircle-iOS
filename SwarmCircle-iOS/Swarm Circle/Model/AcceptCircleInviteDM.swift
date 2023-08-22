//
//  AcceptCircleInviteDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 20/09/2022.
//

import Foundation

// MARK: - DataClass
struct AcceptCircleInviteDM: Codable {
    let circleName: String?
    let circleImageURL: JSONNull?
    let totalMember: Int?
    let memeberImageURL, memberName: JSONNull?
    let identifier: String?
    let question: JSONNull?
    let durationID, circleID: Int?
    let pollOptions: JSONNull?
    let createdBy: Int?
    let createdOn: String?
    let durationInHours, isDiscoverable: Int?
    let isRequestSent, isActive, isAdmin: Bool?
    let pendingCircleRequestsCount, newPollsCount: Int?
    let isMember: Bool?
    let shareLink: JSONNull?
    let membersInfo: [JSONNull]?

    enum CodingKeys: String, CodingKey {
        case circleName
        case circleImageURL = "circleImageUrl"
        case totalMember
        case memeberImageURL = "memeberImageUrl"
        case memberName, identifier, question, durationID, circleID, pollOptions, createdBy, createdOn, durationInHours, isDiscoverable, isRequestSent, isActive, isAdmin, pendingCircleRequestsCount, newPollsCount, isMember, shareLink, membersInfo
    }
}
