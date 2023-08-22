//
//  String+Extension.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 24/08/2022.
//

import Foundation

extension String {
    
    mutating func removeWhiteSpacesFromStartNEnd() {
        self = self.trimmingCharacters(in: .whitespaces)
    }
    mutating func removeNewLinesFromStartNEnd() {
        self = self.trimmingCharacters(in: .newlines)
    }
}

extension String  {
    var isNumber: Bool {
        return !isEmpty && rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}

extension String {
    var isValidURLString: Bool {
        let regEx = "((?:http|https)://)?(?:www\\.)?[\\w\\d\\-_]+\\.\\w{2,3}(\\.\\w{2})?(/(?<=/)(?:[\\w\\d\\-./_]+)?)?"
        let predicate = NSPredicate(format: "SELF MATCHES %@", argumentArray: [regEx])
        return predicate.evaluate(with: self)
    }
}

extension String {
    
    // Reduce white spaces in between to only one
    mutating func condenseWhitespace() {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        self = components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}

// MARK: - Convert HTML to attributed string
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
