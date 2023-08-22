//
//  MyAccountVC.swift
//  Swarm Circle
//
//  Created by Macbook on 08/07/2022.
//

import UIKit

class MyAccountVC: BaseViewController {

    @IBOutlet weak var myWalletCardView: CardViewMaterial!
    @IBOutlet weak var myTransactionCardView: CardViewMaterial!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var walletIdLbl: UILabel!
    @IBOutlet weak var chainLbl: UILabel!
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var walletAddressLbl: UILabel!
    @IBOutlet weak var userNameOnCardLbl: UILabel!
    @IBOutlet weak var walletIdOnCrdLbl: UILabel!
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
//        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        self.myWalletCardView.cornerRadius = (self.myWalletCardView.frame.height / 2) - 6
        self.myTransactionCardView.cornerRadius = (self.myTransactionCardView.frame.height / 2) - 6
        
        if let walletDetail = PreferencesManager.getWalletDetail() {
            self.fullNameLbl.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
            self.userNameOnCardLbl.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
            self.walletIdLbl.text = walletDetail.walletID ?? ""
            self.walletIdOnCrdLbl.text = walletDetail.walletID ?? ""
            self.chainLbl.text = walletDetail.chain ?? ""
            self.currencyLbl.text = walletDetail.currency ?? ""
            self.walletAddressLbl.text = walletDetail.address ?? ""
        }
    }
    
//    // MARK: - Load data from API
//    func initVariable() {
//        self.viewModel.delegateNetworkResponse = self
//        self.showLoader()
//        self.getWalletDetail()
//    }
    
//    // MARK: - Get Wallet Detail
//    func getWalletDetail() {
//        self.viewModel.getWalletDetail()
//    }
    
    // MARK: - My Wallet Image Tapped
    @IBAction func myWalletImgTapped(_ sender: UITapGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
        self.delegate?.moveToWalletTab()
    }
    
    // MARK: - My Transaction Image Tapped
    @IBAction func myTransactionImgTapped(_ sender: UITapGestureRecognizer) {
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "TransactionsVC") as? TransactionsVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Copy Button Tapped
    @IBAction func copyBtnTapped(_ sender: UIButton) {
        UIPasteboard.general.string = walletAddressLbl.text
        self.showToast(message: "Wallet address copied to clipboard", toastType: .black)
    }
}

//extension MyAccountVC: NetworkResponseProtocols {
//
//    // MARK: - Wallet Detail Response
//    func didGetWalletDetail() {
//
//        self.hideLoader()
//
//        if let walletDetail = viewModel.walletDetailResponse?.data {
//            self.fullNameLbl.text = walletDetail.walletName ?? ""
//            self.walletIdLbl.text = walletDetail.walletID ?? ""
//            self.chainLbl.text = walletDetail.chain ?? ""
//            self.currencyLbl.text = walletDetail.currency ?? ""
//            self.walletAddressLbl.text = walletDetail.address ?? ""
//
//        } else {
//            self.showToast(message: self.viewModel.walletDetailResponse?.message ?? "Some error occured", toastType: .red)
//        }
//    }
//}
