//
//  UIApplication+Extension.swift
//  Swarm Circle
//
//  Created by Macbook on 29/04/2022.
//

import Foundation
import UIKit

// MARK: - Fetching Key window
extension UIApplication {
    
    var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
            // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
            // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
            // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
            // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
}

// MARK: - Fetching Key window topViewController
extension UIApplication {
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        // If root `UIViewController` is a `UITabBarController`
        if let presentedController = viewController as? UITabBarController {
            // Move to selected `UIViewController`
            viewController = presentedController.selectedViewController
        }
        
        // Go deeper to find the last presented `UIViewController`
        while let presentedController = viewController?.presentedViewController {
            // If root `UIViewController` is a `UITabBarController`
            if let presentedController = presentedController as? UITabBarController {
                // Move to selected `UIViewController`
                viewController = presentedController.selectedViewController
            } else {
                // Otherwise, go deeper
                viewController = presentedController
            }
        }
        
        return viewController
    }
    
}

extension UIApplication {
    
    class func getTopController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopController(base: selected)
        } else if let presented = base?.presentedViewController {
            return getTopController(base: presented)
        }
        return base
    }
}
