//
//  AppInformationDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 17/11/2022.
//

import Foundation

// MARK: - Datum
struct AppInfoDM: Codable {
    let id: Int?
    let identifier, heading, text: String?
    let createdBy: Int?
    let createdOn, type: String?
    let isActive: Bool?
}
