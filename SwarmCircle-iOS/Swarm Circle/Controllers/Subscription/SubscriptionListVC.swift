//
//  SubscriptionListController.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 12/09/2023.
//

import UIKit

class SubscriptionListVC: BaseViewController
{
    //basic
    @IBOutlet var lblBasicName: UILabel!
    @IBOutlet var lblBasicPrice: UILabel!
    @IBOutlet var lblBasic1: UILabel!
    @IBOutlet var lblBasic2: UILabel!
    @IBOutlet var lblBasic3: UILabel!
    
    //gold
    @IBOutlet var lblGoldName: UILabel!
    @IBOutlet var lblGoldPrice: UILabel!
    @IBOutlet var lblGold1: UILabel!
    @IBOutlet var lblGold2: UILabel!
    @IBOutlet var lblGold3: UILabel!
    
    //Platinum
    @IBOutlet var lblPlatinumName: UILabel!
    @IBOutlet var lblPlatinumPrine: UILabel!
    @IBOutlet var lblPlatinum1: UILabel!
    @IBOutlet var lblPlatinum2: UILabel!
    @IBOutlet var lblPlatinum3: UILabel!
    
    @IBOutlet var vwBasic: UIView!
    @IBOutlet var vwGold: UIView!
    @IBOutlet var vwPlatinum: UIView!
    

    let viewModel = ViewModel()
    var arrSubscription:[SubscriptionListDM] = []
    var subscriptionID = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initVariable()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshSubscription), name: .refreshSubscription, object: nil)
    }
    
    @objc private func refreshSubscription()
    {
        self.getSubscriptionData()
    }
    
    
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.getSubscriptionData()
    }
    func getSubscriptionData()
    {
        self.showLoader()
        self.viewModel.getSubscriptionPackages()
    }
    @IBAction func btnOpenDetail(_ sender: Any) {
        let sndr = sender as! UIButton
        if let details = self.arrSubscription.first(where: {$0.id == sndr.tag})
        {
            if let vc = AppStoryboard.Subscriptions.instance.instantiateViewController(withIdentifier: "SubscriptionDetailVC") as? SubscriptionDetailVC {
                vc.details = details
                vc.isSubscribed = details.isSubscribed ?? false
                if let isSubs = self.arrSubscription.first(where: {$0.isSubscribed!})
                {
                    self.subscriptionID = isSubs.id ?? -1
                    vc.subscribedID = self.subscriptionID
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

extension SubscriptionListVC: NetworkResponseProtocols {
    func didGetSubscriptionList() {
        self.hideLoader()

        if self.viewModel.getSubscriptionPackagesResponse?.isSuccess ?? false {
            if let unwrappedList = self.viewModel.getSubscriptionPackagesResponse?.data
            {
                let selectedColor = UIColor(red: 197/255, green: 54/255, blue: 245/255, alpha: 1.0)
                self.arrSubscription = unwrappedList
                if self.arrSubscription.count > 0
                {
                    for sub in unwrappedList
                    {
                        switch sub.id
                        {
                        case 1:
                            self.lblBasic1.text = "\(sub.chatHistoryDays ?? 0) Days Chat History"
                            self.lblBasic2.text = "No Audio Call"
                            self.lblBasic3.text = "No Video Call"
                            self.lblBasicName.text = sub.name
                            self.lblBasicPrice.text = "$\(sub.price ?? 0)"
                            self.vwBasic.borderColor = sub.isSubscribed! ? selectedColor : .none
                            self.vwBasic.borderWidth = sub.isSubscribed! ? 1.5 : 0
                            self.subscriptionID = (sub.isSubscribed! ? 1 : -1)
                        case 2:
                            self.lblGold1.text = "\(sub.chatHistoryDays ?? 0) days Chat History"
                            self.lblGold2.text = "\(sub.audioCallMonthlyMinutes ?? 0) Minutes Daily Audio Call"
                            self.lblGold3.text = "\(sub.videoCallMonthlyMinutes ?? 0) Minutes Daily Video Call"
                            self.lblGoldName.text = sub.name
                            self.lblGoldPrice.text = "$\(sub.price ?? 0)"
                            self.vwGold.borderColor = sub.isSubscribed! ? selectedColor : .none
                            self.vwGold.borderWidth = sub.isSubscribed! ? 1.5 : 0
                            self.subscriptionID = sub.isSubscribed! ? 2 :  -1
                        default:
                            self.lblPlatinum1.text = "Unlimited Days Chat History"
                            self.lblPlatinum2.text = "\(sub.audioCallMonthlyMinutes ?? 0) Minutes Daily Audio Call"
                            self.lblPlatinum3.text = "\(sub.videoCallMonthlyMinutes ?? 0) Minutes Daily Video Call"
                            self.lblPlatinumName.text = sub.name
                            self.lblPlatinumPrine.text = "$\(sub.price ?? 0)"
                            self.vwPlatinum.borderColor = sub.isSubscribed! ? selectedColor : .none
                            self.vwPlatinum.borderWidth = sub.isSubscribed! ? 1.5 : 0
                            self.subscriptionID = sub.isSubscribed! ? 3 : -1
                        }
                        
                    }
                }
            }
        }
    }
}
