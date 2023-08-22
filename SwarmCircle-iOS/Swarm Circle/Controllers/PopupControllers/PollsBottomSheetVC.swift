//
//  BottomSheetVC.swift
//  Swarm Circle
//
//  Created by Macbook on 19/07/2022.
//

import UIKit

class PollsBottomSheetVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var delegate: AppProtocol?
    
    var pollResponseId: Int?
    var object: AVPastPoll?
    var index: Int?
    
    var privacyItems =
    [
        (UIImage(named: "onlymeIcon"), "Only me", 0), // OnlyMe = 0 (privacy)
        (UIImage(named: "friendsIcon"), "Friends", 1), // Friends = 1 (privacy)
        (UIImage(named: "everyoneIcon"), "Everyone", 2), // Everyone = 2 (privacy)
        (UIImage(named: "removeIconPure"), "Remove", -1)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
    }

    // MARK: - Configuring UI when loading
    func initUI() {
        self.tableView.register(UINib(nibName: "BottomSheetOptionCell", bundle: nil), forCellReuseIdentifier: "BottomSheetOptionCell")
        self.tableView.register(UINib(nibName: "PollQuestionWithMenu", bundle: nil), forHeaderFooterViewReuseIdentifier: "PollQuestionWithMenu")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.dismiss(animated: true)
    }

}
extension PollsBottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return privacyItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BottomSheetOptionCell") as? BottomSheetOptionCell else {
            return UITableViewCell()
        }
        
        cell.optionIcon.image = privacyItems[indexPath.row].0
        cell.optionLBL.text = privacyItems[indexPath.row].1

        if indexPath.row == 3 {
            cell.leadingConstant.constant = 20
            cell.optionLBL.textColor  = .red
        } else {
            cell.leadingConstant.constant = 40
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Set Privacy"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else { return }
        headerView.textLabel?.textColor = .black // any color
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PollQuestionWithMenu") as? PollQuestionWithMenu else {
//            return UIView()
//        }
//        header.menuButton.isHidden = true
//        header.questionLBL.text = "Set Privacy"
//        return header
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.tableView.deselectRow(at: indexPath, animated: true)
        
        guard let pollResponseId else {
            return
        }
        
        if self.privacyItems[indexPath.row].1 != "Remove" {
            self.delegate?.updatePrivacyOfPoll(pollResponseId: pollResponseId, privacy: self.privacyItems[indexPath.row].2)
            self.dismiss(animated: true)
            return
        }
        
        guard
            let object,
            let index
        else {
            return
        }

        Alert.sharedInstance.alertWindow(title: "Warning", message: "Are you sure you want to remove this poll?") { result in
            if result {
                self.delegate?.removeAnsweredOptionOfPoll(pollResponseId: pollResponseId, object: object, index: index)
                self.dismiss(animated: true)
            }
        }
    }
    
}

