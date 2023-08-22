//
//  UserListController.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/12/2022.
//

import UIKit

class UserListController: BaseViewController {
    
    @IBOutlet weak var votesCountLbl: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var optionLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var list: [UserListPollOptionDM] = []
    
    var additionalParameters: [AdditionalParametersKey: Any] = [:]
    
    enum AdditionalParametersKey: String {
        case pollId
        case optionId
        case optionText
        case progressPercentage
    }
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUI()
        self.initVariable()
    }
    
    // MARK: - UI initialization
    func initUI() {
        
        self.optionLbl.text = "Loading..."
        self.votesCountLbl.text = "  Votes"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    // MARK: - Load data
    func initVariable() {
        
        self.viewModel.delegateNetworkResponse = self
        
        self.fetchUserList()
    }
    
    // MARK: - Fetch user list
    func fetchUserList() {
        
        guard let pollId = self.additionalParameters[.pollId] as? Int else {
            dismissOnErrorAlert("Poll Id Missing")
            return
        }
        
        guard let optionId = self.additionalParameters[.optionId] as? Int else {
            dismissOnErrorAlert("Option Id Missing")
            return
        }
        
        self.showLoader()
        
        self.viewModel.getUserListOnPollOption(pollId: pollId, optionId: optionId)
    }
    
    // MARK: - Close Button Tapped
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}


// MARK: - TableView Configuration
extension UserListController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell else {
            return UITableViewCell()
        }
        cell.configureCell(list[indexPath.row])
        return cell
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
////        if indexPath.row == self.myCircleList.count - 10 && self.myCircleList.count < self.viewModel.joinedCircleListResponse?.recordCount ?? 0 {
////            self.pageNumber += 1
////            self.postGetJoinedCircleList()
////        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            
            vc.profileIdentifier = list[indexPath.row].identifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension UserListController: NetworkResponseProtocols {
    
    func didGetUserListOnPollOption() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.userListPollOptionResponse?.data {
            
            self.votesCountLbl.text = "\(unwrappedList.count) Votes"
            self.progressView.progress = Float((self.additionalParameters[.progressPercentage] as? Int ?? 0) / 100)
            self.optionLbl.text = self.additionalParameters[.optionText] as? String ?? ""
            
            self.list = unwrappedList
            
            self.tableView.reloadData()

            self.list.isEmpty ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            
        } else {
            dismissOnErrorAlert(self.viewModel.userListPollOptionResponse?.message ?? "Something went wrong")
        }
    }
}

