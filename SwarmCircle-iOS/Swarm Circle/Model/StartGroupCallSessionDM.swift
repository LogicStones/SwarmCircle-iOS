//
//  StartGroupCallSessionDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 13/12/2022.
//

import Foundation

// MARK: - StartGroupCallSession
struct StartGroupCallSession: Codable {
    let callerIdentifier, apiKey: String?
    let createdBy: Int?
    let isExpired: Bool?
    let callType: Int?
    let groupCallMembers, identifier, callTo, tokenID: String?
    let broadcastID: String?
    let name: String?
    let joinLink: String?
    let id: Int?
    let createdOn, displayURL, sessionID: String?

    enum CodingKeys: String, CodingKey {
        case callerIdentifier, apiKey, createdBy, isExpired, callType, groupCallMembers, identifier, callTo, tokenID
        case broadcastID = "broadcastId"
        case name, joinLink, id, createdOn, displayURL, sessionID
    }
}
