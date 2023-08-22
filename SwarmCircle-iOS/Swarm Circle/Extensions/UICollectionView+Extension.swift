//
//  UICollectionView+Extension.swift
//  Swarm Circle
//
//  Created by Macbook on 09/09/2022.
//

import Foundation
import UIKit

extension UICollectionView {
    
    func setEmptyView(_ title: String, _ message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
//        emptyView.addBlur()
        let imageView = UIImageView()
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = #imageLiteral(resourceName: "Face")
        titleLabel.textColor = .black
        titleLabel.font = UIFont(name: "AvenirNext-DemiBold", size: 18)
        messageLabel.textColor = .black
        messageLabel.font = UIFont(name: "Avenir Next-DemiBold", size: 16)
        
        emptyView.addSubview(imageView)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(messageLabel)
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor, constant:  -50).isActive = true
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 10).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        titleLabel.text = title
        titleLabel.textAlignment = .center
        messageLabel.text = message
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        // The only tricky part is here:
        self.backgroundView = emptyView
    }
    
    
    func restore() {
        self.backgroundView = nil

    }
}
