//
//  ExploreCircleVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 22/08/2022.
//

import UIKit

class ExploreCircleVC: BaseViewController {

    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!

    var pageNumber: Int = 1
    var circleList: [ExploreCircleDM] = []
    
    let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    func initUI() {
        tableView.register(UINib(nibName: "SuggestedCircleCell", bundle: nil), forCellReuseIdentifier: "SuggestedCircleCell")
    }
    
    // MARK: - Load data from API
    func initVariable() {
        
        viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetCircleList()
    }
    
    // MARK: - Fetch Circle List
    func postGetCircleList() {
        self.viewModel.getCircleList(pageNumber: self.pageNumber, searchText: self.searchTF.text ?? "")
    }
    
    // MARK: - Send/Cancel Circle Join Request
    func sendCircleJoinRequest(circleIdentifier: String, status: Bool, indexPath: IndexPath) {
        self.viewModel.sendCircleJoinRequest(params: ["circleIdentifier": circleIdentifier, "status": status], indexPath: indexPath)
    }
    
    // MARK: - Search/Filter Circle List (using API)
    @IBAction func searchNCloseBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            self.searchTF.becomeFirstResponder()
            self.searchTF.isHidden = false
        } else {
            self.searchTF.resignFirstResponder()
            self.searchTF.isHidden = true
            
            self.searchTF.text = ""
            self.pageNumber = 1
            self.postGetCircleList()
        }
    }
}

// MARK: - TableView Configuration
extension ExploreCircleVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.circleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestedCircleCell") as? SuggestedCircleCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(circleInfo: self.circleList[indexPath.row])
        cell.actionBtn.isSelected = self.circleList[indexPath.row].isRequestSent ?? false
        
        cell.actionBtn.tag = indexPath.row
        cell.actionBtn.addTarget(self, action: #selector(self.joinBtnTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.circleList.count - 10 && self.circleList.count < viewModel.circleListResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.postGetCircleList()
        }
    }
    
    // MARK: - Join Button Tapped Action
    @objc func joinBtnTapped(_ sender: ToggleButton) {
        
        guard
            let circleIdentifier = circleList[sender.tag].identifier,
            let isRequestSent = circleList[sender.tag].isRequestSent
        else {
            return
        }

        if sender.isSelected {
            sendCircleJoinRequest(circleIdentifier: circleIdentifier, status: false, indexPath: IndexPath(row: sender.tag, section: 0))
        } else {
            sendCircleJoinRequest(circleIdentifier: circleIdentifier, status: true, indexPath: IndexPath(row: sender.tag, section: 0))
        }
        circleList[sender.tag].isRequestSent = !isRequestSent
        tableView.reloadData()
    }
}

extension ExploreCircleVC: NetworkResponseProtocols {

    // MARK: - Circle List Response
    func didGetCircleList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.circleListResponse?.data {
            
            self.pageNumber == 1 ? self.circleList.removeAll() : ()
            
            self.circleList.append(contentsOf: unwrappedList)
            
            self.tableView.reloadData()
            
            self.circleList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: self.viewModel.circleListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.circleList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
    
    // MARK: - Send/Cancel Join Circle Request Response
    func didSentCircleJoinRequest(indexPath: IndexPath) {

        if viewModel.circleJoinRequestSentResponse?.data ?? false {
            self.showToast(message: self.viewModel.circleJoinRequestSentResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
        }
        else {
            self.showToast(message: self.viewModel.circleJoinRequestSentResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.circleList[indexPath.row].isRequestSent = !self.circleList[indexPath.row].isRequestSent!
            tableView.reloadData()
        }
    }
}

extension ExploreCircleVC: UITextFieldDelegate {
    
    // MARK: - Search Button Tapped on keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTF.resignFirstResponder()
        self.pageNumber = 1
        self.postGetCircleList()
        return true
    }
}

