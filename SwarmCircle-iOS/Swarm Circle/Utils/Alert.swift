//
//  Alert.swift
//  Swarm Circle
//
//  Created by Macbook on 04/08/2022.
//

import Foundation
import UIKit

class Alert {//This is shared class
    
    static let sharedInstance = Alert()
    
    //Show alert
    func alertWindow(title: String, message: String, completion:@escaping (_ result: Bool) -> Void) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alert2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction1 = UIAlertAction(title: "Yes", style: .default, handler: { action in
                completion(true)
                
            })
            let defaultAction2 = UIAlertAction(title: "No", style: .default, handler: { action in
                print("No")
                completion(false)
            })
            alert2.addAction(defaultAction1)
            alert2.addAction(defaultAction2)
            
            topController.present(alert2, animated: true, completion: nil)
        }
    }
    
    func alertOkWindow(title: String, message: String, completion:@escaping (_ result: Bool) -> Void) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alert2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction1 = UIAlertAction(title: "Ok", style: .default, handler: { action in
                completion(true)
                
            })
            alert2.addAction(defaultAction1)
            
            topController.present(alert2, animated: true, completion: nil)
        }
    }
    
    func alertDialogWithImage(msg: String, Icon : UIImage?) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            let alrt = UIAlertController(title:  " ", message: msg, preferredStyle: .alert)
            
            let cancel = UIAlertAction(title: "Ok", style: .default) { (action) in
                
                
            }
            alrt.addAction(cancel)
            
            let _ = (alrt.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
            
            alrt.view.tintColor = UIColor.red
            
            let imageView = UIImageView(frame: CGRect(x: 120, y: 10, width: 35, height: 35))
            
            imageView.image = Icon
            
            alrt.view.addSubview(imageView)
            
            topController.present(alrt, animated: true, completion: nil)
        }
    }
    
    func alertWith3Actions(title: String, message: String, action1: String, action2: String, action3: String, completion:@escaping (_ result: Bool) -> Void) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alert2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction1 = UIAlertAction(title: action1, style: .destructive, handler: { action in
                completion(true)
                
            })
            let defaultAction2 = UIAlertAction(title: action2, style: .destructive, handler: { action in
                print("Later")
                completion(false)
            })
            let defaultAction3 = UIAlertAction(title: action3, style: .destructive, handler: { action in
                print("No")
                completion(false)
            })
            alert2.addAction(defaultAction1)
            alert2.addAction(defaultAction2)
            alert2.addAction(defaultAction3)
            
            topController.present(alert2, animated: true, completion: nil)
        }
    }
    
    func alertTitleandMessage(title: String, message: String) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alert2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction2 = UIAlertAction(title: "OK", style: .destructive, handler: { action in
            })
            
            alert2.addAction(defaultAction2)
            topController.present(alert2, animated: true, completion: nil)
        }
    }
    
    func showAlert(title: String, message:String){
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            topController.present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func alertRedWindow(title: String, message: String, completion:@escaping (_ result: Bool) -> Void) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alert2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction1 = UIAlertAction(title: "Yes", style: .default, handler: { action in
                completion(true)
                
            })
            let defaultAction2 = UIAlertAction(title: "No", style: .destructive, handler: { action in
                print("No")
                completion(false)
            })
            alert2.addAction(defaultAction1)
            alert2.addAction(defaultAction2)
            
            topController.present(alert2, animated: true, completion: nil)
        }
    }
    
    func updateAlert(title: String, message: String, action1: String, action2: String, action3: String, completion:@escaping (_ result: Int) -> Void) {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            let alert2 = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let defaultAction1 = UIAlertAction(title: action1, style: .default, handler: { action in
                completion(2)
                
            })
            let defaultAction2 = UIAlertAction(title: action2, style: .destructive, handler: { action in
                print("Later")
                completion(1)
            })
            let defaultAction3 = UIAlertAction(title: action3, style: .destructive, handler: { action in
                print("No")
                completion(0)
            })
            alert2.addAction(defaultAction1)
            alert2.addAction(defaultAction2)
            alert2.addAction(defaultAction3)
            
            topController.present(alert2, animated: true, completion: nil)
        }
    }
    
    
    
    // MARK: - Action Sheet Alert
    func showActionsheet(vc: UIViewController, title: String, message: String, actions: [(String, UIAlertAction.Style)], completion: @escaping (_ index: Int, _ title: String) -> Void) {
        let alertViewController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
//        alertViewController.setTitle(font: UIFont(name: "Gilroy-Bold", size: 20), color: nil) // Color not working
//        alertViewController.setMessage(font: UIFont(name: "Gilroy-Medium", size: 16), color: nil) // Color not working
//        alertViewController.setBackgroundColor(color: UIColor.white)
//        alertViewController.setTint(color: UIColor(named: "FontColor")!)
        for (index, (title, style)) in actions.enumerated() {
            
            let alertAction = UIAlertAction(title: title, style: style) { (_) in
                completion(index, title)
            }
            alertViewController.addAction(alertAction)
        }
        // iPad Support
        alertViewController.popoverPresentationController?.sourceView = vc.view
        
        vc.present(alertViewController, animated: true, completion: nil)
    }
}
