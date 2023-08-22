//
//  InformationVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 17/11/2022.
//

import UIKit

class AppInfoVC: BaseViewController {

    @IBOutlet weak var iconImgView: UIImageView!
    @IBOutlet weak var mainHeadingLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var infoList: [AppInfoDM] = []
    
    let viewModel = ViewModel()
    
    enum SourceCell: String {
        case privacyPolicy
        case termsNConditions
    }
    
    var sourceCell: SourceCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    func initUI() {
        
        //tableView Nib registration
        self.tableView.register(UINib(nibName: "HeadingInfoCell", bundle: nil), forCellReuseIdentifier: "HeadingInfoCell")
    }
    
    // MARK: - Load data from API
    func initVariable() {
        
        guard let sourceCell else {
            popOnErrorAlert("Source cell not selected")
            return
        }
        
        self.viewModel.delegateNetworkResponse = self
        
        self.showLoader()
        
        switch sourceCell {
            
        case .termsNConditions:
            self.iconImgView.image = UIImage(named: "cost-estimate")
            self.mainHeadingLbl.text = "Terms & Conditions"
            self.fetchTermsNConditions()
            
        case .privacyPolicy:
            self.iconImgView.image = UIImage(named: "contract")
            self.mainHeadingLbl.text = "Privacy Policy"
            self.fetchPrivacyPolicy()
            
//        default:
//            print("Switch Default case")
        }
    }
    
    func fetchTermsNConditions() {
        self.viewModel.getTermsNConditions()
    }
    
    func fetchPrivacyPolicy() {
        self.viewModel.getPrivacyPolicy()
    }
}

// MARK: - UITableView Configuration
extension AppInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.infoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "HeadingInfoCell") as? HeadingInfoCell else {
            return UITableViewCell()
        }
        cell.configureCell(info: self.infoList[indexPath.row])
        return cell
    }
}

extension AppInfoVC: NetworkResponseProtocols {
    
    func didGetTermsNConditions() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.termsNConditionsResponse?.data {
            self.infoList = unwrappedList
            self.tableView.reloadData()
        }
        else {
            self.showToast(message: self.viewModel.termsNConditionsResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
    
    func didGetPrivacyPolicy() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.privacyPolicyResponse?.data {
            self.infoList = unwrappedList
            self.tableView.reloadData()
        }
        else {
            self.showToast(message: self.viewModel.privacyPolicyResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
}
