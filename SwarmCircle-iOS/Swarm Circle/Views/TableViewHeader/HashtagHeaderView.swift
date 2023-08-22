//
//  HashtagHeaderView.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 11/01/2023.
//

import UIKit

class HashtagHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var hastagTF: UITextField!
    @IBOutlet weak var hastagLbl: UILabel!
    
    func configureHeader(hashtag: String, hashtagPlaceholder: String) {
        
        self.hastagTF.placeholder = "#\(hashtagPlaceholder)"
        
        if hashtag.isEmpty {
            self.hastagLbl.text = "Latest Feeds"
        } else {
            self.hastagLbl.text = hashtag.starts(with: "#") ? hashtag : "#\(hashtag)"
        }
    }

}
