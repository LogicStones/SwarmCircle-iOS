//
//  NavBarExtension.swift
//  Swarm Circle
//
//  Created by Macbook on 29/04/2022.
//

import UIKit

extension UINavigationBar {
//    open override func sizeThatFits(_ size: CGSize) -> CGSize {
//        return CGSize(width: UIScreen.main.bounds.width, height: 90)
//    }
    
    
}

class CustomNavBar: UINavigationController{
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        navigationController?.navigationBar.shadowImage = UIImage()
        navigationBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100.0)
    }
}
