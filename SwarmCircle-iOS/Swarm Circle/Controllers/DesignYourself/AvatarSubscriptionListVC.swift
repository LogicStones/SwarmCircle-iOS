//
//  AvatarSubscriptionListVC.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 30/09/2023.
//

import UIKit

class AvatarSubscriptionListVC: BaseViewController
{
    //basic
    @IBOutlet var lblBasicName: UILabel!
    @IBOutlet var lblBasicPrice: UILabel!
    @IBOutlet var lblBasic1: UILabel!
    @IBOutlet var lblBasic2: UILabel!
    @IBOutlet var btnBasicSubscribe: UIButton!
    @IBOutlet var vwBtnBasic: UIView!
    
    //gold
    @IBOutlet var lblGoldName: UILabel!
    @IBOutlet var lblGoldPrice: UILabel!
    @IBOutlet var lblGold1: UILabel!
    @IBOutlet var lblGold2: UILabel!
    @IBOutlet var btnGoldSubscribe: UIButton!
    @IBOutlet var vwBtnGold: UIView!
    
    //Platinum
    @IBOutlet var lblPlatinumName: UILabel!
    @IBOutlet var lblPlatinumPrine: UILabel!
    @IBOutlet var lblPlatinum1: UILabel!
    @IBOutlet var lblPlatinum2: UILabel!
    @IBOutlet var vwBasic: UIView!
    @IBOutlet var vwGold: UIView!
    @IBOutlet var vwPlatinum: UIView!
    @IBOutlet var btnPlatinumSubscribe: UIButton!
    @IBOutlet var vwBtnPlatinum: UIView!
    @IBOutlet var GalleryOL: UIButton!
    

    let viewModel = ViewModel()
    var arrSubscription:[SubscriptionListDM] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.initVariable()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshAvatarSubscription), name: .refreshAvatarSubscription, object: nil)
    }
    
    @objc private func refreshAvatarSubscription()
    {
        self.getSubscriptionData()
    }
    
    func initVariable()
    {
        self.viewModel.delegateNetworkResponse = self
        self.getSubscriptionData()
    }
    
    func getSubscriptionData()
    {
        self.showLoader()
        self.viewModel.getAvatarSubscriptionPackages()
    }
    @IBAction func btnOpenGallary(_ sender: Any)
    {
        if let vc = AppStoryboard.DesignYourself.instance.instantiateViewController(withIdentifier: "AvatarListVC") as? AvatarListVC
        {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension AvatarSubscriptionListVC: NetworkResponseProtocols
{
    func didGetAvatarSubscriptionList()
    {
        self.hideLoader()

        if self.viewModel.getAvatarSubscriptionPackagesResponse?.isSuccess ?? false {
            if let unwrappedList = self.viewModel.getAvatarSubscriptionPackagesResponse?.data
            {
                let selectedColor = UIColor(red: 197/255, green: 54/255, blue: 245/255, alpha: 1.0)
                self.arrSubscription = []
                self.arrSubscription = unwrappedList
                if self.arrSubscription.count > 0
                {
                    for sub in unwrappedList
                    {
                        switch sub.id
                        {
                        case 1:
                            self.lblBasicName.text = sub.name
                            self.lblBasicPrice.text = "$\(sub.price ?? 0)"
                            self.vwBasic.borderColor = sub.isSubscribed! ? selectedColor : .none
                            self.vwBasic.borderWidth = sub.isSubscribed! ? 1.5 : 0
                        case 2:
                            self.lblGoldName.text = sub.name
                            self.lblGoldPrice.text = "$\(sub.price ?? 0)"
                            self.vwGold.borderColor = sub.isSubscribed! ? selectedColor : .none
                            self.vwGold.borderWidth = sub.isSubscribed! ? 1.5 : 0
                            
                        default:
                            self.lblPlatinumName.text = sub.name
                            self.lblPlatinumPrine.text = "$\(sub.price ?? 0)"
                            self.vwPlatinum.borderColor = sub.isSubscribed! ? selectedColor : .none
                            self.vwPlatinum.borderWidth = sub.isSubscribed! ? 1.5 : 0
                        }
                        
                    }
                    self.updateBtnTxt()
                }
            }
        }
    }
    
    private func updateBtnTxt()
    {
        let btnClr = UIColor(red: 26/255, green: 16/255, blue: 54/255, alpha: 1.0)
        self.btnBasicSubscribe.removeTarget(self, action: nil, for: .allEvents)
        self.btnGoldSubscribe.removeTarget(self, action: nil, for: .allEvents)
        self.btnPlatinumSubscribe.removeTarget(self, action: nil, for: .allEvents)
        if let sub = self.arrSubscription.first(where: {$0.isSubscribed!})
        {
            self.GalleryOL.isHidden = false

            switch sub.id {
            case 1:
                self.btnBasicSubscribe.setTitle("Subscribed", for: .normal)
                self.btnGoldSubscribe.setTitle("Upgrade", for: .normal)
                self.btnPlatinumSubscribe.setTitle("Upgrade", for: .normal)
                self.btnBasicSubscribe.isEnabled = false
                self.btnGoldSubscribe.isEnabled = true
                self.btnPlatinumSubscribe.isEnabled = true
                self.btnGoldSubscribe.addTarget(self, action: #selector(self.subscriptionUpgrade(snder:)), for: .touchUpInside)
                self.btnPlatinumSubscribe.addTarget(self, action: #selector(self.subscriptionUpgrade(snder:)), for: .touchUpInside)
                self.vwBtnBasic.backgroundColor = .lightGray
                self.vwBtnGold.backgroundColor = btnClr
                self.vwBtnPlatinum.backgroundColor = btnClr
            case 2:
                self.btnGoldSubscribe.isEnabled = false
                self.btnBasicSubscribe.setTitle("Downgrade", for: .normal)
                self.btnGoldSubscribe.setTitle("Subscribed", for: .normal)
                self.btnPlatinumSubscribe.setTitle("Upgrade", for: .normal)
                self.btnBasicSubscribe.isEnabled = true
                self.btnGoldSubscribe.isEnabled = false
                self.btnPlatinumSubscribe.isEnabled = true
                self.btnBasicSubscribe.addTarget(self, action: #selector(self.subscriptionDowngrade(snder:)), for: .touchUpInside)
                self.btnPlatinumSubscribe.addTarget(self, action: #selector(self.subscriptionUpgrade(snder:)), for: .touchUpInside)
                self.vwBtnBasic.backgroundColor = btnClr
                self.vwBtnGold.backgroundColor = .lightGray
                self.vwBtnPlatinum.backgroundColor = btnClr
            default:
                self.btnBasicSubscribe.setTitle("Downgrade", for: .normal)
                self.btnGoldSubscribe.setTitle("Downgrade", for: .normal)
                self.btnPlatinumSubscribe.setTitle("Subscribed", for: .normal)
                self.btnBasicSubscribe.isEnabled = true
                self.btnGoldSubscribe.isEnabled = true
                self.btnPlatinumSubscribe.isEnabled = false
                self.btnBasicSubscribe.addTarget(self, action: #selector(self.subscriptionDowngrade(snder:)), for: .touchUpInside)
                self.btnGoldSubscribe.addTarget(self, action: #selector(self.subscriptionDowngrade(snder:)), for: .touchUpInside)
                self.vwBtnBasic.backgroundColor = btnClr
                self.vwBtnGold.backgroundColor = btnClr
                self.vwBtnPlatinum.backgroundColor = .lightGray
            }
        }
        else
        {
            self.GalleryOL.isHidden = true
        }
    }
    
    @objc private func subscriptionDowngrade(snder:UIButton)
    {
        self.updateSubscription(isDowngrade: true, btnTag: snder.tag)
    }
    
    @objc private func subscriptionUpgrade(snder:UIButton)
    {
        self.updateSubscription(isDowngrade: false, btnTag: snder.tag)
    }
    
    @objc private func updateSubscription(isDowngrade:Bool, btnTag:Int)
    {
        let subs = self.arrSubscription[btnTag - 1]
        if isDowngrade
        {
            Alert.sharedInstance.alertWindow(title: "Alert!", message: "Are you sure you want to downgrade?") { result in
                if result {
                    self.downgradSubscription(subs: subs)
                }
            }
        }
        else
        {
            if let vc = AppStoryboard.Subscriptions.instance.instantiateViewController(withIdentifier: "PaymentMethodSubscribeVC") as? PaymentMethodSubscribeVC
            {
                
                vc.amount = Double(subs.price ?? 0)
                vc.subscriptionName = subs.name ?? ""
                vc.subscriptionID = "\(subs.id ?? 0)"
                vc.subscriptionType = .DesignYourself
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    private func downgradSubscription(subs:SubscriptionListDM) {
        
        self.showLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false

        let params = [
            "subscriptionId": subs.id ?? 0
        ] as [String : Any]
        
        self.viewModel.postAvatarDowngradSubscription(params: params)
    }

    func didAvatarDowngradSubscription() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.avatarDowngradSubscriptionResponse?.isSuccess ?? false {
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.avatarDowngradSubscriptionResponse?.message ?? "Some error occured") { result in
                if result {
                    self.getSubscriptionData()
                }
            }
        } else {
            self.showToast(message: self.viewModel.avatarDowngradSubscriptionResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}
