//
//  ExploreCircleDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 09/09/2022.
//

import Foundation

// MARK: - ExploreCircleDM
struct ExploreCircleDM: Codable {
    let circleName, circleImageURL: String?
    let totalMember: Int?
    let memeberImageURL, memberName: JSONNull?
    let identifier: String?
    let question: JSONNull?
    let durationID, circleID: Int?
    let pollOptions, createdBy: JSONNull?
    let createdOn: String?
    let durationInHours, isDiscoverable: Int?
    let isActive, isAdmin: Bool?
    var isRequestSent: Bool?
    let membersInfo: [JSONNull]?
    
    enum CodingKeys: String, CodingKey {
        case circleName
        case circleImageURL = "circleImageUrl"
        case totalMember
        case memeberImageURL = "memeberImageUrl"
        case memberName, identifier, question, durationID, circleID, pollOptions, createdBy, createdOn, durationInHours, isDiscoverable, isActive, isAdmin, isRequestSent, membersInfo
    }
}

//// MARK: - Datum
//struct Datum: Codable {
//    let circleName, circleImageURL: String
//    let totalMember: Int
//    let memeberImageURL, memberName: JSONNull?
//    let identifier: String
//    let question: JSONNull?
//    let durationID, circleID: Int
//    let pollOptions, createdBy: JSONNull?
//    let createdOn: CreatedOn
//    let durationInHours, isDiscoverable: Int
//    let isActive, isAdmin, isRequestSent: Bool
//    let pendingCircleRequestsCount, newPollsCount: Int
//    let isMember: Bool
//    let shareLink: JSONNull?
//    let membersInfo: [JSONAny]
//
//    enum CodingKeys: String, CodingKey {
//        case circleName
//        case circleImageURL = "circleImageUrl"
//        case totalMember
//        case memeberImageURL = "memeberImageUrl"
//        case memberName, identifier, question, durationID, circleID, pollOptions, createdBy, createdOn, durationInHours, isDiscoverable, isActive, isAdmin, isRequestSent, pendingCircleRequestsCount, newPollsCount, isMember, shareLink, membersInfo
//    }
//}
