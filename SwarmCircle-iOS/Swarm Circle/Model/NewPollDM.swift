//
//  NewPollDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 13/09/2022.
//

import Foundation

// MARK: - NewPollDM
struct NewPollDM: Codable {
    let pollID: Int?
    let circleName, question, expDate, createdOn: String?
    let createdBy: String?
    let isPollAdmin: Bool?
    let options: [OptionNP]?
    let pollResponse: JSONNull?
    let circleAdmin: Bool?
}

// MARK: - Option New Poll
struct OptionNP: Codable {
    let id: Int?
    let optionText: String?
    let pollID: Int?
}
