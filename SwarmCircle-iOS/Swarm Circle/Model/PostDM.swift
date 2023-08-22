//
//  FeedDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 05/10/2022.
//

import Foundation

// MARK: - FeedDM
struct PostDM: Codable {
    var displayImageURL: String?
    var firstName: String?
    var lastName: String?
    var userIdentifier: String?
    var durationAgo: String?
    var likeCount, commentCount: Int?
    var isLiked: Bool?
    var mediaList: [MediaDM]?
    var commentList: [JSONNull]?
    var taggedFriends: [FriendDM]?
    var sharedWith: [FriendDM]?
    var id: Int?
    var identifier, content: String?
    var privacy: Int?
    var createdOn: String?
    var createdBy: Int?
    var modifiedOn: String?
    var isActive: Bool?
    var shareLink: String?
    var isAccountVerified: Bool?
    
    // custom
    var isContentExpanded: Bool? = false
    var isDeleted: Bool? = false
    var isLikeBtnEnabled: Bool? = true
}

// MARK: - MediaDM
struct MediaDM: Codable {
    var id, postID: Int?
    var fileURL: String?
    var thumbnailURL: String?
    var fileType: String?
    var isActive: Bool?
}

//// MARK: - TaggedFriend
//struct TaggedFriend: Codable {
//    var id: Int?
//    var displayImageURL, name, identifier: String?
//    var postID: Int?
//    var email: String?
//}
//
//// MARK: - SharedWith
//struct SharedWith: Codable {
//    var id: Int?
//    var displayImageURL, name, identifier: String?
//    var postID: Int?
//    var email: String?
//}
