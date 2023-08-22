//
//  ChatListDM.swift
//  Swarm Circle
//
//  Created by Macbook on 17/10/2022.
//

import Foundation
struct MessagesListDM: Codable {
    var id: Int?
    var createdOn, firstName, lastName, displayImageURL, identifier: String?
    var messageText: String?
    var isGroup, isOnline, isCircleAdmin: Bool?
    var isBlocked: Bool?
    var isAccountVerified: Bool?
}
