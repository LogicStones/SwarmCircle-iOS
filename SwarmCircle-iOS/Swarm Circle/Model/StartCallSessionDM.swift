//
//  StartCallSessionDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/11/2022.
//

import Foundation

// MARK: - Welcome
struct StartCellSessionDM: Codable {
    let groupCallMembers, callerIdentifier, name: String?
    let isExpired: Bool?
    let sessionID, callTo: String?
    let id, createdBy: Int?
    let createdOn, displayURL: String?
    let joinLink: String?
    let callType: Int?
    let broadcastID: JSONNull?
    let apiKey, identifier, tokenID: String?

    enum CodingKeys: String, CodingKey {
        case groupCallMembers, callerIdentifier, name, isExpired, sessionID, callTo, id, createdBy, createdOn, displayURL, joinLink, callType
        case broadcastID = "broadcastId"
        case apiKey, identifier, tokenID
    }
}
