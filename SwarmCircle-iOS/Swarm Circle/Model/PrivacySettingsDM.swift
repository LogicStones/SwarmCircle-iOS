//
//  PrivacySettingsDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 03/01/2023.
//

import Foundation


// MARK: - PrivacySettingsDM
struct PrivacySettingsDM: Codable {
    let userID, emailPrivacy: Int?
    let emailPrivacyText: String?
    let phonePrivacy: Int?
    let phonePrivacyText: String?
    let circleListPrivacy: Int?
    let circleListPrivacyText: String?
    let friendListPrivacy: Int?
    let friendListPrivacyText, phoneNo: String?
    var isTwoFAEnabled: Bool?
    let isEmailVerificationProgress, isPhoneVerificationProgress, isTransactionVerificationProgress: Bool?
}
