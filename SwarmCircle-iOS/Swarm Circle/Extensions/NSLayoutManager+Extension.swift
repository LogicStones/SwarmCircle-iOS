//
//  abc+Extension.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 19/08/2022.
//

import UIKit

extension NSLayoutManager {
    var numberOfLines: Int {
        guard let _ = textStorage else { return 0 }

        var count = 0
        enumerateLineFragments(forGlyphRange: NSMakeRange(0, numberOfGlyphs)) { _, _, _, _, _ in
            count += 1
        }
        return count
    }
}
