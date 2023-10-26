//
//  AddStripeCardVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 27/09/2022.
//

import UIKit
import Stripe

class AddStripeCardVC: BaseViewController {

    @IBOutlet weak var cardTextField: STPPaymentCardTextField!
    @IBOutlet var checkmarkBtn: UIButton!
    @IBOutlet var payBtn: UIButton!
    
    
    var amount: Double?
    var isFromSubscription = false
    var subscriptionType:SubscriptionType?
    
    var subscriptionName = ""
    var subscriptionID = ""
//    var clientSecret: String = ""
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = self.isFromSubscription ? "Back To Subscription" : "Back To Deposit"
    }

    // MARK: - Get card details (type, last 4 digits, paymentMethodID i.e. Stripe id)
    func getCardDetails(res: @escaping(String, String, String) -> Void) {
        
        self.showLoader()
        
        let cardParams = self.cardTextField.cardParams
        
        let paymentMethodParams = STPPaymentMethodParams(card: cardParams, billingDetails: nil, metadata: nil)
        
        STPAPIClient.shared.createPaymentMethod(with: paymentMethodParams) { (response, error) in
            
            self.hideLoader()
            
            guard let stripeId = response?.stripeId else {
                self.showToast(message:  error?.localizedDescription ?? "Some error occured", toastType: .red)
                return
            }
            
            // Card type and last 4 digits are required if we are not saving the card.
            if self.checkmarkBtn.isSelected {
                guard let cardLast4Digits = response?.card?.last4, let cardType = response?.card?.brand.description else {
                    self.showToast(message:  error?.localizedDescription ?? "Some error occured", toastType: .red)
                    return
                }
                res(stripeId, "**** **** **** \(cardLast4Digits)", cardType) // if card type is defined then we will save the card.
                return
            }
            res(stripeId, "New card", "") // Card type and last 4 digits are optional if we are not saving the card.
        }
    }
    
    // MARK: - Checkmark Button Tapped
    @IBAction func checkmarkBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        self.payBtn.isSelected = !self.payBtn.isSelected
    }
    
    // MARK: - Pay Button Tapped
    @IBAction func payBtnTapped(_ sender: UIButton) {
        
        self.cardTextField.resignFirstResponder()
        
        if self.validateCardInfo() {
        
            self.getCardDetails { paymentMethodId, cardLast4Digits, cardType in
                if self.isFromSubscription
                {
                    if let vc = AppStoryboard.Subscriptions.instance.instantiateViewController(withIdentifier: "SubscriptionPaymentVC") as? SubscriptionPaymentVC
                    {
                        vc.amount = self.amount
                        vc.isNewCardStripe = true
                        vc.paymentMethodID = paymentMethodId
                        vc.cardNumber = cardLast4Digits
                        vc.cardType = cardType
                        vc.amount = self.amount!
                        vc.subscriptionName = self.subscriptionName
                        vc.subscriptionID = self.subscriptionID
                        vc.paymentGateway = .Stripe
                        vc.subscriptionType = self.subscriptionType
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                else
                {
                    if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "ConfirmPaymentVC") as? ConfirmPaymentVC {
                        
                        vc.isNewCardStripe = true
                        vc.paymentMethodID = paymentMethodId
                        vc.cardNumber = cardLast4Digits
                        vc.cardType = cardType
                        vc.amount = self.amount!
                        
                        vc.paymentGateway = .Stripe
                        
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
                
            }
        }
    }
    
    // MARK: - Validate Card
    func validateCardInfo() -> Bool {
        
        let paymentParams = cardTextField.cardParams
        
        if (paymentParams.number ?? "" == "") {
            self.showToast(message: "Card Number required", toastType: .red)
            return false
        }
        if paymentParams.expMonth == nil || paymentParams.expYear == nil {
            self.showToast(message: "Expiry date required", toastType: .red)
            return false
        }
        if (paymentParams.cvc ?? "" == "") {
            self.showToast(message: "CVC required", toastType: .red)
            return false
        }
//        if !cardTextField.isValid {
//            self.showToast(message: "Invalid card info", toastType: .red)
//            return false
//        }
        return true
    }
}

// This extension apparently has no use, so this can be removed later
extension AddStripeCardVC: STPAuthenticationContext {
    func authenticationPresentingViewController() -> UIViewController {
        return self
    }
}
