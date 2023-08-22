//
//  StripeCardDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 27/09/2022.
//

import Foundation

// MARK: - CardDM
struct CardDM: Codable {
    let id: Int?
    let identifier, cardNumber: String?
    let paymentMethodID, customerID: JSONNull?
    let expiryDate, cardType: String?
    let nameOnCard: JSONNull?
    let createdOn: String?
    let createdBy, ccv: Int?
    let isDeleted, isDefault: Bool?

    enum CodingKeys: String, CodingKey {
        case id, identifier, cardNumber
        case paymentMethodID = "paymentMethodId"
        case customerID = "customerId"
        case expiryDate, cardType, nameOnCard, createdOn, createdBy, ccv, isDeleted, isDefault
    }
}
