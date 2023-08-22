//
//  MediaCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 16/08/2022.
//

import UIKit
import AVFoundation
import Kingfisher
import AVKit

class MediaCell: UICollectionViewCell {
    
    @IBOutlet weak var mediaImgView: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var videoPlayButton: UIButton!
    
    var videoPlayerController = VideoPlayerVC()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    
    }
    
    func configureCell(info: MediaDM) {
        
        self.mediaImgView.isHidden = false
        self.mediaImgView.kf.indicatorType = .activity
        self.videoPlayerView.isHidden = true
        
        if info.fileType?.contains("image") ?? false {
            
            self.videoPlayButton.isHidden = true
            
            if let imgURL = Utils.getCompleteURL(urlString: info.fileURL) {
                self.mediaImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "imagePlaceholder")) {_ in
                    
                    // Set Aspect ratio of imageview as per image
                    let heightInPoints = self.mediaImgView.image?.size.height ?? 0
                    let heightInPixels = heightInPoints * (self.mediaImgView.image?.scale ?? 0)

                    let widthInPoints = self.mediaImgView.image?.size.width ?? 0
                    let widthInPixels = widthInPoints * (self.mediaImgView.image?.scale ?? 0)
                    
                    if heightInPixels > widthInPixels {
                        self.mediaImgView.contentMode = UIView.ContentMode.scaleAspectFit
                    } else {
                        self.mediaImgView.contentMode = UIView.ContentMode.scaleAspectFill
                    }
                }
            } else {
                self.mediaImgView.image = UIImage(named: "imagePlaceholder")!
            }
            
        } else {
            
            self.videoPlayButton.isHidden = false
            
            if let videoURL = Utils.getCompleteURL(urlString: info.fileURL) {
                
                self.mediaImgView.kf.setImage(with: AVAssetImageDataProvider(assetURL: videoURL, seconds: 1), placeholder: UIImage(named: "imagePlaceholder")) {_ in
                    
                    // Set Aspect ratio of imageview as per image
                    let heightInPoints = self.mediaImgView.image?.size.height ?? 0
                    let heightInPixels = heightInPoints * (self.mediaImgView.image?.scale ?? 0)

                    let widthInPoints = self.mediaImgView.image?.size.width ?? 0
                    let widthInPixels = widthInPoints * (self.mediaImgView.image?.scale ?? 0)
                    
                    if heightInPixels > widthInPixels {
                        self.mediaImgView.contentMode = UIView.ContentMode.scaleAspectFit
                    } else {
                        self.mediaImgView.contentMode = UIView.ContentMode.scaleAspectFill
                    }
                }
                
            } else {
                self.mediaImgView.image = UIImage(named: "imagePlaceholder")!
            }
        }
        

        
        
    }
    
    // MARK: - HostedView

    // 1
    private weak var _hostedView: UIView? {
        didSet {
            if let oldValue = oldValue {
                if oldValue.isDescendant(of: self) { //Make sure that hostedView hasn't been added as a subview to a different cell
                    oldValue.removeFromSuperview()
                }
            }

            if let _hostedView = _hostedView {
                _hostedView.frame = videoPlayerView.bounds
                videoPlayerView.addSubview(_hostedView)
            }
        }
    }

    // 2
    weak var hostedView: UIView? {
        // 3
        get {
            guard _hostedView?.isDescendant(of: self) ?? false else {
                _hostedView = nil
                return nil
            }

            return _hostedView
        }
        //4
        set {
            _hostedView = newValue
        }
    }
    
//    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
//        let p = convert(point, to: v)
//        if v.point(inside: p, with: event) {
//            return v.hitTest(p, with: event)
//        }
//        return super.hitTest(point, with: event)
//    }

}
