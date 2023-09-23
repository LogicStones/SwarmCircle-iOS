//
//  PaymentMethodSubscribeVC.swift
//  Swarm Circle
//
//  Created by Abubakar Gulzar on 12/09/2023.
//

import UIKit

class PaymentMethodSubscribeVC: BaseViewController {

    
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var amountLbl: UILabel!
    
    var actions: [(String, UIAlertAction.Style)] = [
        ("Stripe", UIAlertAction.Style.default),
        ("Wallet", UIAlertAction.Style.default),
        ("Cancel", UIAlertAction.Style.cancel)
    ]
    
    var amount: Double?
    
    var subscriptionName = ""
    var subscriptionID = ""
    let viewModel = ViewModel()
    
    var stripeCardList: [CardDM] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
//
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Subscription"
    }
    
    // MARK: - Configuring UI when loading
    func initUI(){
        self.tableView.allowsSelection = true
        self.tableView.register(UINib(nibName: "CardsCell", bundle: nil), forCellReuseIdentifier: "CardsCell")
        self.amountLbl.text = "$\(amount!)"
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.getStripeCardList()
    }
    
    // MARK: - Get Stripe Card List
    func getStripeCardList() {
        self.viewModel.getStripeCardList()
    }
    
    func makeDefaultCardStripe(cardIdentifier: String) {
        
        self.showLoader()
        
        let params = [
            "cardIdentifier": cardIdentifier
        ] as [String : Any]
        
        self.viewModel.makeDefaultCardStripe(params: params)
    }
    
    // MARK: - Get Payment Intent
    func getPaymentIntentStripe() {
        self.showLoader()
        self.viewModel.getPaymentIntent()
    }
    
    @IBAction func editAmountPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Stripe Button Tapped
    @IBAction func stripeBtnTapped(_ sender: UIButton) {
        self.getPaymentIntentStripe()
    }
    
    // MARK: - PayPal Button Tapped
    @IBAction func payPalBtnTapped(_ sender: UIButton) {
        if let vc = AppStoryboard.Subscriptions.instance.instantiateViewController(withIdentifier: "SubscriptionPaymentVC") as? SubscriptionPaymentVC {
            vc.amount = self.amount
            vc.paymentGateway = .Wallet
            vc.subscriptionName = self.subscriptionName
            vc.subscriptionID = self.subscriptionID
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Next Button Tapped
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        
        if self.stripePaymentValidation() {
            
            if let vc = AppStoryboard.Subscriptions.instance.instantiateViewController(withIdentifier: "SubscriptionPaymentVC") as? SubscriptionPaymentVC {
                
                vc.amount = self.amount
                vc.isNewCardStripe = false
                vc.subscriptionName = self.subscriptionName
                vc.subscriptionID = self.subscriptionID
                guard let indexPath = self.tableView.indexPathForSelectedRow else {
                    return
                }
                vc.cardNumber = "**** **** **** \(self.stripeCardList[indexPath.row].cardNumber ?? "")"
                vc.paymentGateway = .Stripe
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func stripePaymentValidation() -> Bool {
        if self.stripeCardList.isEmpty {
            self.showToast(message: "Please add a card to proceed", toastType: .red)
            return false
        }
        return true
    }
    
    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async {
            super.updateViewConstraints()
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
    }

}

// MARK: - TableView Configuration
extension PaymentMethodSubscribeVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stripeCardList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardsCell") as? CardsCell else {
            return UITableViewCell()
        }
        cell.configureCell(info: stripeCardList[indexPath.row])
        
        if stripeCardList[indexPath.row].isDefault ?? false {
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let cardIdentifier = stripeCardList[indexPath.row].identifier else {
            self.showToast(message: "Some error occured", toastType: .red)
            return
        }
        self.makeDefaultCardStripe(cardIdentifier: cardIdentifier)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
    
}

extension PaymentMethodSubscribeVC: NetworkResponseProtocols {
    
    // MARK: - Card List Response
    func didGetStripeCardList() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.stripeCardListResponse?.data {
            
            self.stripeCardList.removeAll()
            
            self.stripeCardList.append(contentsOf: unwrappedList)
            
            self.tableView.reloadData()
        } else {
            self.showToast(message: viewModel.stripeCardListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
        
    }
    
    // MARK: - Default card changed response
    func didMakeDefaultCardStripe() {
        
        self.hideLoader()
        
        if viewModel.defaultCardStripeResponse?.isSuccess ?? false {
            self.showToast(message: "Successfully Changed Default Card", delay: 2, toastType: .green)
        } else {
            self.showToast(message: self.viewModel.defaultCardStripeResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Payment Intent Response
    func didGetPaymentIntentStripe() {
        
        self.hideLoader()
        
        if viewModel.paymentIntentStripeResponse?.isSuccess ?? false {
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "AddStripeCardVC") as? AddStripeCardVC {
//                vc.clientSecret = clientSecret
                vc.amount = self.amount
                vc.isFromSubscription = true
                vc.subscriptionName = self.subscriptionName
                vc.subscriptionID = self.subscriptionID
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else {
            self.showToast(message: self.viewModel.paymentIntentStripeResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }

    }
}

extension PaymentMethodSubscribeVC: AppProtocol {
    func refreshCardList() {
        self.getStripeCardList()
    }
}
