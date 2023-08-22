//
//  PastPollQuestionCell.swift
//  Swarm Circle
//
//  Created by Macbook on 08/07/2022.
//

import UIKit

class PastPollQuestionCell: UITableViewCell {


    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var options = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.collectionView.delegate = self
//        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "OptionPollCell", bundle: nil), forCellWithReuseIdentifier: "OptionPollCell")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.collectionViewHeight.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
//        self.layoutIfNeeded()
    }

//    override var intrinsicContentSize: CGSize {
//        self.layoutIfNeeded()
//        return self.contentSize
//    }
//
//    override var contentSize: CGSize {
//        didSet{
//            self.invalidateIntrinsicContentSize()
//        }
//    }
//
//    override func reloadData() {
//        super.reloadData()
//        self.invalidateIntrinsicContentSize()
//    }
    
}
// MARK: - TableView Configuration
//extension PastPollQuestionCell: UICollectionViewDelegate, UICollectionViewDataSource{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 3
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OptionPollCell", for: indexPath) as? OptionPollCell else {
//            return UICollectionViewCell()
//        }
//        
//        
//        
//        return cell
//    }
//    //, UITableViewDragDelegate{
//    
//}
//extension PastPollQuestionCell: UITableViewDelegate, UITableViewDataSource{//, UITableViewDragDelegate{
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3//self.options.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionsCell") as? PollOptionsCell else {
//            return UITableViewCell()
//        }
//        if indexPath.row == 1{
//            cell.optionButton.isSelected = true
//        } else {
//            cell.optionButton.isSelected = false
//        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        self.layoutSubviews()
////        self.setNeedsLayout()
//    }
//
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
////        self.layoutSubviews()
//    }
//}
//class ChildTableView: UITableView {
//    override var intrinsicContentSize: CGSize {
//        self.layoutIfNeeded()
//        return self.contentSize
//    }
//
//    override var contentSize: CGSize {
//        didSet{
//            super.contentSize = contentSize
//            self.invalidateIntrinsicContentSize()
//        }
//    }
//
//    override func reloadData() {
//        super.reloadData()
//        self.invalidateIntrinsicContentSize()
//    }
//}
