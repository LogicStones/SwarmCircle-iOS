//
//  UserDM.swift
//  Swarm Circle
//
//  Created by Macbook on 04/08/2022.
//

import Foundation

// MARK: - User
struct UserDM: Codable {
    
    let userID: String?
    let isActive: Bool?
    let createdBy: Int?
    let dateOfBirth: String?
    let userTypeID: Int?
    let authToken: String?
    let id: Int?
    let verifiedOn: JSONNull?
    let isActiveByAdmin: Bool?
    let firstName, email: String?
    let countryID: Int?
    let displayImageURL, lastName, zipcode, identifier: String?
    let phoneNo: String?
    let isDeleted: Bool?
    let city, createdOn, password: String?
    let isVerified, isDiscoverable: Bool?
    let tag: String?
    let genderID: Int?
    let isTwoFAEnabled: Bool?
    let role: String?
    let tooManyAttemptRedirect: Bool?
    var isAccountVerified: Bool?
    var isAMLSuccess: Bool?
    let shareLink: String?
    
}

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
