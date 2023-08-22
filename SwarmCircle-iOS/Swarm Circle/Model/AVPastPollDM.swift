//
//  AVPastPollDM.swift
//  Swarm Circle
//
//  Created by Macbook on 31/10/2022.
//

import Foundation
// MARK: - AVPastPoll
struct AVPastPoll: Codable {
    var id, pollID, optionID, privacy: Int?
    var createdBy: Int?
    var displayImageURL, createOn: String?
    var isActive: Bool?
    var optionText, question: String?
}
