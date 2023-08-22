//
//  UserDetailDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 02/11/2022.
//

import Foundation

// MARK: - UserDetailDM
struct UserDetailDM: Codable {
    let id: Int?
    let emailAddress, identifier: String?
    var firstName, lastName: String?
    var phoneNumber: String?
    var imageFile: Data?
    let displayImageURL: String?
    var facebookLink, twitterLink, youtubeLink, instagramLink: String?
    let typeOfLink, link: String?
    var tag: String?
    let userTypeID, countryID: Int?
    let isDiscoverable: Bool?
    let city, dateOfBirth: String?
    let genderID: Int?
    let genderName, zipcode: String?
    let isTwoFAEnabled: Bool?
    let userId: Int?
    var isAMLSuccess: Bool?
    var isAccountVerified: Bool?
    
    
}
