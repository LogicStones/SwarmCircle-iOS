//
//  UploadOptions.swift
//  Swarm Circle
//
//  Created by Macbook on 07/06/2023.
//

import Foundation

// MARK: - DataClass
struct UploadOptions: Codable {
    let isPassportVisible, isDrivingVisible, isIDCardVisible: Bool?
}
