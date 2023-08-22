//
//  UIView+Extension.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import Foundation
import UIKit
import AVFoundation

// MARK: - Extension for UIView
extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
//    open override func awakeFromNib() {
//        super.awakeFromNib()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(UIView.endEditing))
//        tap.cancelsTouchesInView = false
//        self.addGestureRecognizer(tap)
//    }
}

//extension UIView {
//    
//    // Retrieve Thumbnail from Server (in video).
//    func thumbnailFromURL(url: URL) {
//        DispatchQueue.global().async { //1
//            let asset = AVURLAsset(url: url, options: nil)
//            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
//            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
//            let thumnailTime = CMTimeMake(value: 1, timescale: 60)
//            do {
//                
//                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
//                
//                let thumbImage = UIImage(cgImage: cgThumbImage) //7
//                DispatchQueue.main.async { //8
//                    
//                    if (self as? UIImageView) != nil {
//                        (self as! UIImageView).image = thumbImage //9
//                    } else {
//                        self.backgroundColor = UIColor(patternImage: thumbImage)
//                    }
//                }
//            } catch {
//                print(error.localizedDescription) //10
//            }
//        }
//    }
//    
//    func thumbnailFromURLString(urlString: String?) {
//        
//        guard let urlString = urlString else {
//            return
//        }
//        
//        guard let url = URL(string: urlString) else {
//            return
//        }
//        self.thumbnailFromURL(url: url)
//    }
//}
