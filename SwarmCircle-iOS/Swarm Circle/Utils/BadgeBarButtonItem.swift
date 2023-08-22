//
//  BadgeBarButtonItem.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/09/2022.
//

import UIKit

public class BadgeBarButtonItem: UIBarButtonItem
{
    @IBInspectable public var badgeNumber: Int = 0 {
        didSet {
            self.updateBadge()
        }
    }
    
    private let label: UILabel
    private var isLabelSet = false
    
    required public init?(coder aDecoder: NSCoder)
    {
        let label = UILabel()
        label.backgroundColor = UIColor(named: "FontColor")
        label.alpha = 0.9
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        label.layer.zPosition = 1
        self.label = label
        
        super.init(coder: aDecoder)
        
        //        guard let view = self.value(forKey: "view") as? UIView else { return }
        //
        //        view.addSubview(self.label)
        //
        //        self.label.widthAnchor.constraint(equalToConstant: 18).isActive = true
        //        self.label.heightAnchor.constraint(equalToConstant: 18).isActive = true
        //        self.label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 9).isActive = true
        //        self.label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -9).isActive = true
        
        self.addObserver(self, forKeyPath: "view", options: [], context: nil)
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        self.updateBadge()
    }
    
    private func updateBadge()
    {
        
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        //        self.label.text = "\(badgeNumber)"
        self.label.text = badgeNumber > 9 ? "9+" : "\(badgeNumber)"
        
        //        if self.badgeNumber > 0 && self.label.superview == nil
        //        {
        if !isLabelSet {
            
            
            view.addSubview(self.label)
            
            self.label.widthAnchor.constraint(equalToConstant: 18).isActive = true
            self.label.heightAnchor.constraint(equalToConstant: 18).isActive = true
            self.label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 9).isActive = true
            self.label.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -9).isActive = true
            
            self.isLabelSet = true
        }
        //        else if self.badgeNumber == 0 && self.label.superview != nil
        //        {
        //            self.label.removeFromSuperview()
        //        }
    }
    
    deinit {
        self.removeObserver(self, forKeyPath: "view")
    }
}
