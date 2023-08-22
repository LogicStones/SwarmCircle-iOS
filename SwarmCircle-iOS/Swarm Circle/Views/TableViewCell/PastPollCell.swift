//
//  PollIntersectionCell.swift
//  Swarm Circle
//
//  Created by Macbook on 22/07/2022.
//

import UIKit

class PastPollCell: UITableViewCell {

    @IBOutlet weak var selectionIcon: UIImageView!
//    @IBOutlet weak var typeView: UIView!
//    @IBOutlet weak var typeLBL: UILabel!
    
    @IBOutlet weak var questionLBL: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var pollCreatedByLbl: UILabel!
    
    @IBOutlet var optionViewCollection: [UIView]!
    
    @IBOutlet var votesCountLblCollection: [UILabel]!
    
    @IBOutlet var optionLblCollection: [UILabel]!
    
    @IBOutlet var progressViewCollection: [UIProgressView]!
    
    @IBOutlet var option1ImgViewCollection: [CircleImage]!
    @IBOutlet var option2ImgViewCollection: [CircleImage]!
    @IBOutlet var option3ImgViewCollection: [CircleImage]!
    @IBOutlet var option4ImgViewCollection: [CircleImage]!
    @IBOutlet var option5ImgViewCollection: [CircleImage]!
    
    var optionArrayImgViewCollection = [[CircleImage]]()
    
    @IBOutlet weak var option1Btn: UIButton!
    @IBOutlet weak var option2Btn: UIButton!
    @IBOutlet weak var option3Btn: UIButton!
    @IBOutlet weak var option4Btn: UIButton!
    @IBOutlet weak var option5Btn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.optionArrayImgViewCollection.append(option1ImgViewCollection)
        self.optionArrayImgViewCollection.append(option2ImgViewCollection)
        self.optionArrayImgViewCollection.append(option3ImgViewCollection)
        self.optionArrayImgViewCollection.append(option4ImgViewCollection)
        self.optionArrayImgViewCollection.append(option5ImgViewCollection)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        if selected{
//            self.selectionIcon.image = UIImage(named: "checked")
//        } else{
//            self.selectionIcon.image = UIImage(named: "gray-Radio")
//        }
    }
    
    func configureCell(info: PastPollDM) {
        
        self.selectionIcon.isHidden = true
//        self.typeView.isHidden = true
//        self.typeLBL.isHidden = true
        
        self.questionLBL.isHidden = false
        
        if info.isPollAdmin == true || info.circleAdmin == true {
            self.deleteBtn.isHidden = false
        } else {
            self.deleteBtn.isHidden = true
        }

        self.pollCreatedByLbl.isHidden = false
        
        self.questionLBL.text = "\(info.question ?? "")"
        self.pollCreatedByLbl.text = "Poll created by \(info.createdBy ?? "")"
        
        // Loop through all options
        for i in stride(from: 0, to: 5, by: 1) {
            
            if i < info.options?.count ?? 0 {
                
                self.optionViewCollection[i].isHidden = false
                self.votesCountLblCollection[i].isHidden = false
                self.optionLblCollection[i].isHidden = false
                
                self.optionLblCollection[i].text = info.options?[i].optionText ?? ""
                self.votesCountLblCollection[i].text = "\(info.options?[i].voteCount ?? 0) Votes"
                self.progressViewCollection[i].progress = Float((info.options?[i].percentage ?? 0) / 100)
                
                // Loop through all 5 image views
                for j in stride(from: 0, to: 5, by: 1) {
                    
                    if j < info.options?[i].topFiveUsersImages?.count ?? 0 {
                        
                        self.optionArrayImgViewCollection[i][j].isHidden = false
                        
                        if let imgURL = Utils.getCompleteURL(urlString: info.options?[i].topFiveUsersImages?[j]) {
                            self.optionArrayImgViewCollection[i][j].kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
                        } else {
                            self.optionArrayImgViewCollection[i][j].image = UIImage(named: "defaultProfileImage")!
                        }

                    } else {
                        self.optionArrayImgViewCollection[i][j].isHidden = true
//                        for imgView in self.optionArrayImgViewCollection[i] {
//                            imgView.isHidden = true
//                        }
                    }
                }
            } else {
                self.optionViewCollection[i].isHidden = true
                self.votesCountLblCollection[i].isHidden = true
                self.optionLblCollection[i].isHidden = true
            }
        }
        
        if info.isPollAdmin ?? false {
            self.option1Btn.isHidden = false
            self.option2Btn.isHidden = false
            self.option3Btn.isHidden = false
            self.option4Btn.isHidden = false
            self.option5Btn.isHidden = false
        } else {
            self.option1Btn.isHidden = true
            self.option2Btn.isHidden = true
            self.option3Btn.isHidden = true
            self.option4Btn.isHidden = true
            self.option5Btn.isHidden = true
        }
        
    }
}
