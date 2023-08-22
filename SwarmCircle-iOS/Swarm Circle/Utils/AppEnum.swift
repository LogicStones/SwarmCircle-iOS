//
//  AppEnum.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 11/08/2022.
//

import UIKit
import Foundation

enum ToastType {
    case red
    case black
    case green
}
extension ToastType: RawRepresentable {
    typealias RawValue = UIColor

    init?(rawValue: RawValue) {
        switch rawValue {
        case #colorLiteral(red: 174/255, green: 36/255, blue: 25/255, alpha: 1): self = .red
        case #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1): self = .green
        case #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1): self = .black
        default: return nil
        }
    }

var rawValue: RawValue {
        switch self {
        case .red: return #colorLiteral(red: 0.7448501587, green: 0.007339844014, blue: 0.01269714441, alpha: 1)
        case .green: return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        case .black: return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}
