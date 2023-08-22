//
//  ViewProfileDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 31/10/2022.
//

import Foundation


// MARK: - DataClass
struct ViewProfileDM: Codable {
    let id, uID: Int?
    let identifier, firstName, lastName, email: String?
    let phoneNo: String?
    let city: String?
    let displayImageURL: String?
    var isFriendRequestSent: Bool?
    let requestSentID: Int?
    var isFriendRequestRecieved: Bool?
    let requestRecievedID: Int?
    var isMyFriend: Bool?
    let isActiveByAdmin, isMyAccount, isDeleted: Bool?
    let circleMemberCount, friendsCount: Int?
    let facebookLink, twitterLink, youtubeLink, instagramLink: String?
    let typeOfLink, link: String?
    
    var isAccountVerified: Bool?
    var isBlocked: Bool?
    var isEmailVisible, isPhoneVisible, isCircleListVisible, isFriendListVisible: Bool?
    var emailPrivacy, phonePrivacy: Int?
    var circleListPrivacy, friendListPrivacy: Int?
    var profileCircles: [ProfileCircle]?
    var profileFriends: [FriendDM]?

    enum CodingKeys: String, CodingKey {
        case id
        case uID = "u_Id"
        case identifier, firstName, lastName, email, phoneNo, city, displayImageURL, isFriendRequestSent
        case requestSentID = "requestSentId"
        case isFriendRequestRecieved
        case requestRecievedID = "requestRecievedId"
        case isMyFriend, isActiveByAdmin, isMyAccount, isDeleted, circleMemberCount, friendsCount, facebookLink, twitterLink, youtubeLink, instagramLink, typeOfLink, link, isAccountVerified, isBlocked, isEmailVisible, isPhoneVisible, isCircleListVisible, isFriendListVisible, emailPrivacy, phonePrivacy, circleListPrivacy, friendListPrivacy, profileCircles, profileFriends
    }
}

// MARK: - ProfileCircle
struct ProfileCircle: Codable {
    var recordNum, id: Int?
    var identifier, circleName: String?
    var createdBy: JSONNull?
    var displayImageURL: String?
    var totalMember: Int?
    var createdOn: String?
    var isActive: Bool?
}
