//
//  TransactionDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/09/2022.
//

import Foundation

// MARK: - TransactionDM
struct TransactionDM: Codable {
    let date: String?
//    let transID, bankID: Int?
    let account: String?
//    let paymentMethod, paymentCardID, cardNumber, cardType: JSONNull?
//    let errorMessage: JSONNull?
//    let isWithdrawError: Bool?
    let transType: String?
//    let name: JSONNull?
    let amount: Double?
//    let isWithdrawPending: Bool?
}
