//
//  CirclePollsByCircleIdListDN.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 14/09/2022.
//

import Foundation


// MARK: - CirclePollsByCircleIdListDM
struct CirclePollsByCircleIdDM: Codable {
    let pollID, circleID: Int?
    let circleName, question, expDate, createdOn: String?
    let createdBy: String?
    let isPollAdmin: Bool?
    let options: [Option]?
    let pollResponse: [PollResponse]?
}

// MARK: - Option
struct Option: Codable {
    let id: Int?
    let optionText: String?
    let pollID, percentage, voteCount: Int?
    let topFiveUsersImages: JSONNull?
}

// MARK: - PollResponse
struct PollResponse: Codable {
    let id, pollID: Int?
    let displayImageURL: String?
    let optionID: Int?
    let isActive: Bool?
    let createdBy: Int?
}
