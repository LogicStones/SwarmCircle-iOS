//
//  UIImage+Extension.swift
//  Swarm Circle
//
//  Created by Macbook on 21/07/2022.
//

import Foundation
import UIKit
import AVFoundation

extension UIImage {
    
    func imageWithColor(color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color.setFill()

        let context = UIGraphicsGetCurrentContext()
        context?.translateBy(x: 0, y: self.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.setBlendMode(CGBlendMode.normal)

        let rect = CGRect(origin: .zero, size: CGSize(width: self.size.width, height: self.size.height))
        context?.clip(to: rect, mask: self.cgImage!)
        context?.fill(rect)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
}

// MARK: - Extension for UIImage Compression
extension UIImage {
  enum JPEGQuality: CGFloat {
    case lowest = 0
    case low   = 0.25
    case medium = 0.5
    case high  = 0.75
    case highest = 1
  }
  func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
    return jpegData(compressionQuality: jpegQuality.rawValue)
  }
}


//extension UIImageView {
//    
//    // Retrieve Thumbnail from Server (in video).
//    func thumbnailFromURL(url: URL) {
//        DispatchQueue.global().async { //1
//            let asset = AVAsset(url: url) //2
//            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset) //3
//            avAssetImageGenerator.appliesPreferredTrackTransform = true //4
//            let thumnailTime = CMTimeMake(value: 2, timescale: 1) //5
//            do {
//                let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumnailTime, actualTime: nil) //6
//                let thumbImage = UIImage(cgImage: cgThumbImage) //7
//                DispatchQueue.main.async { //8
//                    self.image = thumbImage //9
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
