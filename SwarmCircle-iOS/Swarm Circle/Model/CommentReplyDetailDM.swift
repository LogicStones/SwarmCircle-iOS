//
//  SaveCommentReplyDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 10/10/2022.
//

import Foundation

// MARK: - SaveCommentReplyDM
struct SaveCommentReplyDM: Codable {
    let commentsCount, commentID: Int?
}

// MARK: - DataClass
struct CommentReplyDetailDM: Codable {
    let sourceLikeCount, commentLikeCount, commentReplyCount: Int
}
