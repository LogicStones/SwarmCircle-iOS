//
//  UsersListDM.swift
//  Swarm Circle
//
//  Created by Macbook on 31/08/2022.
//

import Foundation

// MARK: - User
struct UsersListDM: Codable {
    let id, uID: Int?
    let identifier: String?
    let userTypeID: Int?
    let name: String?
    let firstName: String?
    let lastName: String?
    let email: String?
    let phoneNo: String?
    let password: String?
    let dateOfBirth: String?
    let countryID: Int?
    let city: String?
    let displayImageURL: String?
    let isVerified: Bool?
    var isFriendRequestSent: Bool?
    let verifiedOn: JSONNull?
    let isActive, isActiveByAdmin, isDeleted, isTwoFAEnabled: Bool?
    let createdOn: String?
    let createdBy: Int?
    let modifiedBy: Int?
    let modifiedOn: String?
    let genderID: Int?
    let zipcode: String?
    
    var isAccountVerified: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case uID = "u_Id"
        case identifier, userTypeID, name, firstName, lastName, email, phoneNo, password, dateOfBirth, countryID, city, displayImageURL, isVerified, isFriendRequestSent, verifiedOn, isActive, isActiveByAdmin, isDeleted, isTwoFAEnabled, createdOn, createdBy, modifiedBy, modifiedOn, genderID, zipcode, isAccountVerified
    }
}
//
//// MARK: - Encode/decode helpers
//
//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    public var hashValue: Int {
//        return 0
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
//}
