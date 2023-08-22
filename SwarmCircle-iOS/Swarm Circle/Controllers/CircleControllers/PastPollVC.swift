//
//  PastPollVController.swift
//  Swarm Circle
//
//  Created by Macbook on 08/07/2022.
//

import UIKit

class PastPollVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pollTitleLBL: UILabel!
    var options1 = ["test", "test"]
    var options2 = ["test", "test", "test"]
    var pollType = "View Past Polls"
    
    var circleIdentifier: String?
    
    let viewModel = ViewModel()
    
    var pollList: [PastPollDM] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    

    // MARK: - Configuring UI when loading
    
    func initUI(){
        self.pollTitleLBL.text = self.pollType
        self.tableView.register(UINib(nibName: "PastPollCell", bundle: nil), forCellReuseIdentifier: "PastPollCell")
//        self.tableView.register(UINib(nibName: "PollOptionsCell", bundle: nil), forCellReuseIdentifier: "PollOptionsCell")
//        self.tableView.register(UINib(nibName: "PollQuestionView", bundle: nil), forHeaderFooterViewReuseIdentifier: "PollQuestionView")
    }
    func initVariable() {
        viewModel.delegateNetworkResponse = self
        self.postGetPastPollList()
    }
    
    func postGetPastPollList() {
        
        guard let circleIdentifier = circleIdentifier else {
            self.showToast(message: "Some error occured", delay: 2, toastType: .red)
            return
        }
        
        self.showLoader()
        
        self.viewModel.getCirclePastPollList(circleIdentifier: circleIdentifier)
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
extension PastPollVC: UITableViewDelegate, UITableViewDataSource{//, UITableViewDragDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pollList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PastPollCell")  as? PastPollCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(info: self.pollList[indexPath.row])
        
        cell.deleteBtn.tag = indexPath.row
        
        cell.option1Btn.tag = indexPath.row
        cell.option2Btn.tag = indexPath.row
        cell.option3Btn.tag = indexPath.row
        cell.option4Btn.tag = indexPath.row
        cell.option5Btn.tag = indexPath.row
        
        if (self.pollList[indexPath.row].isPollAdmin ?? false) || (self.pollList[indexPath.row].circleAdmin ?? false) {
            
            cell.deleteBtn.addTarget(self, action: #selector(deleteBtnTapped(_:)), for: .touchUpInside)
            
            cell.option1Btn.addTarget(self, action: #selector(option1BtnTapped(_:)), for: .touchUpInside)
            cell.option2Btn.addTarget(self, action: #selector(option2BtnTapped(_:)), for: .touchUpInside)
            cell.option3Btn.addTarget(self, action: #selector(option3BtnTapped(_:)), for: .touchUpInside)
            cell.option4Btn.addTarget(self, action: #selector(option4BtnTapped(_:)), for: .touchUpInside)
            cell.option5Btn.addTarget(self, action: #selector(option5BtnTapped(_:)), for: .touchUpInside)
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
                
                if self.pollList.isEmpty {
                    self.tableView.setEmptyView("No Data Found", "")
                }
            }
        }
    }
    
    @objc func option1BtnTapped(_ sender: UIButton) {
        
        self.openUserListController(senderTag: sender.tag, optionId: 0)
    }
    
    @objc func option2BtnTapped(_ sender: UIButton) {
        self.openUserListController(senderTag: sender.tag, optionId: 1)
    }
    
    @objc func option3BtnTapped(_ sender: UIButton) {
        self.openUserListController(senderTag: sender.tag, optionId: 2)
    }
    
    @objc func option4BtnTapped(_ sender: UIButton) {
        self.openUserListController(senderTag: sender.tag, optionId: 3)
    }
    
    @objc func option5BtnTapped(_ sender: UIButton) {
        self.openUserListController(senderTag: sender.tag, optionId: 4)
    }
    
    func openUserListController(senderTag: Int, optionId: Int) {
        
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "UserListController") as? UserListController {
            
            vc.additionalParameters[.pollId] = self.pollList[senderTag].pollID
            vc.additionalParameters[.optionId] = self.pollList[senderTag].options?[optionId].id
            vc.additionalParameters[.optionText] = self.pollList[senderTag].options?[optionId].optionText
            vc.additionalParameters[.progressPercentage] = self.pollList[senderTag].options?[optionId].percentage
            
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.modalTransitionStyle = .crossDissolve
            self.present(navigationController, animated: true)
        }
    }
    
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
extension PastPollVC: NetworkResponseProtocols {
    
    func didGetCirclePastPollList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.getCirclePastPollListResponse?.data {
            pollList.append(contentsOf: unwrappedList)
            tableView.reloadData()
            self.pollList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        } else {
            self.showToast(message: viewModel.getCirclePastPollListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
            self.pollList.count == 0 ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        }
    }
    
    func didDeleteCirclePoll(object: AnyObject) {
        
        if self.viewModel.deleteCirclePollResponse?.isSuccess ?? false {
            self.showToast(message: self.viewModel.deleteCirclePollResponse?.message ?? "Something went wrong", toastType: .green)
        } else {
            self.showToast(message: self.viewModel.deleteCirclePollResponse?.message ?? "Something error occured", toastType: .red)
            self.pollList.append(object as! PastPollDM)
            self.tableView.reloadData()
            self.tableView.restore()
        }
    }
}
