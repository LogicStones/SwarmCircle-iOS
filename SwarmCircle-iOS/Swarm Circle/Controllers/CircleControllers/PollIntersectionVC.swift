//
//  PollIntersectionVC.swift
//  Swarm Circle
//
//  Created by Macbook on 20/07/2022.
//

import UIKit

class PollIntersectionVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    var pollList: [CirclePollsByCircleIdDM] = []
    
    var circleImageData: Data?
    var circleName: String?
    var circleCategory: String?
    var circlePrivacyType: Int?
    var circleIdArray: [Int]?
    var selectedMemberIdArray: [Int]?
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    func initUI(){
        self.tableView.allowsMultipleSelection = true
        self.tableView.register(UINib(nibName: "PollOptionsViewCell", bundle: nil), forCellReuseIdentifier: "PollOptionsViewCell")
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetPollList()
    }
    
    func postGetPollList() {
        
        guard let circleIdArray else {
            self.hideLoader()
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }
        
        let params: [String: Any] = [
            "circleId" : circleIdArray
        ]
        self.viewModel.getCirclePollsByCircleIdsList(params: params)
    }
    
    func postIntersectCircle() {
        
        guard
            let circleIds = self.circleIdArray,
            let imageData = self.circleImageData,
            let circleName = self.circleName,
            let circleCategory = self.circleCategory,
            let circlePrivacyType = self.circlePrivacyType,
            let memberIds = selectedMemberIdArray
        else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }
        
        self.showLoader()
        
        self.viewModel.intersectCircles(circleIds: circleIds, imageFile: imageData, circleName: Utils.encodeUTF(circleName), memberIds: memberIds, pollIds: getSelectedPollOptionsFromTableView(), circleCategory: Utils.encodeUTF(circleCategory), privacy: circlePrivacyType)
    }
    
    @IBAction func intersectPressed(_ sender: UIButton) {
        self.postIntersectCircle()
    }
    
    func getSelectedPollOptionsFromTableView() -> [Int] {
        
        guard let indexPaths = self.tableView.indexPathsForSelectedRows else { // if no selected cells just return
            return []
        }
        var pollIdArray:[Int] = []
        
        for indexPath in indexPaths {
            if let pollId = pollList[indexPath.row].pollID {
                pollIdArray.append(pollId)
            }
        }
        return pollIdArray
    }

    override func viewWillLayoutSubviews() {
        DispatchQueue.main.async {
            super.updateViewConstraints()
            
            if self.pollList.isEmpty {
                self.tableViewHeight.constant = self.view.frame.height - 250
            } else {
                self.tableViewHeight.constant = self.tableView.contentSize.height
            }
        }
    }

}
extension PollIntersectionVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.pollList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionsViewCell")  as? PollOptionsViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(info: pollList[indexPath.row])
        self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        return cell
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
}

extension PollIntersectionVC: NetworkResponseProtocols {
    
    func didGetCirclePollsByCircleIdsList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.didGetCirclePollsByCircleIdsResponse?.data {
            
            self.pollList.append(contentsOf: unwrappedList)

            unwrappedList.isEmpty ? self.tableView.setEmptyView("", "There are no polls available for the circles, please continue to intersect circles.") : ()
            tableView.reloadData()

        } else {
            self.showToast(message: viewModel.didGetCirclePollsByCircleIdsResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
    
    func didIntersectCircles() {
        
        self.hideLoader()
        
        if self.viewModel.intersectCircleResponse?.isSuccess ?? false {
            
            // refresh circle screen (MyCircleVC)
            NotificationCenter.default.post(name: .refreshCircleScreen, object: nil)
            
            Alert.sharedInstance.alertOkWindow(title: "Success", message: viewModel.intersectCircleResponse?.message ?? "Circle Intersected Successfully !") { result in
                if result {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        } else {
            self.showToast(message: viewModel.intersectCircleResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}


