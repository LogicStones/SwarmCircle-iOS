//
//  AppStoryboard.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import Foundation
import UIKit

enum AppStoryboard : String {
    case Main = "Main"
    case Login = "Login"
    case Circle = "Circle"
    case Finance = "Finance"
    case Posts = "Posts"
    case Interaction = "Interaction"
    case Profile = "Profile"
    case AVCalling = "AVCalling"
    case Identify = "Identify"
    case Subscriptions = "Subscription"
    
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}
