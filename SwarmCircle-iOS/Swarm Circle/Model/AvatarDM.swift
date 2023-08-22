//
//  AvatarDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 04/11/2022.
//

import Foundation

// MARK: - AvatarDM
struct AvatarDM: Codable {
    let id: Int?
    let identifier: String?
    let genderID, minAge, maxAge: Int?
    let genderName: String?
    var propSkin: String?
    var propGlasses, propHair, propShoes, propPants: String?
    var propShirt: String?
    let userID: Int?
    var skin, hair, shoes: Int?
    var pants, shirt, glasses: Int?
    let isDefault: Bool?
}
