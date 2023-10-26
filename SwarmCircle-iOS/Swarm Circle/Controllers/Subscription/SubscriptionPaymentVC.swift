//
//  SubscriptionPaymentVC.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 12/09/2023.
//

import UIKit

class SubscriptionPaymentVC: BaseViewController {

    @IBOutlet weak var receiverFullNameLbl: UILabel!
    @IBOutlet weak var receiverWalletIdLbl: UILabel!
    @IBOutlet weak var cardNumberTitleLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var paymentMethodLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var feesLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var checkmarkBtn: UIButton!
    @IBOutlet var confirmTransferBtn: UIButton!
    
    
    var amount: Double?
    var subscriptionName = ""
    var subscriptionID = ""
    var fees:Double?
    var subscriptionType:SubscriptionType?
    
    var cardNumber: String? // Default Card (Stripe) eg: ****** 4566, New Card (Stripe) eg: New card, PayPal eg: either hide the field or New card
    var paymentGateway: PaymentGateway? // Stripe or PayPal
    
    // Below 3 variable are use when deposit with a new card (Stripe)
    var isNewCardStripe: Bool?
    var paymentMethodID: String?
    var cardType: String?
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
        
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        
        self.receiverFullNameLbl.text = PreferencesManager.getWalletDetail()?.walletName ?? ""
        self.receiverWalletIdLbl.text = self.subscriptionName 
        
        self.cardNumberLbl.text = cardNumber ?? ""
        
        guard let paymentGateway else {
            popOnErrorAlert("Payment Gateway missing")
            return
        }
        
        self.paymentMethodLbl.text = paymentGateway.rawValue
        
        guard let amount else {
            popOnErrorAlert("Amount missing")
            return
        }
        
        self.amountLbl.text = "$ \(amount)"
        self.totalLbl.text = "$ \(amount - 0)" // replace 0 by fees later
        //self.pfLbl.text = "$ \(self.platformFees)"
        
        if paymentGateway == .Wallet
        { // Hide Card complete details (Title + number) if wallet method is selected.
        
            self.cardNumberTitleLbl.text = ""
//            self.confirmTransferBtn.tintColor = .clear
//            self.confirmTransferBtn.backgroundColor = .clear
            
            //adding fees
            self.fees = 0.0
            self.feesLbl.text = "$ " + String(format: "%.2f", self.fees!)
            
        } else if paymentGateway == .Stripe {
            
            self.cardNumberTitleLbl.text = "Card Number:"
            self.confirmTransferBtn.tintColor = .white
            self.confirmTransferBtn.backgroundColor = UIColor(named: "BackgroundColor")
            
            //adding fees
            self.fees = ((amount + 3.30)/0.971) - (amount)
            self.feesLbl.text = "$ " + String(format: "%.2f", self.fees ?? 0.0)
            // Continue if new or default card value is defined if method is stripe.
            guard let _ = isNewCardStripe else {
                popOnErrorAlert("Stripe Card not defined (New/Default)")
                return
            }
        }
        self.amount = amount //+ self.fees! + self.platformFees
        self.totalLbl.text = "$ " + String(format: "%.2f", self.amount! + self.fees!)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
    }
    
    // MARK: - Subscribe with Wallet
    func subscribeWithWallet() {
        
        self.showLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false

        let params = [
            "subscriptionId": Int(self.subscriptionID)!,
            "amount": String(format: "%.1f", self.amount! + self.fees!)
        ] as [String : Any]
        if self.subscriptionType == .AppSubscription
        {
            self.viewModel.subscriptionThroughWallet(params: params)
        }
        else
        {
            self.viewModel.avatarSubscriptionThroughWallet(params: params)
        }
        
    }
    // MARK: - Deposit with new Card (Stripe)
    func subscribeWithNewCardStripe() {
        
        self.showLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false

        let params = [
            "cardNumber": "\(self.cardNumber!.suffix(4))",
              "paymentMethodId": self.paymentMethodID!,
              "cardType": self.cardType!,
              "isSave": self.cardType! == "" ? false : true,
              "amount": self.amount! + self.fees!,
            "subscriptionId": Int(self.subscriptionID)!
        ] as [String : Any]
        if self.subscriptionType == .AppSubscription
        {
            self.viewModel.subscriptionThroughNewCardStripe(params: params)
        }
        else
        {
            self.viewModel.avatarSubscriptionThroughNewCard(params: params)
        }
        
    }
    
    // MARK: - Deposit with default Card (Stripe)
    func subscribeWithDefaultCardStripe() {
        
        self.showLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        let params = [
            "subscriptionId": Int(self.subscriptionID)!,
            "amount": String(format: "%.1f", self.amount! + self.fees!)
        ] as [String : Any]
        if self.subscriptionType == .AppSubscription
        {
            self.viewModel.subscriptionThroughSaveCardStripe(params: params)
        }
        else
        {
            self.viewModel.avatarSubscriptionThroughSaveCard(params: params)
        }
        
    }
        
    // MARK: - Checkmark Button Tapped
    @IBAction func checkmarkBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
    }
    
    // MARK: - Terms and Conditions Button Tapped
    @IBAction func termsNConditionBtnTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "AppInfoVC") as? AppInfoVC {
            vc.sourceCell = .termsNConditions
            self.navigationController?.pushViewController(vc, animated: true)
        }
//        guard let url = URL(string: "https://216.108.238.109:7926/about/terms") else { return }
//        UIApplication.shared.open(url)
    }
    
    // MARK: - Confirm Transfer Button Tapped
    @IBAction func confirmTransferBtnTapped(_ sender: UIButton) {
        
        if self.checkmarkBtn.isSelected {
            if self.paymentGateway == .Wallet
            {
                self.subscribeWithWallet()
            }
            else
            {
                self.isNewCardStripe! ? self.subscribeWithNewCardStripe() : self.subscribeWithDefaultCardStripe()
            }
            
        }
        else {
            self.showToast(message: "Please agree Terms & conditions to Proceed", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Cancel Button Tapped
    @IBAction func cancelBtnTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SubscriptionPaymentVC: NetworkResponseProtocols {
    
    // MARK: - Deposit with New card Response (Stripe)
    func didSubscriptionThroughNewCard() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.subscriptionThroughNewCardResponse?.isSuccess ?? false {
            NotificationCenter.default.post(name: .refreshSubscription, object: nil)
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.subscriptionThroughNewCardResponse?.message ?? "Some error occured") { result in
                if result {
                    self.popToSubscription()
                }
            }
        } else {
            self.showToast(message: self.viewModel.subscriptionThroughNewCardResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Deposit with default card Response (Stripe)
    func didSubscriptionThroughSaveCard() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.subscriptionThroughSaveCardResponse?.isSuccess ?? false {
            NotificationCenter.default.post(name: .refreshSubscription, object: nil)
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.subscriptionThroughSaveCardResponse?.message ?? "Some error occured") { result in
                if result {
                    self.popToSubscription()
                }
            }
        } else {
            self.showToast(message: self.viewModel.subscriptionThroughSaveCardResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: -  Response wallet
    func didSubscriptionThroughWallet() {
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.subscriptionThroughWalletResponse?.isSuccess ?? false {
            
            // refresh wallet amount in MyWalletVC
            NotificationCenter.default.post(name: .refreshSubscription, object: nil)
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.subscriptionThroughWalletResponse?.message ?? "Some error occured") { result in
                if result {
                    self.popToSubscription()
                }
            }
        } else {
            self.showToast(message: self.viewModel.subscriptionThroughWalletResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }

    }
    
    private func popToSubscription()
    {
        for controller in self.navigationController!.viewControllers as Array {
                if controller.isKind(of: SubscriptionListVC.self) {
                    _ =  self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
                else if controller.isKind(of: AvatarSubscriptionListVC.self) {
                    _ =  self.navigationController!.popToViewController(controller, animated: true)
                    break
                }
            }
    }
    
}

extension SubscriptionPaymentVC {
    
    // MARK: - Design your self
    
    func didAvatarSubscriptionThroughNewCard() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.avatarSubscriptionThroughNewCardResponse?.isSuccess ?? false {
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.avatarSubscriptionThroughNewCardResponse?.message ?? "Some error occured") { result in
                if result {
                    // refresh wallet amount in MyWalletVC
                    NotificationCenter.default.post(name: .refreshAvatarSubscription, object: nil)
                    self.popToSubscription()
                }
            }
        } else {
            self.showToast(message: self.viewModel.avatarSubscriptionThroughNewCardResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Deposit with default card Response (Stripe)
    func didAvatarSubscriptionThroughSaveCard() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.avatarSubscriptionThroughSaveCardResponse?.isSuccess ?? false {
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.avatarSubscriptionThroughSaveCardResponse?.message ?? "Some error occured") { result in
                if result {
                    // refresh wallet amount in MyWalletVC
                    NotificationCenter.default.post(name: .refreshAvatarSubscription, object: nil)
                    self.popToSubscription()
                }
            }
        } else {
            self.showToast(message: self.viewModel.avatarSubscriptionThroughSaveCardResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: -  Response wallet
    func didAvatarSubscriptionThroughWallet() {
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.avatarSubscriptionThroughWalletResponse?.isSuccess ?? false {
            
            
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.avatarSubscriptionThroughWalletResponse?.message ?? "Some error occured") { result in
                if result {
                    // refresh wallet amount in MyWalletVC
                    NotificationCenter.default.post(name: .refreshAvatarSubscription, object: nil)
                    self.popToSubscription()
                    
                }
            }
        }
        else
        {
            self.showToast(message: self.viewModel.avatarSubscriptionThroughWalletResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}


