//
//  PollIntersectionCell.swift
//  Swarm Circle
//
//  Created by Macbook on 22/07/2022.
//

import UIKit

class PollOptionsViewCell: UITableViewCell {

    @IBOutlet weak var selectionIcon: UIImageView!
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var createdByLbl: UILabel!
    @IBOutlet weak var questionLBL: UILabel!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var typeLBL: UILabel!
    @IBOutlet weak var lblsStackView: UIStackView!
    
    @IBOutlet var optionBtnCollection: [ToggleButton]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
//        if selected {
//
////            self.selectionIcon.image = UIImage(named: "checked")
//        } else{
////            self.selectionIcon.image = UIImage(named: "gray-Radio")
//        }
        
//         Configure the view for the selected state
        if selected{
            self.selectionIcon.image = UIImage(named: "checked")
        } else{
            self.selectionIcon.image = UIImage(named: "gray-Radio")
        }
    }
    
    func configureCell(info: NewPollDM) {
        
        self.lblsStackView.alignment = .fill
        
        self.isUserInteractionEnabled = true
        
        typeView.isHidden = true
        typeLBL.isHidden = true
        selectionIcon.isHidden = true
        
        createdByLbl.isHidden = false
        questionLBL.isHidden = false
        
        if info.isPollAdmin == true || info.circleAdmin == true {
            self.deleteBtn.isHidden = false
        } else {
            self.deleteBtn.isHidden = true
        }

        questionLBL.text = info.question ?? ""
        createdByLbl.text = "Poll created by \(info.createdBy ?? "")"
        
        for (index, optionBtn) in optionBtnCollection.enumerated() {
            
            optionBtn.isSelected = false
            
            if index < info.options?.count ?? 0 {
                
                optionBtn.isHidden =  false
                optionBtn.setTitle("   \(info.options?[index].optionText ?? "")   ", for: .normal)
                
            } else {
                optionBtn.isHidden = true
            }
        }
    }
    
    func configureCell(info: CirclePollsByCircleIdDM) {
        
        self.lblsStackView.alignment = .leading
        
        createdByLbl.isHidden = true
        
        self.isUserInteractionEnabled = true
        
        typeView.isHidden = false
        typeLBL.isHidden = false
        questionLBL.isHidden = false
        selectionIcon.isHidden = false
        
        typeLBL.text = info.circleName ?? ""
        
        questionLBL.text = info.question ?? ""
        
        for (index, optionBtn) in optionBtnCollection.enumerated() {
            
            if index < info.options?.count ?? 0 {
                
                optionBtn.isHidden =  false
                optionBtn.setTitle("   \(info.options?[index].optionText ?? "")   ", for: .normal)
                
            } else {
                optionBtn.isHidden = true
            }
            optionBtn.isUserInteractionEnabled = false
        }
        
        
    }
}
