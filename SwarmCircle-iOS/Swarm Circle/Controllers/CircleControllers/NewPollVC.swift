//
//  NewPollVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 26/08/2022.
//

import UIKit

class NewPollVC: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pollTitleLBL: UILabel!
    
    //    var pollType = "New Polls"
    
    var circleIdentifier: String?
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?
    
    var pollList: [NewPollDM] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    
    func initUI() {
        //        self.pollTitleLBL.text = self.pollType
        self.tableView.register(UINib(nibName: "PollOptionsViewCell", bundle: nil), forCellReuseIdentifier: "PollOptionsViewCell")
        //        self.tableView.register(UINib(nibName: "PollOptionsCell", bundle: nil), forCellReuseIdentifier: "PollOptionsCell")
        //        self.tableView.register(UINib(nibName: "PollQuestionView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PollQuestionView")
        
    }
    
    func initVariable() {
        viewModel.delegateNetworkResponse = self
        self.postGetNewPollList()
    }
    
    func postGetNewPollList() {
        
        guard let circleIdentifier = circleIdentifier else {
            return
        }
        
        self.showLoader()
        
        self.viewModel.getCircleNewPollList(circleIdentifier: circleIdentifier)
    }
    
    func submitPollAnswer(pollId: Int, optionId: Int, indexPath: IndexPath, pollObject: AnyObject) {
        
        let params = ["pollID": pollId,
                      "optionID": optionId
        ] as [String : Any]
        viewModel.submitPollAnswer(params: params, indexPath: indexPath, pollObject: pollObject)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
// MARK: - TableView Configuration
extension NewPollVC: UITableViewDelegate, UITableViewDataSource{//, UITableViewDragDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionsViewCell")  as? PollOptionsViewCell else {
            return UITableViewCell()
        }
        
        for optionBtn in cell.optionBtnCollection {
            optionBtn.addTarget(self, action: #selector(optionBtnPressed(_:)), for: .touchUpInside)
            optionBtn.accessibilityValue = "\(indexPath.row)"
        }
        
        cell.configureCell(info: pollList[indexPath.row])
        
        cell.deleteBtn.tag = indexPath.row
        
        if (self.pollList[indexPath.row].isPollAdmin ?? false) || (self.pollList[indexPath.row].circleAdmin ?? false) {
            cell.deleteBtn.addTarget(self, action: #selector(deleteBtnTapped(_:)), for: .touchUpInside)
        }
        
        return cell
    }
    
    @objc func deleteBtnTapped(_ sender: UIButton) {
        
        self.deleteCirclePoll(index: sender.tag)
    }
    
    func deleteCirclePoll(index: Int) {
        
        guard let pollId = self.pollList[index].pollID else {
            return
        }
        
        Alert.sharedInstance.alertWindow(title: "Warning", message: "Are you sure you want to delete this poll?") { result in
            if result {
                self.viewModel.deleteCirclePoll(pollId: pollId, object: self.pollList[index] as AnyObject)
                self.pollList.remove(at: index)
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                self.tableView.reloadData()
                self.delegate?.updateNewPollsCount(-1)
                
                if self.pollList.isEmpty {
                    self.tableView.setEmptyView("No Data Found", "")
                }
            }
        }
    }
    
    
    @objc func optionBtnPressed(_ sender: ToggleButton) {
        
        sender.isSelected = true
        
        let row = Int(sender.accessibilityValue!)!
        
        tableView.cellForRow(at: IndexPath(row: row, section: 0))?.isUserInteractionEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [self] in
            
            guard let pollId = pollList[row].pollID, let optionId = pollList[row].options?[sender.tag - 1].id else {
                return
            }
            
            self.submitPollAnswer(pollId: pollId, optionId: optionId, indexPath: IndexPath(row: row, section: 0), pollObject: pollList[row] as AnyObject)
            self.pollList.remove(at: row)
            
            self.tableView.deleteRows(at: [IndexPath(row: row, section: 0)], with: .automatic)
            self.tableView.reloadData()
            
            self.pollList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
    
    //    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return UITableView.automaticDimension
    //    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews()
    }
}
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 10
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 3
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
////        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PastPollQuestionCell") as? PastPollQuestionCell else {
////            return UITableViewCell()
////        }
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionsCell") as? PollOptionsCell else {
//            return UITableViewCell()
//        }
//
//        if indexPath.row == 1{
//            cell.optionButton.isSelected = true
//        } else {
//            cell.optionButton.isSelected = false
//        }
////        cell.layoutSubviews()
////        if indexPath.row == 2{
////            cell.options = options2
////        } else if indexPath.row == 3{
////            cell.options = options1
////        } else {
////            cell.options = options2
////        }
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PollQuestionView") as! PollQuestionView
////        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//
//        return header
//    }
//
////    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
////         return BeerListSectionHeader.height
////     }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//    }
//
//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//
//    }
//}

extension NewPollVC: NetworkResponseProtocols {
    
    func didGetCircleNewPollList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.getCircleNewPollListResponse?.data {
            pollList.append(contentsOf: unwrappedList)
            tableView.reloadData()
            self.pollList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            
        } else {
            self.showToast(message: viewModel.getCircleNewPollListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pollList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
    
    func didSubmitPollAnswer(indexPath: IndexPath, pollObject: AnyObject) {
        if let _ = viewModel.submitPollAnswerResponse?.data {
            self.showToast(message: viewModel.submitPollAnswerResponse?.message ?? "Some error occured", delay: 2, toastType: .green)
            self.delegate?.updateNewPollsCount(-1)
        } else {
            self.pollList.insert(pollObject as! NewPollDM, at: indexPath.row)
            self.tableView.insertRows(at: [indexPath], with: .automatic)
            self.tableView.reloadData()
            self.showToast(message: viewModel.submitPollAnswerResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.tableView.restore()
        }
    }
    
    func didDeleteCirclePoll(object: AnyObject) {
        
        if self.viewModel.deleteCirclePollResponse?.isSuccess ?? false {
            self.showToast(message: self.viewModel.deleteCirclePollResponse?.message ?? "Something went wrong", toastType: .green)
        } else {
            self.showToast(message: self.viewModel.deleteCirclePollResponse?.message ?? "Something error occured", toastType: .red)
            self.pollList.append(object as! NewPollDM)
            self.tableView.reloadData()
            self.delegate?.updateNewPollsCount(1)
            self.tableView.restore()
        }
    }
}
