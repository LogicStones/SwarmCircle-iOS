//
//  UITableView+Extension.swift
//  Swarm Circle
//
//  Created by Macbook on 09/09/2022.
//

import Foundation
import UIKit

// MARK: - Extension for TableView when list is empty
extension UITableView {
    
    func setEmptyView(_ title: String, _ message: String) {
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
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

extension UITableView {

    func scrollToBottom(isAnimated:Bool = true){

        DispatchQueue.main.async {
            
            guard 0 < self.numberOfSections else {return}
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: isAnimated)
            }
        }
    }

    func scrollToTop(isAnimated:Bool = true) {

        DispatchQueue.main.async {
            let indexPath = IndexPath(row: 0, section: 0)
            if self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .top, animated: isAnimated)
           }
        }
    }

    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
//        return indexPath.section > 0 ? false : indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
