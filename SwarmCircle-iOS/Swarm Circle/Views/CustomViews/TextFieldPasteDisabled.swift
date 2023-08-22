//
//  TextFieldPasteDisabled.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 16/09/2022.
//

import Foundation
import UIKit

class TextFieldPasteDisabled: UITextField {
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
//        if action == #selector(cut(_:)) ||
//            action == #selector(copy(_:)) ||
//            action == #selector(UIResponderStandardEditActions.paste(_:)) ||
//            action == #selector(UIResponderStandardEditActions.select(_:)) ||
//            action == #selector(UIResponderStandardEditActions.selectAll(_:)) ||
//            action == #selector(UIResponderStandardEditActions.delete(_:)) ||
//            action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionLeftToRight(_:)) ||
//            action == #selector(UIResponderStandardEditActions.makeTextWritingDirectionRightToLeft(_:)) ||
//            action == #selector(UIResponderStandardEditActions.toggleBoldface(_:)) ||
//            action == #selector(UIResponderStandardEditActions.toggleItalics(_:)) ||
//            action == #selector(UIResponderStandardEditActions.toggleUnderline(_:)) ||
//            action == #selector(UIResponderStandardEditActions.increaseSize(_:)) ||
//            action == #selector(UIResponderStandardEditActions.decreaseSize(_:))
//        {
//            return false
//        }
        return false
    }
}
