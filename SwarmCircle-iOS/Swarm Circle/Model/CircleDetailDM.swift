//
//  CircleDetailDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 14/09/2022.
//

import Foundation

// MARK: - DataClass
struct CircleDetailDM: Codable {
    let circleName, circleImageURL: String?
    let totalMember: Int?
    let memeberImageURL, memberName: JSONNull?
    let identifier: String?
    let question: JSONNull?
    let durationID: Int?
    var circleID: Int?
    let pollOptions: JSONNull?
    let createdBy: Int?
    let createdOn: String?
    let durationInHours, isDiscoverable: Int?
    let isActive, isAdmin, isRequestSent: Bool?
    let pendingCircleRequestsCount: Int?
    var newPollsCount: Int?
    let shareLink: String?
    let membersInfo: [MembersInfo]?
    let privacy: Int?
    let category: String?

    enum CodingKeys: String, CodingKey {
        case circleName
        case circleImageURL = "circleImageUrl"
        case totalMember
        case memeberImageURL = "memeberImageUrl"
        case memberName, identifier, question, durationID, circleID, pollOptions, createdBy, createdOn, durationInHours, isDiscoverable, isActive, isAdmin, isRequestSent, pendingCircleRequestsCount, newPollsCount, shareLink, membersInfo, privacy, category
    }
}
