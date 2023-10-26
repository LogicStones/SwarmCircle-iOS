//
//  AvatarGallaryDM.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 03/10/2023.
//

import Foundation
struct AvatarGallaryDM: Codable
{
    let id: String?
    let userId: Int?
    let faceId: String?
    let url:String?
    let version: String?
    let createdOn: String?
    let monthlyRemainingLimit: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case faceId, url, version, createdOn
        case monthlyRemainingLimit
    }
}
