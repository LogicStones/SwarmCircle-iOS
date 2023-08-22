//
//  CircleMemberListVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 12/12/2022.
//

import UIKit

class CircleMemberListVC: BaseViewController {
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet private weak var searchTF: UITextField!
    @IBOutlet private weak var tableView: UITableView!
    
    enum DestinationController: String { // next action/controller after pressing done button
        case transferVC
        case emailIntent
        case groupAVCallingVC
        case editCircleVC
        case circleDetailVC
    }
    
    enum ControllerTitle: String {
        case selectMembers = "Select Members"
        case selectAMember = "Select a Member"
        case removeMembers = "Remove Members"
        case circleMembers = "Circle Members"
    }
    
    enum SelectionType: String { // tableView selection (multiple/single)
        case single
        case multiple
        case none
    }
    
    enum AdditionalParamsKey: String { // any params for next controllers
        case circleId
        case callType
    }
    
    var controllerTitle: ControllerTitle?
    var selection: SelectionType? // tableView selection (multiple/single)
    var destinationController: DestinationController? // next action/controller after pressing done button
    var additionalParams:[AdditionalParamsKey: Any?] = [:] // any other params for next controllers
    var memberList: [CircleMemberDM] = [] // array to hold fetched member list
    var memberListFiltered: [CircleMemberDM] = []
    var selectionCount = 0
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configure UI when loading
    func initUI() {
        
        guard let controllerTitle = self.controllerTitle?.rawValue else {
            self.dismissOnErrorAlert("Controller title missing")
            return
        }
        guard let _ = selection else {
            self.dismissOnErrorAlert("Selection type (single/multiple) missing")
            return
        }
        guard let _ = destinationController else {
            self.dismissOnErrorAlert("Destination action/controller missing")
            return
        }
        
        self.titleLbl.text = controllerTitle
        
        self.tableView.register(UINib(nibName: "FriendsListCell", bundle: nil), forCellReuseIdentifier: "FriendsListCell")
        
        if self.selection == .single {
            self.tableView.allowsMultipleSelection = false
        } else if self.selection == .multiple {
            self.tableView.allowsMultipleSelection = true
        } else {
            self.tableView.allowsSelection = false
        }
    }
    
    // MARK: - Load Data
    func initVariable() {
        
        if self.memberList.isEmpty {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // put delay in loader, to avoid UI glitch, (because loader is displayed before this controller is properly presented)
                
                self.viewModel.delegateNetworkResponse = self
                self.showLoader()
                self.fetchCircleMemberList()
            }
            
        } else {
            
            self.memberList.sort { a, b in // sort member list according to id, because we will use binary search to sync main list to filtered list when selecting.
                a.id! < b.id!
            }
            self.memberListFiltered = self.memberList // Initially, set filtered member list equal to member list.
        }
    }
    
    // MARK: - Fetch Circle Member List
    func fetchCircleMemberList() {
        
        guard let circleId = self.additionalParams[.circleId] as? Int else {
            dismissOnErrorAlert("Circle ID missing")
            return
        }
        self.viewModel.getCircleMemberList(circleId: circleId, pageNumber: 0, searchText: "")
    }
    
    // MARK: - Cross Button Tapped
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Done Button Tapped
    @IBAction func doneTapped(_ sender: UIButton) {
        
        switch destinationController {
            
        case .emailIntent:
            
            if self.selectionCount == 0 {
                self.showToast(message: "Please select a member to send email", toastType: .red)
                return
            }
            
            let memberListSelected = self.memberList.filter { member in
                return (member.isSelected ?? false) == true
            }

            let selectedMembersEmailAddressArray = memberListSelected.map { member in
                return member.email ?? ""
            }
            
            Utils.openEmailIntent(self, emailAddresses: selectedMembersEmailAddressArray)
            
            
        case .transferVC:
            
            if self.selectionCount == 0 {
                self.showToast(message: "Please select a member to transfer", toastType: .red)
                return
            }
            
            let memberListSelected = self.memberList.filter { member in
                return (member.isSelected ?? false) == true
            }
            
            if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "TransferVC") as? TransferVC {
                
                let member = memberListSelected.first
                
                // convert member object to friend object and pass it to next controller
                let friend = FriendDM(id: member?.id, inviteID: member?.inviteID, identifier: member?.identifier, name: member?.name, displayImageURL: member?.displayImageURL, email: member?.email, circleCount: member?.circleCount, walletID: member?.walletID, isOnline: member?.isOnline)
                vc.selectedFriend = ValueWrapper(value: friend) 
                vc.isTransferFromCircle = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        case .groupAVCallingVC:
            
            guard let callType = self.additionalParams[.callType] as? CallType else {
                dismissOnErrorAlert("Call type missing")
                return
            }

            if self.selectionCount == 0 {
                self.showToast(message: "Please select at least 1 member for group \(callType == .videoGroup ? "video" : "audio") calling", toastType: .red)
                return
            }
            
            let memberListSelected = self.memberList.filter { member in
                return (member.isSelected ?? false) == true
            }
            
            let selectedMembersIdentifierArray = memberListSelected.map { member in
                return member.identifier ?? ""
            }

            self.dismiss(animated: true) {
                self.delegate?.goToGroupCallingVC(members: Utils.convertArrayToCommaSeperatedString(selectedMembersIdentifierArray), isVideoCalling: callType == .videoGroup ? true : false)
            }
        
        case .editCircleVC:
            self.dismiss(animated: true) {
                self.delegate?.setUpdatedMemberList(memberList: self.memberList)
            }
            
        case .circleDetailVC:
            print("Do nothing")
            
            
        case .none:
            print("No value selected for destination controller in CircleMemberListVC")
        }
    }
}

// MARK: - TableView Configuration
extension CircleMemberListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.memberListFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell") as? FriendsListCell else {
            return UITableViewCell()
        }
        
        if self.selection == .single || self.selection == .multiple {
            cell.configureCell(self.memberListFiltered[indexPath.row])
        } else {
            cell.configureCell(self.memberListFiltered[indexPath.row], hideSelectionIcon: true)
        }
        
        
        if self.memberListFiltered[indexPath.row].isSelected ?? false {
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        cell.profilePicBtn.tag = indexPath.row
        cell.profilePicBtn.addTarget(self, action: #selector(self.profileIconTapped(_:)), for: .touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.destinationController == .groupAVCallingVC { // restrict selected member to 5 when calling.
            
            if self.memberListFiltered[indexPath.row].IsInCall ?? false {
                
                self.tableView.deselectRow(at: indexPath, animated: false)
                
                return
            }
            
            if self.selectionCount == 5 {
                
                self.tableView.deselectRow(at: indexPath, animated: false)
                
                guard let callType = self.additionalParams[.callType] as? CallType else {
                    dismissOnErrorAlert("Call type missing")
                    return
                }
                self.showToast(message: "Only 5 members are allowed for group \(callType == .videoGroup ? "video" : "audio") calling", toastType: .red)
                return
            }
            
        }
        
        self.memberListFiltered[indexPath.row].isSelected = true
        
        self.selectionCount += 1
        
        self.syncSelectionInMemberList(id: self.memberListFiltered[indexPath.row].id)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.memberListFiltered[indexPath.row].isSelected = false
        
        self.selectionCount -= 1
        
        self.syncSelectionInMemberList(id: self.memberListFiltered[indexPath.row].id)
    }
    
    // MARK: - Change selection in member list after a selection is change in filtered member list
    func syncSelectionInMemberList(id: Int?) {
        
        guard let id else { return }
        
        var lowerIndex = 0
        var upperIndex = self.memberList.count - 1
        
        while (true) { // using binary search algorithm for faster search.
            
            let currentIndex = (lowerIndex + upperIndex)/2
            
            if(self.memberList[currentIndex].id == id) {
                self.memberList[currentIndex].isSelected = !(self.memberList[currentIndex].isSelected ?? false)
                break
                
            } else if (lowerIndex > upperIndex) {
                break
                
            } else {
                
                if ((self.memberList[currentIndex].id ?? -1) > id) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
    
    // MARK: - Member Profile Icon Tapped
    @objc func profileIconTapped(_ sender: UIButton) {
        
        self.searchTF.resignFirstResponder()
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            
            vc.profileIdentifier = self.memberList[sender.tag].identifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension CircleMemberListVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTF.resignFirstResponder()
        return true
    }
    
    // MARK: - TextField Delegate Fires on Less than and greater than 3 text Values
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            textField.text!.removeLast()
        }
        
        self.memberListFiltered = self.memberList.filter({ member in
            member.name!.lowercased().starts(with: "\(textField.text!.lowercased())\(string.lowercased())")
        })
        
        self.memberListFiltered.isEmpty ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
        
        self.tableView.reloadData()
        
        if string.isEmpty {
            return false
        }
        
        return true
    }
}

import MessageUI

extension CircleMemberListVC: MFMailComposeViewControllerDelegate {
    
    // MARK: - Email Intent
    func openEmail(_ emailAddresses: [String]) {
        Utils.openEmailIntent(self, emailAddresses: emailAddresses)
    }

    // MARK: MailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true)
    }
}

extension CircleMemberListVC: NetworkResponseProtocols {
    
    // MARK: - Circle Member List Response
    func didGetCircleMemberList() {
        
        self.hideLoader()
        
        if let unwrappedList = self.viewModel.circleMemberListResponse?.data {
            
            self.memberList = unwrappedList
            
            self.memberList.isEmpty ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            
            self.memberList.sort { a, b in // sort member list according to id, because we will use binary search to sync main list to filtered list when selecting.
                a.id! < b.id!
            }
 
            self.memberListFiltered = self.memberList // Initially, set filtered member list equal to member list.
            
            self.tableView.reloadData()
            
        } else {
            self.dismissOnErrorAlert("\(self.viewModel.circleMemberListResponse?.message ?? "Something went wrong")")
        }
    }
}





