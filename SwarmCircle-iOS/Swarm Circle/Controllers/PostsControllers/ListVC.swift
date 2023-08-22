//
//  TaggedUserListVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 10/01/2023.
//

import UIKit

class ListVC: BaseViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    enum ListType: String {
        case taggedList
        case friendList
        case circleList
    }
    
    var listType: ListType?
    
    var friendList: [FriendDM] = []
    var circleList: [ProfileCircle] = []
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.initUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            self.tableView.flashScrollIndicators()
        }
    }
    
    // MARK: - UI initialization
    func initUI() {
        
        guard let listType else {
            dismissOnErrorAlert("List type missing")
            return
        }
        
        if listType == .taggedList {
            self.friendList.remove(at: 0)
            self.titleLbl.text = "Tagged Friends"
            
        } else if listType == .friendList {
            self.titleLbl.text = "Friend list"
            
        } else if listType == .circleList {
            self.titleLbl.text = "Circle list"
        }
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "UserCell", bundle: nil), forCellReuseIdentifier: "UserCell")
    }
    
    // MARK: - Close Button Tapped
    @IBAction func closeBtnTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}


// MARK: - TableView Configuration
extension ListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.listType == .taggedList || self.listType == .friendList {
            self.friendList.isEmpty ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            return self.friendList.count
            
        } else { // else if self.listType == .circleList
            self.circleList.isEmpty ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()
            return self.circleList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as? UserCell else {
            return UITableViewCell()
        }
        
        if self.listType == .taggedList || self.listType == .friendList {
            cell.configureCell(self.friendList[indexPath.row])
            
        } else { // else if self.listType == .circleList
            cell.configureCell(self.circleList[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if self.listType == .taggedList || self.listType == .friendList {
            
            if let vc = AppStoryboard.Profile.instance.instantiateViewController(withIdentifier: "ViewProfileVC") as? ViewProfileVC {
                
                vc.profileIdentifier = self.friendList[indexPath.row].identifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else { // else if self.listType == .circleList
            
            if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "CircleDetailVC") as? CircleDetailVC {
                
                vc.circleIdentifier = self.circleList[indexPath.row].identifier
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}


