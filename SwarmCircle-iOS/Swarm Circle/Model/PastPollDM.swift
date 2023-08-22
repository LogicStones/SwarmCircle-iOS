//
//  PastPollDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 14/09/2022.
//

import Foundation

// MARK: - PastPollDM
struct PastPollDM: Codable {
    let pollID, circleID: Int?
    let circleName: String?
    let question: String?
    let expDate, createdOn, createdBy: String?
    let isPollAdmin: Bool?
    let options: [OptionPP]?
    let pollResponse: JSONNull?
    let circleAdmin: Bool?
}

// MARK: - Option
struct OptionPP: Codable {
    let id: Int?
    let optionText: String?
    let pollID, percentage, voteCount: Int?
    let topFiveUsersImages: [String]?
}
