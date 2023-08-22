//
//  CircleIntersectionCell.swift
//  Swarm Circle
//
//  Created by Macbook on 22/07/2022.
//

import UIKit

class CircleIntersectionCell: UICollectionViewCell {

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var cardView: CardViewMaterial!
    
    var delegate: AppProtocol?
    
    var myCircleList: [JoinedCircleDM] = []
//    var mycircleList = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
//        self.collectionView.dropDelegate = self
        self.collectionView.register(UINib(nibName: "CircleCell", bundle: nil), forCellWithReuseIdentifier: "CircleCell")
    }
    
    override func draw(_ rect: CGRect) {
        self.cardView.cornerRadius = (self.cardView.frame.height / 2)
    }

}

extension CircleIntersectionCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDropDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.myCircleList.count > 1 {
            return 2
        } else {
            return self.myCircleList.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircleCell", for: indexPath) as? CircleCell else {
            return UICollectionViewCell()
        }
//        cell.imageHeight.constant = 40
//        cell.imageWidth.constant = 40
        if indexPath.item == 0 {
            cell.circleImage.isHidden = false
            
            cell.circleImage.kf.indicatorType = .activity
            
            if let imgURL = Utils.getCompleteURL(urlString: self.myCircleList[indexPath.row].circleImageURL) {
                
                cell.circleImage.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage")!)
            } else {
                cell.circleImage.image = UIImage(named: "defaultProfileImage")!
            }
            
            cell.countLBL.isHidden = true
            cell.deleteButton.isHidden = false
            cell.counterView.isHidden = true
        } else {
            cell.counterView.isHidden = false
            cell.circleImage.isHidden = true
            cell.countLBL.isHidden = false
            cell.countLBL.text = "+\(self.myCircleList.count - 1)"
            cell.deleteButton.isHidden = true
        }
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(deleteItemFromList), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.collectionView.deselectItem(at: indexPath, animated: true)
        
        self.delegate?.tapCircleIntersectionCell()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
//    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator){
//        let destinationIndexPath : IndexPath
//        if let indexPath = coordinator.destinationIndexPath
//        {
//            destinationIndexPath = indexPath
//        }
//        else
//        {
//            let row = collectionView.numberOfItems(inSection: 0)
//            destinationIndexPath = IndexPath(item: row - 1, section: 0)
//        }
//        if coordinator.proposal.operation == .copy
//        {
//            //Here you can add your copy code
//            self.iconImage.isHidden = true
//            self.titleLBL.text = "Drop Another Circle"
////            self.myCircleList.insert("1", at: self.myCircleList.endIndex)
//            self.collectionView.reloadData()
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        
        let destinationIndexPath : IndexPath
        
        print(coordinator.proposal.intent.rawValue)
        
        if let indexPath = coordinator.destinationIndexPath {
            
            destinationIndexPath = indexPath
            
        } else {
            // Get last index path of table view.
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        switch coordinator.proposal.operation {
            
        case .move:
            self.iconImage.isHidden = true
            guard let sourceData = coordinator.items[0].dragItem.localObject as? JoinedCircleDM else  {
                return
            }
            self.myCircleList.append(sourceData)
            self.collectionView.reloadData()
            
            print("Moved")
            break
            
        case .copy:
            print("Copy")
            self.iconImage.isHidden = true
            guard let sourceData = coordinator.items[0].dragItem.localObject as? JoinedCircleDM else  {
                return
            }
            self.myCircleList.append(sourceData)
            self.collectionView.reloadData()
        case .cancel:
            print("Cancelled Called")
        default:
            return
        }
    }
    
    
    @objc func deleteItemFromList(sender: UIButton) {
        
        self.delegate?.moveCircleBackToList(circleInfo: myCircleList[sender.tag])
        self.myCircleList.remove(at: sender.tag)
        
        if self.myCircleList.count == 0 {
            self.iconImage.isHidden = false
            self.titleLBL.text = "Circles Intersection"
        } else {
            self.iconImage.isHidden = true
            self.titleLBL.text = "Drop Another Circle"
        }
        self.collectionView.reloadData()
    }
}
