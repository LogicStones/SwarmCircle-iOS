//
//  UserListPollOptionDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 02/01/2023.
//

import Foundation

// MARK: - Datum
struct UserListPollOptionDM: Codable {
    let id, pollID: Int?
    let displayImageURL, identifier, firstName, lastName: String?
    let optionID: Int?
    let isActive: Bool?
    let createdBy: Int?
}
