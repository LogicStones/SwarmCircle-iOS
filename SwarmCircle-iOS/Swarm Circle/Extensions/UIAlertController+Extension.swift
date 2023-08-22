//
//  UIAlertController+Extension.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 17/08/2022.
//

import UIKit

extension UIAlertController {
    
    //Set background color of UIAlertController
    func setBackgroundColor(color: UIColor) {
        if let bgView = self.view.subviews.first,
           let groupView = bgView.subviews.first,
           let contentView = groupView.subviews.first {
            contentView.backgroundColor = color
        }
    }
    
    //Set title font and title color
    func setTitle(font: UIFont?, color: UIColor?) {
        guard let title = self.title else { return }
        let attributeString = NSMutableAttributedString(string: title)//1
        
        //      let iRange = LocalisationUtil.shared.isRTL(code: DBManager.shared.getLanguagePreference()) ? title.utf8.count : 0 // if app is in RTL language
        //      let fRange = LocalisationUtil.shared.isRTL(code: DBManager.shared.getLanguagePreference()) ? 0 : title.utf8.count
        
        let iRange = 0
        let fRange = title.utf8.count
        
        if let titleFont = font {
            attributeString.addAttribute(NSAttributedString.Key.font, value: titleFont,//2
                                          range: NSMakeRange(iRange, fRange))
        }
        if let titleColor = color {
            attributeString.addAttribute(NSAttributedString.Key.foregroundColor, value: titleColor,//3
                                          range: NSMakeRange(iRange, fRange))
        }
        self.setValue(attributeString, forKey: "attributedTitle")//4
    }
    
    //Set message font and message color
    func setMessage(font: UIFont?, color: UIColor?) {
        guard let title = self.message else {
            return
        }
        let attributedString = NSMutableAttributedString(string: title)
        
//        let iRange = LocalisationUtil.shared.isRTL(code: DBManager.shared.getLanguagePreference()) ? title.utf8.count : 0 // if app is in RTL language
//        let fRange = LocalisationUtil.shared.isRTL(code: DBManager.shared.getLanguagePreference()) ? 0 : title.utf8.count
        
        let iRange = 0
        let fRange = title.utf8.count
        
        if let titleFont = font {
            attributedString.addAttributes([NSAttributedString.Key.font : titleFont], range: NSMakeRange(iRange, fRange))
        }
        if let titleColor = color {
            attributedString.addAttributes([NSAttributedString.Key.foregroundColor : titleColor], range: NSMakeRange(iRange, fRange))
        }
        self.setValue(attributedString, forKey: "attributedMessage")//4
    }
    
    //Set tint color of UIAlertController
    func setTint(color: UIColor) {
        self.view.tintColor = color
    }
}
