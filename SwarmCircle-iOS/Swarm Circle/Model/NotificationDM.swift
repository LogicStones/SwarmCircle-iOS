//
//  NotificationDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/09/2022.
//

import Foundation

// MARK: - NotificationDM
struct NotificationDM: Codable {
    let id, userID: Int?
    let identifier, title, message: String?
    let isSeen: Bool?
    let notificationTypeID: Int?
    let notificationTypeName, createdOn, durationAgo, redirectLink: String?
    let createdBy: Int?
    let circleIdentifier, userIdentifier, newsfeedIdentifier: String?
}
