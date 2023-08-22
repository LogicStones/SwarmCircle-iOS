//
//  Utils.swift
//  Swarm Circle
//
//  Created by Macbook on 02/08/2022.
//

import Foundation
import UIKit
import AVFAudio

final class Utils {
    
    static let feedsPageLimit = 50
    
    static func validateString(text: String, with regex: String) -> Bool {
        // Create the regex
        guard let gRegex = try? NSRegularExpression(pattern: regex) else {
            return false
        }
        
        // Create the range
        let range = NSRange(location: 0, length: text.utf16.count)
        
        // Perform the test
        if gRegex.firstMatch(in: text, options: [], range: range) != nil {
            return true
        }
        
        return false
    }
    
    // MARK: - Get Blur View
    static func getBlurView(effect: UIBlurEffect.Style, intensity: CGFloat) -> CustomIntensityVisualEffectView {
        return CustomIntensityVisualEffectView(effect: UIBlurEffect(style: effect), intensity: intensity)
    }
    
    // MARK: - Encode string Unicode
    static func encodeUTF(_ s: String) -> String {
        
        let data = s.replacingOccurrences(of: "+", with: "%2B").data(using: .utf8, allowLossyConversion: false)
        return String(data: data!, encoding: .utf8)!
    }
    // MARK: - Decode string Unicode
    static func decodeUTF(_ s: String) -> String? {
        let data = s.data(using: .utf8, allowLossyConversion: false)!
        return String(data: data, encoding: .utf8)?.replacingOccurrences(of: "+", with: " ").removingPercentEncoding ?? s
    }
    
    static func getCompleteURL(urlString: String?) -> URL? {
        
        if let urlString = urlString {
            return URL(string:"\(AppConstants.baseImageURL)\(urlString.replacingOccurrences(of: "\\", with: #"/"#))")
        }
        
        return nil
    }
    
    static func getCompleteURL(urlWithoutSlashString: String?) -> URL? {
        
        if let urlString = urlWithoutSlashString {
            return URL(string:"\(AppConstants.baseImageURL)/\(urlString.replacingOccurrences(of: "\\", with: #"/"#))")
        }
        
        return nil
    }
    
    //    // MARK: - Encode string Unicode
    //    static func encodeUTF(_ s: String) -> String {
    //        let data = s.data(using: .nonLossyASCII, allowLossyConversion: true)!
    //        return String(data: data, encoding: .utf8)!
    //    }
    //    // MARK: - Decode string Unicode
    //    static func decodeUTF(_ s: String) -> String? {
    //        let data = s.data(using: .utf8)!
    //        return String(data: data, encoding: .nonLossyASCII)
    //    }
    
    // MARK: - Encode string Hexcode
    static func encodeHex(_ s: String) -> String {
        //        return s.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        return s.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed)!
    }
    // MARK: - Decode string Hexcode
    static func decodeHex(_ s: String) -> String {
        return s.removingPercentEncoding!
    }
    
    static func getCurrentDateTime() -> String {
        let formatter = DateFormatter()
        //2016-12-08 03:37:22 +0000
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let now = Date()
        return formatter.string(from:now)
    }
    
    // 2022-04-23
    static func getFormattedDateShortFormat(date: Date) -> String {
        let formatter = DateFormatter()
        //2016-12-23
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from:date)
    }
    
    // 2022-04-23
    static func getFormattedDateMMDDYYYY(date: Date) -> String {
        let formatter = DateFormatter()
        //2016-12-23
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.string(from:date)
    }
    
    // 2022-04-23
    static func getFormattedDateShortFormat(dateString: String) -> String {
        let formatter = DateFormatter()
        //2016-12-23
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        let date = formatter.date(from: dateString) ?? Date()
    
        let formatterString = DateFormatter()
//        formatterString.dateFormat = "dd MMM yyyy"
        formatterString.dateFormat = "MMM dd yyyy"
        
        return formatterString.string(from: date)
    }
    
    // Call a phone number/ open call intent from bottom
    static func callNumber(phoneNumber: String) {
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    //Get Date from String
    static func getFormatedDate(dateString: String) -> Date {
        let formatter = DateFormatter()
        //2016-12-08 03:37:22 +0000
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter.date(from: dateString) ?? Date()
    }
    
    static func getChatHeaderDate(dateString: String) -> Date {
        let formatter = DateFormatter()
        //2016-12-08 03:37:22 +0000
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: dateString) ?? Date()
    }
    
    // Convert Date to 12 hours
    static func convertStringDateTo12HourTime(_ string: String) -> String {
        
        let date = self.getFormatedDate(dateString: string)
        
        let formatter = DateFormatter()
        //    formatter.timeZone = TimeZone.current
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.locale = .current//Locale(identifier: “en_US_POSIX”) // fixes nil if device time in 24 hour format
        let currentDateStr = formatter.string(from: date)
        
        return currentDateStr
        
    }
    
    static func openShareIntent(_ viewController: UIViewController, description: String, shareLink: String) {
        
        // Setting description
        let firstActivityItem = description
        
        // Setting url
        let secondActivityItem : NSURL = NSURL(string: shareLink)!
        
        // If you want to use an image
        let image : UIImage = UIImage(named: "send")!
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        //        activityViewController.popoverPresentationController?.sourceView = (sender) // sender was uibutton
        
        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        viewController.present(activityViewController, animated: true, completion: nil)
    }
}

import MessageUI

extension Utils {
    
    // Check if screen is locked/unlocked
    static func isProtectedDataAvailable() -> Bool {
      let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as! UIApplication
      return application.isProtectedDataAvailable
    }
    
    // Open email intent
    static func openEmailIntent(_ viewController: UIViewController, emailAddresses: [String]) {
        
        // If user has not setup any email account in the iOS Mail app
        
        if !MFMailComposeViewController.canSendMail() {
            print("Mail services are not available")
            
            UIApplication.shared.open(URL(string: "mailto:\(emailAddresses.joined(separator: "%2C"))")!)
            return
        }
        
        // Use the iOS Mail app
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = viewController as? any MFMailComposeViewControllerDelegate
        composeVC.setToRecipients(emailAddresses)
        composeVC.setSubject("")
        composeVC.setMessageBody("", isHTML: false)
        
        composeVC.mailComposeDelegate = viewController as? any MFMailComposeViewControllerDelegate
        
        viewController.present(composeVC, animated: true)
    }
    
    // MARK: - Restrict double value to two decimal places and return string.
    static func restrictDoubleTwoDecimal(_ value: Double) -> String {
        
        let string = "\(value)"
        
        let splitStringArray = string.split(separator: ".")
        
        if splitStringArray.count > 0 {
            if splitStringArray[1].count > 2 {
                return "\(String(format: "%.2f", value))"
            }
        }
        return "\(value)"
    }
    
    // MARK: - Get file size from url.
    func sizePerMB(url: URL?) -> Double {
        guard let filePath = url?.path else {
            return 0.0
        }
        do {
            let attribute = try FileManager.default.attributesOfItem(atPath: filePath)
            if let size = attribute[FileAttributeKey.size] as? NSNumber {
                return size.doubleValue / 1000000.0
            }
        } catch {
            print("Error: \(error)")
        }
        return 0.0
    }
    
    // MARK: - Convert Comma Seperated String To String Array
    static func convertCommaSeperatedStringToStringArray(_ string: String) -> [String] {
        
        string.split(separator: ",").map { "\($0)" }
    }
    
    // MARK: - Convert Comma Seperated String To Int Array
    static func convertCommaSeperatedStringToIntArray(_ string: String) -> [Int] {
        convertCommaSeperatedStringToStringArray(string).map { Int($0) ?? -1 }
    }
    
    // MARK: - Convert String Array To Comma Seperated String
    static func convertArrayToCommaSeperatedString(_ array: [String]) -> String {
        array.joined(separator: ",")
    }
    
    // MARK: - Convert Integer Array To Comma Seperated String
    static func convertArrayToCommaSeperatedString(_ array: [Int]) -> String{
        let stringArray = array.map { "\($0)" }
        return self.convertArrayToCommaSeperatedString(stringArray)
    }
    
    static func getSymbols(symbol: String, count: Int?) -> String {
        
        guard let count else {
            return "\(symbol) N/A \(symbol)"
        }
        
        var finalSymbol = ""

        for _ in stride(from: 0, to: count, by: 1) {
            finalSymbol += symbol
        }
        
        return finalSymbol
    }
    
}

extension Utils {
    
    // MARK: - Method use to change audio and mic route for callkit
    static func configureAudioSessionType(sessionMode: AVAudioSession.Mode) {
        
        let session = AVAudioSession.sharedInstance()
         
        // Configure category and mode
        do {
//            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.videoChat)
//            try session.setMode(AVAudioSession.Mode.videoChat)
            try session.setMode(sessionMode)
            
        } catch let error as NSError {
            print("Unable to set category:  \(error.localizedDescription)")
        }
         
        // Set preferred sample rate
        do {
            try session.setPreferredSampleRate(44_100)
        } catch let error as NSError {
            print("Unable to set preferred sample rate:  \(error.localizedDescription)")
        }
         
        // Set preferred I/O buffer duration
        do {
            try session.setPreferredIOBufferDuration(0.005)
        } catch let error as NSError {
            print("Unable to set preferred I/O buffer duration:  \(error.localizedDescription)")
        }
         
        // Activate the audio session
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Unable to activate session. \(error.localizedDescription)")
        }
         
        // Query the audio session's ioBufferDuration and sampleRate properties
        // to determine if the preferred values were set
        print("Audio Session ioBufferDuration: \(session.ioBufferDuration), sampleRate: \(session.sampleRate)")
        
        // Preferred Mic = Front, Preferred Polar Pattern = Cardioid
        let preferredMicOrientation = AVAudioSession.Orientation.front
        let preferredPolarPattern = AVAudioSession.PolarPattern.cardioid
         
        // Retrieve your configured and activated audio session
//        let session = AVAudioSession.sharedInstance()
         
        // Get available inputs
        guard let inputs = session.availableInputs else { return }
         
        // Find built-in mic
        guard let builtInMic = inputs.first(where: {
            $0.portType == AVAudioSession.Port.builtInMic
        }) else { return }
         
        // Find the data source at the specified orientation
        guard let dataSource = builtInMic.dataSources?.first (where: {
            $0.orientation == preferredMicOrientation
        }) else { return }
         
        // Set data source's polar pattern
        do {
            try dataSource.setPreferredPolarPattern(preferredPolarPattern)
        } catch let error as NSError {
            print("Unable to preferred polar pattern: \(error.localizedDescription)")
        }
         
        // Set the data source as the input's preferred data source
        do {
            try builtInMic.setPreferredDataSource(dataSource)
        } catch let error as NSError {
            print("Unable to preferred dataSource: \(error.localizedDescription)")
        }
         
        // Set the built-in mic as the preferred input
        // This call will be a no-op if already selected
        do {
            try session.setPreferredInput(builtInMic)
        } catch let error as NSError {
            print("Unable to preferred input: \(error.localizedDescription)")
        }
         
        // Print Active Configuration
        session.currentRoute.inputs.forEach { portDesc in
            print("Port: \(portDesc.portType)")
            if let ds = portDesc.selectedDataSource {
                print("Name: \(ds.dataSourceName)")
                print("Polar Pattern: \(ds.selectedPolarPattern)")
            }
        }
    }
    
    
    static func unconfigureAudioSession(){
        let session = AVAudioSession.sharedInstance()
         
        // Configure category and mode
        do {
//            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.videoChat)
//            try session.setMode(AVAudioSession.Mode.videoChat)
            try session.setActive(false)
            
        } catch let error as NSError {
            print("Unable to set category:  \(error.localizedDescription)")
        }
    }
}

import FlagPhoneNumber

extension Utils {
    
    // Validate phone number (Flag phone number library)
    static func validatePhoneNumber(flagPhoneNumberTextField: FPNTextField) -> Bool {
        
        let cleanedPhoneNumber = flagPhoneNumberTextField.clean(string: "\(flagPhoneNumberTextField.selectedCountry!.phoneCode) \(flagPhoneNumberTextField.text!)")
        
        return (flagPhoneNumberTextField.getValidNumber(phoneNumber: cleanedPhoneNumber) != nil)
        
    }
}
