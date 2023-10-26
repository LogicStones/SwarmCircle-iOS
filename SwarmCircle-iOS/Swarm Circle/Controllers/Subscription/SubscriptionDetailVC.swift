//
//  SubscriptionDetailVC.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 12/09/2023.
//

import UIKit

class SubscriptionDetailVC: BaseViewController {
    
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblChatHistory: UILabel!
    @IBOutlet var lblAudio: UILabel!
    @IBOutlet var lblVideo: UILabel!
    @IBOutlet var lblCoinsTransferlmt: UILabel!
    @IBOutlet var lblMultimedia: UILabel!
    @IBOutlet var lblCircleType: UILabel!
    @IBOutlet var lblWithdraw: UILabel!
    @IBOutlet var btnSubscribe: UIButton!
    @IBOutlet var btnView: UIView!
    
    var subscribedID = -1
    var isSubscribed = false
    var viewModel = ViewModel()
    var details:SubscriptionListDM!
    var isDowngrad = false
    
    var blue = UIColor(red: 4/255, green: 109/255, blue: 179/255, alpha: 1.0)
    var gld = UIColor(red: 210/255, green: 175/255, blue: 38/255, alpha: 1.0)
    var pltm = UIColor(red: 197/255, green: 54/255, blue: 245/255, alpha: 1.0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnSubscribe.addTarget(self, action: #selector(self.updateSubscription), for: .touchUpInside)
        self.showLoader()
        showDetails()
        self.initVariable()
        print("selectedID \(subscribedID)")
    }
    
    
    func initVariable()
    {
        self.viewModel.delegateNetworkResponse = self
        
    }
    
    // MARK: - Subscribe 
    private func downgradSubscription() {
        
        self.showLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false

        let params = [
            "subscriptionId": self.details.id ?? 0
        ] as [String : Any]
        
        self.viewModel.postDowngradSubscription(params: params)
    }
    
    @objc private func updateSubscription()
    {
        if self.isDowngrad
        {
            Alert.sharedInstance.alertWindow(title: "Alert!", message: "Are you sure you want to downgrade?") { result in
                if result {
                    self.downgradSubscription()
                }
            }
        }
        else
        {
            if let vc = AppStoryboard.Subscriptions.instance.instantiateViewController(withIdentifier: "PaymentMethodSubscribeVC") as? PaymentMethodSubscribeVC
            {
                vc.amount = Double(details.price ?? 0)
                vc.subscriptionName = self.details.name ?? ""
                vc.subscriptionID = "\(self.details.id ?? 0)"
                vc.subscriptionType = .AppSubscription
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func showDetails()
    {
        self.hideLoader()
        if let details = self.details
        {
            let btnClr = UIColor(red: 26/255, green: 16/255, blue: 54/255, alpha: 1.0)
            
            if details.id != nil, let id = details.id
            {
                self.details = details
                self.lblName.text = details.name
                self.lblPrice.text = "$\(details.price ?? 0)"
                self.btnSubscribe.isEnabled = details.isSubscribed! ? false : true
                
                self.btnView.backgroundColor = details.isSubscribed! ? UIColor.systemGray : btnClr
                //self.btnSubscribe.setTitleColor(details.isSubscribed! ? UIColor.lightGray : UIColor.white, for: .normal) 
                if (id == 1 || id == 2 || id == 3)  && self.isSubscribed
                {
                    self.btnSubscribe.setTitle("Subscribed", for: .normal)
                }
                else
                {
                    if self.subscribedID < id
                    {
                        self.btnSubscribe.setTitle("Upgrade", for: .normal)
                    }
                    else if subscribedID > id
                    {
                        self.btnSubscribe.setTitle("Dowgrade", for: .normal)
                        self.isDowngrad = true
                    }
//                    if id < 3 && !self.isSubscribed
//                    {
//                        self.btnSubscribe.setTitle("Dowgrade", for: .normal)
//                        self.isDowngrad = true
//                    }
//                    else
//                    {
//                        if id > 1 && !self.isSubscribed
//                        {
//                            self.btnSubscribe.setTitle("Upgrade", for: .normal)
//                        }
//                    }
                }
                
                switch id
                {
                case 1:
                    self.lblChatHistory.text = "\(details.chatHistoryDays ?? 0) Days Chat History"
                    self.lblAudio.text = "No Audio Call"
                    self.lblVideo.text = "No Video Call"
                    self.lblCoinsTransferlmt.text = "\(details.transferCoinsDailyLimit ?? 0) Coins Daily Transfer Limit"
                    self.lblMultimedia.text = "\(details.newsFeedDailyLimit ?? 0) Daily Text only Newsfeed Posts"
                    self.lblCircleType.text = "Create Only Public Circles"
                    self.lblWithdraw.text = "Cannot Withdraw Any Coins"
                    self.lblPrice.textColor = self.blue
                case 2:
                    self.lblChatHistory.text = "\(details.chatHistoryDays ?? 0) Days Chat History"
                    self.lblAudio.text = "\(details.audioCallMonthlyMinutes ?? 0) Minutes Daily Audio Call"
                    self.lblVideo.text = "\(details.videoCallMonthlyMinutes ?? 0) Minutes Daily Video Call"
                    self.lblCoinsTransferlmt.text = "\(details.transferCoinsDailyLimit ?? 0) Coins Daily Transfer Limit"
                    self.lblMultimedia.text = "\(details.newsFeedDailyLimit ?? 0) Daily Text only Newsfeed Multimedia Posts"
                    self.lblCircleType.text = "Create Public / Private Circles"
                    self.lblWithdraw.text = "Withdraw \(details.withdrawCoinsDailyLimit ?? 0) Coins Daily"
                    self.lblPrice.textColor = self.gld
                default:
                    self.lblChatHistory.text = "Unlimited Chat History"
                    self.lblAudio.text = "\(details.audioCallMonthlyMinutes ?? 0) Minutes Daily Audio Call"
                    self.lblVideo.text = "\(details.videoCallMonthlyMinutes ?? 0) Minutes Daily Video Call"
                    self.lblCoinsTransferlmt.text = "\(details.transferCoinsDailyLimit ?? 0) Coins Daily Transfer Limit"
                    self.lblMultimedia.text = "Unlimited Daily Newsfeed Multimedia Posts"
                    self.lblCircleType.text = "Create Public / Private Circles"
                    self.lblWithdraw.text = "Withdraw \(details.withdrawCoinsDailyLimit ?? 0) Coins Daily"
                    self.lblPrice.textColor = self.pltm
                }
                
            }
        }
    }
}
extension SubscriptionDetailVC: NetworkResponseProtocols {
    func didDowngradSubscription() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.downgradSubscriptionResponse?.isSuccess ?? false {
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.downgradSubscriptionResponse?.message ?? "Some error occured") { result in
                if result {
                    NotificationCenter.default.post(name: .refreshSubscription, object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        } else {
            self.showToast(message: self.viewModel.downgradSubscriptionResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}
