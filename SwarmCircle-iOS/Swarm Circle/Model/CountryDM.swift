//
//  CountryDM.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 07/10/2022.
//

import Foundation

// MARK: - CountryDM
struct CountryDM: Codable {
    let id: Int?
    let countryName, shortCode: String?
    let isActive: Bool?
    let phoneCode: String?
}
