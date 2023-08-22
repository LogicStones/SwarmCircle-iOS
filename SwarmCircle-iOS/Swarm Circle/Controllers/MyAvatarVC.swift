//
//  MyAvatarVC.swift
//  Swarm Circle
//
//  Created by Macbook on 19/07/2022.
//

import UIKit

class MyAvatarVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let viewModel = ViewModel()
    var pageNumber = 1
    
    var pastPollList: [AVPastPoll] = []
    
    var avatar: AvatarDM?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To My Avatar"
    }

    // MARK: - Configuring UI when loading
    func initUI(){
    
        //tableView Nib registration
        self.tableView.register(UINib(nibName: "AvatarHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: "AvatarHeaderView")
        self.tableView.register(UINib(nibName: "PollOptionsCell", bundle: nil), forCellReuseIdentifier: "PollOptionsCell")
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
    }
    
    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.getCurrentAvatar()
    }
    
    // MARK: - Get Current Avatar
    func getCurrentAvatar(refreshPollList: Bool = true) {
        self.viewModel.getCurrentAvatar(refreshPollList: refreshPollList)
    }

    // MARK: - Fetch Past Poll List
    func getPastPolls() {
        self.viewModel.getPastPolls(pageNumber: self.pageNumber, pageLimit: 20)
    }
    
    // MARK: - Update Poll Privacy
    func updatePollPrivacy(pollResponseId: Int, privacy: Int) {
        self.viewModel.updatePollPrivacy(pollResponseId: pollResponseId, privacy: privacy)
    }
    
    // MARK: - Remove Answered Poll Option
    func removeAnsweredPollOption(pollResponseId: Int, object: AVPastPoll) {
        self.viewModel.removeAnsweredPollOption(pollResponseId: pollResponseId, object: object as AnyObject)
    }
    
    // MARK: - Edit Avatar Button Tapped
    @IBAction func editAvatarPressed(_ sender: Any) {
        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "EditAvatarVC") as? EditAvatarVC {
            
            vc.currentAvatar = self.avatar
            vc.delegate = self
            
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // MARK: - Menu (3 dots) Button Tapped
    @objc func showPrivacyMenu(sender: UIButton){
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "PollsBottomSheetVC") as? PollsBottomSheetVC {
            vc.modalPresentationStyle  = .popover
            self.present(vc, animated: true)
        }
    }

}
// MARK: - TableView Configuration
extension MyAvatarVC: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "AvatarHeaderView") as? AvatarHeaderView else {
            return UIView()
        }
        if let avatar {
            header.configureHeader(avatar: avatar)
        }
        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.pastPollList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PollOptionsCell") as? PollOptionsCell else {
            return UITableViewCell()
        }
        cell.questionLbl.text = self.pastPollList[indexPath.row].question ?? ""
        cell.optionButton.isSelected = true
        cell.optionButton.isUserInteractionEnabled = false
        cell.optionButton.setTitle("\(self.pastPollList[indexPath.row].optionText ?? "")", for: .selected)
        cell.optionButton.frame = CGRect(x: 0.0, y: 0.0, width: cell.optionButton.intrinsicContentSize.width, height: cell.optionButton.intrinsicContentSize.height + 5)
        cell.optionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        cell.menuBtn.tag = indexPath.row
        cell.menuBtn.addTarget(self, action: #selector(menuBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        350
//    }
    
    @objc func menuBtnTapped(_ sender: UIButton) {
        
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "PollsBottomSheetVC") as? PollsBottomSheetVC {
            vc.modalPresentationStyle = .overFullScreen
            vc.pollResponseId = pastPollList[sender.tag].id
            vc.object = pastPollList[sender.tag]
            vc.index = sender.tag
            vc.delegate = self
            self.present(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.pastPollList.count - 10 && self.pastPollList.count < self.viewModel.pastPollsResponse?.recordCount ?? 0 {
            self.pageNumber += 1
            self.getPastPolls()
        }
    }
}

extension MyAvatarVC: NetworkResponseProtocols {
    
    func didGetCurrentAvatar(refreshPollList: Bool) {
        
        refreshPollList ? self.getPastPolls() : ()
        
        if let data = self.viewModel.currentAvatarResponse?.data {
            self.avatar = data
            self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { // improve this later, issue on first time loading avatar.
                self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
            }
            
        } else {
            self.showToast(message: self.viewModel.currentAvatarResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
    
    // MARK: - Past Polls Response
    func didReceivePastPolls() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.pastPollsResponse?.data {
            
            self.pageNumber == 1 ? self.pastPollList.removeAll() : ()
            
            self.pastPollList.append(contentsOf: unwrappedList)
            
            self.tableView.reloadSections(IndexSet(integer: 0), with: .none)
        }
        else {
            self.showToast(message: self.viewModel.pastPollsResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
    
    // MARK: - Update Poll Privacy Response
    func didUpdatePollPrivacy() {
        
        self.hideLoader()
        
        if self.viewModel.updatePollPrivacyResponse?.isSuccess ?? false {
            self.showToast(message: self.viewModel.updatePollPrivacyResponse?.message ?? "Some error occured", toastType: .green)
        }
        else {
            self.showToast(message: self.viewModel.updatePollPrivacyResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
    
    // MARK: - Remove Answered Poll Option Response
    func didRemoveAnsweredPollOption(id: Int, object: AnyObject) {

        if self.viewModel.removeAnsweredPollOptionResponse?.isSuccess ?? false {
            self.showToast(message: self.viewModel.removeAnsweredPollOptionResponse?.message ?? "Some error occured", toastType: .green)
        }
        else {
            self.pastPollList.append(object as! AVPastPoll)
            self.tableView.reloadData()
            self.showToast(message: self.viewModel.removeAnsweredPollOptionResponse?.message ?? "Some error occured", toastType: .red)
        }
    }
}

extension MyAvatarVC: AppProtocol {
    
    // MARK: - Update Poll Privacy in MyAvatarVC after selecting a privacy in PollsBottomSheetVC
    func updatePrivacyOfPoll(pollResponseId: Int, privacy: Int) {
        self.showLoader()
        self.updatePollPrivacy(pollResponseId: pollResponseId, privacy: privacy)
    }
    
    // MARK: - Remove Answered Poll in MyAvatarVC after selecting a remove in PollsBottomSheetVC
    func removeAnsweredOptionOfPoll(pollResponseId: Int, object: AVPastPoll, index: Int) {
        self.removeAnsweredPollOption(pollResponseId: pollResponseId, object: object)
        self.pastPollList.remove(at: index)
        self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        self.tableView.reloadData()
    }
    
    // MARK: - Refresh User Avatar
    func refreshAvatar() {
        
        self.getCurrentAvatar(refreshPollList: false)
    }
}
