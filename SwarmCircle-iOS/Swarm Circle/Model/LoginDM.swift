//
//  LoginResponse.swift
//  Swarm Circle
//
//  Created by Macbook on 04/08/2022.
//

import Foundation

struct LoginDM: Codable {
    var user: UserDM?
    var isTwoFAEnabled: Bool?
    var isVerified: Bool?
    let tooManyAttemptRedirect: Bool?
}
