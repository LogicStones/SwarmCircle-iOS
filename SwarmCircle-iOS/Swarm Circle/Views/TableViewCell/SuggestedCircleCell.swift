//
//  SuggestedCircleCell.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/08/2022.
//

import UIKit

class SuggestedCircleCell: UITableViewCell {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var memberCountLbl: UILabel!
    @IBOutlet weak var actionBtn: ToggleButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(circleInfo: ExploreCircleDM) {
        
        self.iconImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: circleInfo.circleImageURL) {
            
            self.iconImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.iconImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.memberCountLbl.text = "\(circleInfo.totalMember ?? 0) members"
        self.nameLbl.text = Utils.decodeUTF(circleInfo.circleName ?? "")
    }
    
}
