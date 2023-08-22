//
//  VideoPlayerVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 06/10/2022.
//

import UIKit
import AVKit

class VideoPlayerVC: AVPlayerViewController {
    
    var videoURL: URL?
    var avPlayer: AVPlayer?
//    var playerController = AVPlayerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.initUI()
    }
    
    func initUI() {
        
        guard let videoURL else {
            return
        }
//        self.avPlayer?.preventsDisplaySleepDuringVideoPlayback = true
        self.avPlayer = AVPlayer(url: videoURL)
        self.player = self.avPlayer
//        self.player?.preventsDisplaySleepDuringVideoPlayback = true
        self.allowsPictureInPicturePlayback = true
//        self.player?.play()
        self.updatesNowPlayingInfoCenter = false
        
//        self.present(playerController, animated: true)
    }

    
}
