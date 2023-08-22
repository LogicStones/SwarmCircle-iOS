//
//  TagDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 27/12/2022.
//

import Foundation

// MARK: - TagDM
struct TagDM: Codable {
    let id: Int?
    let name: String?

    // Custom keys
    var isSelected: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "ids"
        case name = "category"
    }
}



