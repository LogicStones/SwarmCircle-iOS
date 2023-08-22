//
//  BankAccountDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/10/2022.
//

import Foundation

// MARK: - BankAccountDM
struct BankAccountDM: Codable {
    let id: Int?
    let identifier, accountID, bankName: String?
    let bankID: JSONNull?
    let accountHolderName, accountNumber: String?
    let countryList, currency: JSONNull?
    let routingNumber: String?
    let address, ssn, verifiDocIdentifier: JSONNull?
    let dob: String?
    let documentFile, documentURL: JSONNull?
    let isBankConfigured, isStripeActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id, identifier
        case accountID = "accountId"
        case bankName
        case bankID = "bankId"
        case accountHolderName, accountNumber, countryList, currency, routingNumber, address, ssn, verifiDocIdentifier, dob, documentFile, documentURL, isBankConfigured, isStripeActive
    }
}
