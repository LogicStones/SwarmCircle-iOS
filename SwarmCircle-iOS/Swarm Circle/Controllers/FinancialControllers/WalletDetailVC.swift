//
//  WalletDetailVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 21/09/2022.
//

import UIKit

class WalletDetailVC: BaseViewController {
    
    
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var walletIdLbl: UILabel!
    @IBOutlet weak var chainLbl: UILabel!
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var walletAddressLbl: UILabel!
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
//        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI() {
        if let walletDetail = PreferencesManager.getWalletDetail() {
            self.fullNameLbl.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
            self.walletIdLbl.text = walletDetail.walletID ?? ""
            self.chainLbl.text = walletDetail.chain ?? ""
            self.currencyLbl.text = walletDetail.currency ?? ""
            self.walletAddressLbl.text = walletDetail.address ?? ""
        }
    }
    
    // MARK: - Load data from API
    func initVariable() {
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // remove dispatch queue after putting a delay in loader.
//
//            self.viewModel.delegateNetworkResponse = self
//            self.showLoader()
//            self.getWalletDetail()
//        }
    }
    
//    // MARK: - Get Wallet Detail
//    func getWalletDetail() {
//        self.viewModel.getWalletDetail()
//    }
    
    // MARK: - Close Button Tapped
    @IBAction func crossBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Copy Button Tapped
    @IBAction func copyBtnTapped(_ sender: UIButton) {
        UIPasteboard.general.string = walletAddressLbl.text
        self.showToast(message: "Wallet address copied to clipboard", toastType: .black)
    }
}

//extension WalletDetailVC: NetworkResponseProtocols {
//
//    // MARK: - Wallet Detail Response
//    func didGetWalletDetail() {
//
//        self.hideLoader()
//
//        if let walletDetail = viewModel.walletDetailResponse?.data {
//
//            self.fullNameLbl.text = walletDetail.walletName ?? ""
//            self.walletIdLbl.text = walletDetail.walletID ?? ""
//            self.chainLbl.text = walletDetail.chain ?? ""
//            self.currencyLbl.text = walletDetail.currency ?? ""
//            self.walletAddressLbl.text = walletDetail.address ?? ""
//
//        } else {
//            self.showToast(message: "\(viewModel.walletDetailResponse?.message ?? "Something went wrong")", toastType: .red)
//        }
//    }
//}
