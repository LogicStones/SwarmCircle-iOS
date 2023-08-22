//
//  WalletDetailDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 21/09/2022.
//

import Foundation

// MARK: - WalletDetailDM
struct WalletDetailDM: Codable {
    let walletName: String?
    let amount: Double?
    let walletID, address, idempotencyKey, currency: String?
    let chain: String?
}
