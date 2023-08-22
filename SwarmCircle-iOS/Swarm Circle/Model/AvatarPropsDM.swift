//
//  AvatarPropsDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 04/11/2022.
//

import Foundation

// MARK: - AvatarPropsDM
struct AvatarPropsDM: Codable {
    var propname : String?
    var id : Int?
    var genderID : Int?
    var propType : Int?
    var propLink : String?
    var propLinkApp : String?
    var genderName : String?
    var color : Int?
    
    enum CodingKeys: String, CodingKey {
        
        case propname = "propname"
        case id = "id"
        case genderID = "genderID"
        case propType = "propType"
        case propLink = "propLink"
        case propLinkApp = "propLinkApp"
        case genderName = "genderName"
        case color = "color"
    }
}
