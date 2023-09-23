//
//  SubscriptionListM.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 13/09/2023.
//

import Foundation

struct SubscriptionListDM: Codable
{
    let id: Int?
    let name: String?
    let price: Int?
    let chatHistoryDays:Int?
    let audioCallMonthlyMinutes: Int?
    let videoCallMonthlyMinutes: Int?
    let transferCoinsDailyLimit: Int?
    let newsFeedDailyLimit: Int?
    let isPrivateCircleAllowed: Bool?
    let withdrawCoinsDailyLimit: Int?
    let subscribedUserCount: Int?
    var isSubscribed: Bool?
    let remainingAudioCallMinutes:Int?
    let remainingVideoCallMinutes:Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case price, chatHistoryDays, audioCallMonthlyMinutes, videoCallMonthlyMinutes, transferCoinsDailyLimit, newsFeedDailyLimit
        case isPrivateCircleAllowed
        case withdrawCoinsDailyLimit,subscribedUserCount
        case isSubscribed
        case remainingAudioCallMinutes, remainingVideoCallMinutes
    }
}
