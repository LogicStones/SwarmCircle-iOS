//
//  MyCircleDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 10/09/2022.
//

import Foundation

// MARK: - MyCircleDM
struct JoinedCircleDM: Codable {
    let circleName, circleImageURL: String?
    let totalMember: Int?
    let memeberImageURL, memberName: JSONNull?
    let identifier: String?
    let question: JSONNull?
    let durationID, circleID: Int?
    let pollOptions, createdBy: JSONNull?
    let createdOn: String?
    let durationInHours, isDiscoverable: Int?
    let isActive, isAdmin, isRequestSent: Bool?
    let membersInfo: [MembersInfo]?

    enum CodingKeys: String, CodingKey {
        case circleName
        case circleImageURL = "circleImageUrl"
        case totalMember
        case memeberImageURL = "memeberImageUrl"
        case memberName, identifier, question, durationID, circleID, pollOptions, createdBy, createdOn, durationInHours, isDiscoverable, isActive, isAdmin, isRequestSent, membersInfo
    }
}

// MARK: - MembersInfo
struct MembersInfo: Codable {
    let circleID, userID: Int?
    let firstName, lastName: String?
    let displayImageURL: String?
}
