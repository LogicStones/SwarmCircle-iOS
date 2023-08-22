//
//  MessagesRecord.swift
//  Swarm Circle
//
//  Created by Macbook on 18/10/2022.
//

import Foundation
// MARK: - MessagesRecord
class MessagesRecordDM: Codable {
    var date: String?
    var chatList: [ChatList]?
}

// MARK: - ChatList
class ChatList: Codable {
    var recordNum, id: Int?
    var createdOn: String?
    var isDeleted: Bool?
    var messageText, name, displayImageURL, identifier: String?
    var isMine, isSeen: Bool?
    var fileURL, fileName: JSONNull?
    
}

struct SocketChat: Codable {
    var data: ChatList?
    var isSuccess: Bool?
    var message: String?
    var recordCount: Int?
    var statusCode: Int?
}
