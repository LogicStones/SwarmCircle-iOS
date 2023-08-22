//
//  FeedsMediaController.swift
//  Swarm Circle
//
//  Created by Macbook on 16/08/2022.
//

import UIKit
import AVFoundation
import Kingfisher
import AVKit

class FeedsMediaController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    var mediaArray: [MediaDM] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    // MARK: - Initialization UI
    func initUI() {
        self.collectionView.register(UINib(nibName: "MediaCell", bundle: nil), forCellWithReuseIdentifier: "MediaCell")
        self.pageController.numberOfPages = mediaArray.count
        self.pageController.hidesForSinglePage = true
    }
    
    // MARK: - ChildViewControllers
    private func addChildContentViewController(_ childViewController: AVPlayerViewController) {
        addChild(childViewController)
        childViewController.didMove(toParent: self)
    }
}

extension FeedsMediaController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mediaArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MediaCell", for: indexPath) as? MediaCell else {
            return UICollectionViewCell()
        }
        
        
        if !(self.mediaArray[indexPath.row].fileType?.contains("image") ?? false) {
            
            if let videoURL = Utils.getCompleteURL(urlString: self.mediaArray[indexPath.row].fileURL) {
                
//                var videoPlayerController = VideoPlayerVC()
                cell.videoPlayerController = AppStoryboard.Posts.instance.instantiateViewController(withIdentifier: "VideoPlayerVC") as! VideoPlayerVC
                
                cell.videoPlayerController.videoURL = videoURL
                
                addChildContentViewController(cell.videoPlayerController)
                cell.hostedView = cell.videoPlayerController.view
            }
        }
        
        cell.configureCell(info: mediaArray[indexPath.row])
        cell.videoPlayButton.tag = indexPath.row
        cell.videoPlayButton.addTarget(self, action: #selector(videoPlayBtnTapped(_:)), for: .touchUpInside)

        return cell
    
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = self.collectionView.cellForItem(at: indexPath) as? MediaCell {
            cell.videoPlayerController.avPlayer?.pause()
        }
    }
    
    @objc func videoPlayBtnTapped(_ sender: UIButton) {
        if let cell = self.collectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? MediaCell {
            cell.videoPlayButton.isHidden = true
            cell.videoPlayerView.isHidden = false
            cell.videoPlayerController.avPlayer?.play()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: self.collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

extension FeedsMediaController {
    // MARK: - Change Pager Controller Index
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset.x
        let width = scrollView.frame.width
        let horizontalCenter = width / 2
        
        self.pageController.currentPage = Int(offSet + horizontalCenter) / Int(width)
    }
}
