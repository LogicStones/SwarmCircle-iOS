//
//  BroadCastCallDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 13/12/2022.
//

import Foundation

// MARK: - StartGroupCallSession
struct BroadCastCallDM: Codable {
    let id: Int?
    let identifier, name, displayURL, apiKey: String?
    let sessionID, tokenID: String?
    let callType, createdBy: Int?
    let createdOn: String?
    let isExpired: Bool?
    let callTo: String?
    let groupCallMembers: JSONNull?
    let joinLink: String?
    let broadcastID, callerIdentifier: String?

    enum CodingKeys: String, CodingKey {
        case id, identifier, name, displayURL, apiKey, sessionID, tokenID, callType, createdBy, createdOn, isExpired, callTo, groupCallMembers, joinLink
        case broadcastID = "broadcastId"
        case callerIdentifier
    }
}


