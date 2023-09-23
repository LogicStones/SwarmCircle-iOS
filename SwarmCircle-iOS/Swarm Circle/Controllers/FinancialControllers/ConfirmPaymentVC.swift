//
//  ConfirmPaymentVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 27/09/2022.
//

import UIKit
import PayPalCheckout

enum PaymentGateway: String {
    case Stripe
    case PayPal
    case Wallet
}

class ConfirmPaymentVC: BaseViewController {
    
    @IBOutlet weak var receiverFullNameLbl: UILabel!
    @IBOutlet weak var receiverWalletIdLbl: UILabel!
    @IBOutlet weak var cardNumberTitleLbl: UILabel!
    @IBOutlet weak var cardNumberLbl: UILabel!
    @IBOutlet weak var paymentMethodLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var feesLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet var pfLbl: UILabel!
    @IBOutlet weak var checkmarkBtn: UIButton!
    @IBOutlet var confirmTransferBtn: UIButton!
    
    
    let payPalBtnContainer = PaymentButtonContainer()
    
    var amount: Double?
    var fees:Double?
    var platformFees = 3.0
    
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
        self.receiverWalletIdLbl.text = PreferencesManager.getWalletDetail()?.walletID ?? ""
        
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
        self.pfLbl.text = "$ \(self.platformFees)"
        
        if paymentGateway == .PayPal { // Hide Card complete details (Title + number) if PayPal method is selected.
            
            self.addPayPalButton()
            self.configurePayPalCheckout()
            
            self.cardNumberTitleLbl.text = ""
            self.confirmTransferBtn.tintColor = .clear
            self.confirmTransferBtn.backgroundColor = .clear
            
            //adding fees
            self.fees = ((amount + 3.49)/0.9651) - (amount + self.platformFees)
            self.feesLbl.text = "$ " + String(format: "%.2f", self.fees!)
            
        } else if paymentGateway == .Stripe {
            
            self.cardNumberTitleLbl.text = "Card Number:"
            self.confirmTransferBtn.tintColor = .white
            self.confirmTransferBtn.backgroundColor = UIColor(named: "BackgroundColor")
            
            //adding fees
            self.fees = ((amount + 3.30)/0.971) - (amount + self.platformFees)
            self.feesLbl.text = "$ " + String(format: "%.2f", self.fees ?? 0.0)
            
            // Continue if new or default card value is defined if method is stripe.
            guard let _ = isNewCardStripe else {
                popOnErrorAlert("Stripe Card not defined (New/Default)")
                return
            }
            
        }
        self.amount = amount //+ self.fees! + self.platformFees
        self.totalLbl.text = "$ " + String(format: "%.2f", self.amount! + self.fees! + self.platformFees)
    }
    
    // MARK: - Add PayPal Button
    private func addPayPalButton() {
        
        view.addSubview(payPalBtnContainer)
        
        NSLayoutConstraint.activate(
            [
                self.payPalBtnContainer.leadingAnchor.constraint(equalTo: self.confirmTransferBtn.leadingAnchor),
                self.payPalBtnContainer.trailingAnchor.constraint(equalTo: self.confirmTransferBtn.trailingAnchor),
                self.payPalBtnContainer.topAnchor.constraint(equalTo: self.confirmTransferBtn.topAnchor),
                self.payPalBtnContainer.bottomAnchor.constraint(equalTo: self.confirmTransferBtn.bottomAnchor),
                self.payPalBtnContainer.heightAnchor.constraint(equalTo: self.confirmTransferBtn.heightAnchor)
            ]
        )
        self.payPalBtnContainer.cornerRadius = 25
        self.payPalBtnContainer.clipsToBounds = true
        
        self.payPalBtnContainer.isUserInteractionEnabled = false
    }
    
    // MARK: PayPal Checkout Configuration
    private func configurePayPalCheckout() {
        
        Checkout.setCreateOrderCallback { action in
            let total = String(format: "%.2f",self.amount! + self.fees! + self.platformFees)
            let amount = PurchaseUnit.Amount(currencyCode: .usd, value: total)
            let purchaseUnit = PurchaseUnit(amount: amount)
            let order = OrderRequest(intent: .capture, purchaseUnits: [purchaseUnit])
            
            action.create(order: order)
        }
        Checkout.setOnApproveCallback { approval in
            
            self.showLoader()
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            
            approval.actions.capture { response, error in
                
                self.hideLoader()
                self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
                self.navigationController?.navigationBar.isUserInteractionEnabled = true
                
                // Hit sever API here to save checkout details
                if let orderId = response?.data.id {
                    self.saveCheckoutDetailPayPal(orderId: orderId)
                } else {
                    self.showToast(message: error?.localizedDescription ?? "Some error occured", toastType: .red)
                }
                
            }
        }
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
    }
    
    // MARK: - Deposit with new Card (Stripe)
    func depositWithNewCardStripe() {
        
        self.showLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false

        let params = [
            "cardNumber": "\(self.cardNumber!.suffix(4))", // remove ******* and save last 4 digits of card on server.
            "paymentMethodID": self.paymentMethodID!,
            "cardType": self.cardType!,
            "isSave": self.cardType! == "" ? false : true, // if card type is empty then we will save the card.
            "amount": self.amount!
        ] as [String : Any]
        
        self.viewModel.depositWithNewCardStripe(params: params)
    }
    
    // MARK: - Deposit with default Card (Stripe)
    func depositWithDefaultCardStripe() {
        
        self.showLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        let params: [String: Any] = [
            "amount": amount!
        ]
        self.viewModel.depositWithDefaultCardStripe(params: params)
    }
    
    // MARK: - Save User Checkout Detail (PayPal)
    func saveCheckoutDetailPayPal(orderId: String) {
        
        self.showLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
        
        let params: [String: Any] = [
            "orderId": orderId
        ]
        self.viewModel.saveCheckoutOrderDetailPayPal(params: params)
    }
    
    // MARK: - Checkmark Button Tapped
    @IBAction func checkmarkBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        self.payPalBtnContainer.isUserInteractionEnabled = !self.payPalBtnContainer.isUserInteractionEnabled
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
            
            self.isNewCardStripe! ? self.depositWithNewCardStripe() : self.depositWithDefaultCardStripe()
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

extension ConfirmPaymentVC: NetworkResponseProtocols {
    
    // MARK: - Deposit with New card Response (Stripe)
    func didDepositWithNewCardStripe() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.depositWithNewCardStripeResponse?.isSuccess ?? false {
            
            // refresh wallet amount in MyWalletVC
            NotificationCenter.default.post(name: .refreshWalletAmount, object: nil)
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.depositWithNewCardStripeResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            self.showToast(message: self.viewModel.depositWithNewCardStripeResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Deposit with default card Response (Stripe)
    func didDepositWithDefaultCardStripe() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.depositWithDefaultCardStripeResponse?.isSuccess ?? false {
            
            // refresh wallet amount in MyWalletVC
            NotificationCenter.default.post(name: .refreshWalletAmount, object: nil)
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.depositWithDefaultCardStripeResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            self.showToast(message: self.viewModel.depositWithDefaultCardStripeResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    // MARK: - Save Checkout detail Response
    func didSaveCheckoutDetailPayPal() {
        
        self.hideLoader()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        
        if self.viewModel.checkoutPayPalResponse?.isSuccess ?? false {
            
            // refresh wallet amount in MyWalletVC
            NotificationCenter.default.post(name: .refreshWalletAmount, object: nil)
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: self.viewModel.checkoutPayPalResponse?.message ?? "Some error occured") { result in
                if result {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
            
        } else {
            self.showToast(message: self.viewModel.checkoutPayPalResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}


