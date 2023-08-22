//
//  CommentDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 10/10/2022.
//

import Foundation

// MARK: - Comment and ReplyDM
struct ComRepDM: Codable {
    let firstName: String?
    let id: Int?
    var isLiked: Bool?
    let sourceType: Int?
    let lastName: String?
    let commentID: Int?
    let displayImageURL: String?
    var comment: String?
    let createdBy: Int?
    let isActive, isMyComment: Bool?
    let userIdentifier, modifiedOn: String?
    var replyCount: Int?
    let durationAgo: String?
    let recordCount, postID: Int?
    var likeCount: Int?
    let createdOn: String?
    
    let isAccountVerified: Bool?
    
    var isLikeBtnEnabled: Bool? = true
}
