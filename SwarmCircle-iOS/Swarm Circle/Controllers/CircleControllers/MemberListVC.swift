//
//  MemberListVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 14/09/2022.
//

import UIKit

class MemberListVC: BaseViewController {

    @IBOutlet weak var titleLBL: UILabel!
    @IBOutlet weak var searchTF: UITextField!
    @IBOutlet weak var tableView: UITableView!
//    var isTitleAvailable = false
    
    var memberList: [CircleMembersByCircleIdDM] = []
    
    var memberListFiltered: [CircleMembersByCircleIdDM] = []
    
    var selectedMemberIds = ArrayWrapper<Int>(array: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configuring UI when loading
    
    func initUI() {
        tableView.register(UINib(nibName: "FriendsListCell", bundle: nil), forCellReuseIdentifier: "FriendsListCell")
//        if self.isTitleAvailable{
//            self.titleLBL.text = "Select Members"
//        }
//        self.titleLBL.text = "Select Members"
    }
    
    func initVariable() {
        self.memberListFiltered = self.memberList
    }

//    // MARK: - Touch anywhere to dismiss
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        self.dismiss(animated: true)
//    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
}
extension MemberListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendsListCell") as? FriendsListCell else {
            return UITableViewCell()
        }
//        cell.radioIcon.isSelected = self.selectedFriendIds.array.contains(where: {$0 == friendsList[indexPath.row].id})
        DispatchQueue.main.async {
            cell.configureCell(userInfo: self.memberList[indexPath.row])
//            cell.setSelected(self.selectedFriendIds.array.contains(where: {$0 == self.friendsList[indexPath.row].id}), animated: true)
            
            
        }
        
        cell.profilePicBtn.tag = indexPath.row
        cell.profilePicBtn.addTarget(self, action: #selector(self.profileIconTapped(_:)), for: .touchUpInside)
        
//        cell.setSelected(self.selectedFriendIds.array.contains(where: {$0 == friendsList[indexPath.row].id}), animated: true)
        return cell
    }
    
    @objc func profileIconTapped(_ sender: UIButton) {
        
        self.searchTF.resignFirstResponder()
        
        if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
            
            vc.profileIdentifier = self.memberList[sender.tag].identifier
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.selectedMemberIds.array.contains(where: {$0 == self.memberList[indexPath.row].id}){
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let id = memberList[indexPath.row].id else {
            return
        }
        
        if !self.selectedMemberIds.array.contains(where: {$0 == id}) {
            self.selectedMemberIds.array.append(id)
        }
//        if self.selectedFriendIds.array.contains(where: {$0 == id}) {
//            self.selectedFriendIds.array.removeAll(where: {$0 == id})
//        } else {
//        self.selectedFriendIds.array.append(id)
//        }
//        self.tableView.reloadRows(at: [indexPath], with: .fade)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let id = self.memberList[indexPath.row].id else {
            return
        }
        
        if self.selectedMemberIds.array.contains(where: {$0 == id}) {
            self.selectedMemberIds.array.removeAll(where: {$0 == id})
        }
//       let cell = tableView.cellForRow(at: indexPath) as? FriendsListCell
//        cell?.setSelected(false, animated: true)
//        if self.selectedFriendIds.array.contains(where: {$0 == id}) {
//            self.selectedFriendIds.array.removeAll(where: {$0 == id})
//        } else {
//            self.selectedFriendIds.array.append(id)
//        }
    }
}

extension MemberListVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTF.resignFirstResponder()
        return true
    }
    
   // MARK: - TextField Delegate Fires on Less than and greater than 3 text Values
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let text = (self.searchTF.text! as NSString).replacingCharacters(in: range, with: string)
        
        if text.count > 0 {

          self.memberList = textField.text!.isEmpty ? self.memberListFiltered : self.memberListFiltered.filter { member in
            
              return member.name?.range(of: textField.text!, options: .caseInsensitive) != nil
          }
        } else {
          self.memberList = self.memberListFiltered
        }
        self.tableView.reloadData()
        return true
      }
}


