//
//  CreateCircleIntersectionVC.swift
//  Swarm Circle
//
//  Created by Macbook on 21/07/2022.
//

import UIKit

class CreateCircleIntersectionVC: BaseViewController {

    @IBOutlet weak var lastBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var circleImgView: UIImageView!
    @IBOutlet weak var circleNameTF: UITextField!
    @IBOutlet weak var categoryTF: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var setPrivacyBtn: UIButton!
    
    let privacyOptions: [(String, UIAlertAction.Style)] = [
        ("Public", UIAlertAction.Style.default),
        ("Friends", UIAlertAction.Style.default),
        ("Only Members", UIAlertAction.Style.default),
        ("Cancel", UIAlertAction.Style.cancel)
    ]
    
    var selectedPrivacyIndex: Int?
    
    var isImageSelected = false
    
    var collectionViewItem = 3
    
    let viewModel = ViewModel()
    
    var memberList: [CircleMembersByCircleIdDM] = []
    
    var selectedMemberIds = ArrayWrapper<Int>(array: [])
    
    var circleList: [JoinedCircleDM] = []
    
    var delegate: AppProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To My Circle Intersection"
    }


    // MARK: - Configuring UI when loading

    func initUI(){
        
        self.circleNameTF.keyboardType = .asciiCapable
        self.categoryTF.keyboardType = .asciiCapable

//        self.collectionView.register(UINib(nibName: "CircleCell", bundle: nil), forCellWithReuseIdentifier: "CircleCell")
        self.tableView.register(UINib(nibName: "CirclesInfoCell", bundle: nil), forCellReuseIdentifier: "CirclesInfoCell")
        addDismissKeyboardOnTapGesture(scrollView: scrollView)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    //        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
    //           flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    //         }
    }
    
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.postGetMemberList()
    }
    
    func postGetMemberList() {
        
        self.circleNameTF.resignFirstResponder()
        
        let params: [String: Any] = [
            "circleId" : getCircleIdsFromCircleList()
        ]
        self.viewModel.getCircleMembersByCircleIdsList(params: params)
    }
    
    // handling show / hide keyboard
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            
            // get the size of keyboard
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            // checking keyboard status weather it's showing or hidden
            if isKeyboardShowing {
                print("Keyboard Showing")
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - keyboardSize.height, right: 0)
                
                self.lastBottomConstraint.constant = keyboardSize.height - 15
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else{
                print("Keyboard Hidden")
                
                self.lastBottomConstraint.constant = 20
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            
        }
    }
    
    
    @IBAction func uploadImgBtnTapped(_ sender: UITapGestureRecognizer) {
        
        self.circleNameTF.resignFirstResponder()
        
        ImagePickerManager().pickImage(self) { image in
            self.isImageSelected = true
            self.circleImgView.image = image
        }
    }
    
    // MARK: - Set privacy button tapped
    @IBAction func setPrivacyBtnTapped(_ sender: UIButton) {
        Alert.sharedInstance.showActionsheet(vc: self, title: "Select Audience", message: "Who can see your circle?", actions: self.privacyOptions) { index, _ in
            if index < 3 { // Set Privacy
                self.setPrivacyBtn.setTitle(self.privacyOptions[index].0, for: .normal)
                self.selectedPrivacyIndex = index + 1
            }
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        self.circleNameTF.text?.removeWhiteSpacesFromStartNEnd()
        self.circleNameTF.text?.condenseWhitespace()
        
        self.categoryTF.text!.removeWhiteSpacesFromStartNEnd()
        self.categoryTF.text!.condenseWhitespace()
        
        if !self.isImageSelected {
            self.showToast(message: "Image is required", delay: 2, toastType: .red)
            return
        }
        
        if !self.circleNameTF.text!.isEmpty {
            
            if self.categoryTF.text!.isEmpty {
                self.showToast(message: "Category name is required", delay: 2, toastType: .red)
                return
            }
            if self.selectedPrivacyIndex == nil {
                self.showToast(message: "Circle privacy is required", delay: 2, toastType: .red)
                return
            }
            
            if !self.selectedMemberIds.array.isEmpty {
                
                self.proceedToCreateCircleIntersection()
                
            } else {
                self.showToast(message: "Atleast 1 member is required", delay: 2, toastType: .red)
            }
        } else {
            self.showToast(message: "Circle name is required", delay: 2, toastType: .red)
        }
    }
    
    func proceedToCreateCircleIntersection() {
        
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "PollIntersectionVC") as? PollIntersectionVC {
            
            vc.circleImageData = self.circleImgView.image?.jpeg(.low)
            vc.circleName = Utils.encodeUTF(self.circleNameTF.text!)
            vc.circleCategory = self.categoryTF.text!
            vc.circlePrivacyType = self.selectedPrivacyIndex
            vc.circleIdArray = self.getCircleIdsFromCircleList()
            vc.selectedMemberIdArray = self.selectedMemberIds.array
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    fileprivate func getCircleIdsFromCircleList() -> [Int] {
        
        var circleIdArray: [Int] = []
        
        for circle in circleList {
            if let circleId = circle.circleID {
                circleIdArray.append(circleId)
            }
        }
        return circleIdArray
    }
    
    @IBAction func selectMemberPressed(_ sender: Any) {
        self.circleNameTF.resignFirstResponder()
        if let vc = AppStoryboard.Circle.instance.instantiateViewController(withIdentifier: "MemberListVC") as? MemberListVC {
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.modalPresentationStyle = .overFullScreen
            navigationController.modalTransitionStyle = .crossDissolve
            vc.memberList = self.memberList
            vc.selectedMemberIds = self.selectedMemberIds
            self.present(navigationController, animated: true, completion: nil)
        }
    }


//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.tableViewHeight.constant = self.tableView.contentSize
////        self.collectionViewHeight.constant = self.collectionView.collectionViewLayout.collectionViewContentSize.height
////        self.view.layoutIfNeeded()
//    }
    override func viewWillLayoutSubviews() {
        
        DispatchQueue.main.async {
            super.updateViewConstraints()
            self.tableViewHeight.constant = self.tableView.contentSize.height
        }
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
//MARK: - CollectionView Configuration
extension CreateCircleIntersectionVC: UITableViewDelegate,  UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return circleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CirclesInfoCell") as? CirclesInfoCell else {
            return UITableViewCell()
        }
        cell.configureCell(circleInfo: circleList[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.viewWillLayoutSubviews() 
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            if self.circleList.count > 2 {
                
                self.delegate?.moveCircleBackToList(circleInfo: circleList[indexPath.row])
                self.delegate?.removeCircleFromIntersectionCell(circleInfo: circleList[indexPath.row])
                
                self.circleList.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .fade)
                self.postGetMemberList()
                self.tableView.reloadData()
            } else {
                self.showToast(message: "Minimum two circles are required to create intersection", delay: 2, toastType: .red)
            }

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
}
//// MARK: - CollectionView Configuration
//extension CreateCircleIntersectionVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return self.collectionViewItems
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CircleCell", for: indexPath) as? CircleCell else {
//            return UICollectionViewCell()
//        }
//
//
//
//        return cell
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        //        self.collectionView.deselectItem(at: indexPath, animated: true)
//        //        if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "CreateCircleVC") as? CreateCircleVC{
//        //            self.navigationController?.pushViewController(vc, animated: true)
//        //        }
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: self.collectionView.frame.width / 3, height: 100)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return 0
//    }
//}

extension CreateCircleIntersectionVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        switch textField {
        case self.circleNameTF:
            self.categoryTF.becomeFirstResponder()
        case self.categoryTF:
            self.categoryTF.resignFirstResponder()
        default:
            self.view.endEditing(true) // will never be executed because both textField in this controller is handled.
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text!.isEmpty && (string == " ") { // also check if first character of string is a special character
            return false
        }
        if textField.text!.count + string.count > 100 {
            return false
        }
        return true
    }
}


extension CreateCircleIntersectionVC: NetworkResponseProtocols {
    
    func didGetCircleMembersByCircleIdsList() {
        
        self.hideLoader()
        
        if let unwrappedList = viewModel.didGetCircleMemberByCircleIdsListResponse?.data {
            self.memberList.removeAll()
            self.selectedMemberIds.array.removeAll()
            self.memberList.append(contentsOf: unwrappedList)
            
            for member in memberList {
                if let id = member.id {
                    self.selectedMemberIds.array.append(id)
                }
            }
            
        } else {
            self.showToast(message: viewModel.didGetCircleMemberByCircleIdsListResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}
