//
//  TagListVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 26/12/2022.
//

import UIKit

class TagListVC: BaseViewController {
    
    @IBOutlet private weak var searchTF: UITextField!
    @IBOutlet weak var searchBtn: UIButton!
    @IBOutlet weak var actIndView: UIActivityIndicatorView!
    @IBOutlet private weak var tableView: UITableView!

    var pageNumber: Int = 1 // not using this because pagination is not supported.
    var tagList: [TagDM] = [] // array to hold fetched friend list
    var tagListSelected: [TagDM] = [] // array to hold selected friend list this will only be altered when user selects/deselects a row.
    var tagListSelectedFiltered: [TagDM] = []
    
    let viewModel = ViewModel()
    
    var delegate: AppProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Configure UI when loading
    func initUI() {
    
        self.tableView.register(UINib(nibName: "TagCell", bundle: nil), forCellReuseIdentifier: "TagCell")
        self.tableView.allowsMultipleSelection = true
    }
    
    // MARK: - Load Data
    func initVariable() {
        
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.fetchTagList()
    }
    
    // MARK: - Fetch Circle Member List
    func fetchTagList() {
        
        self.tagListSelectedFiltered = self.tagListSelected
        
        self.viewModel.getTrendingCircleCategoryList(search: searchTF.text!)
//        self.viewModel.getTagList(circleId: circleId, pageNumber: 0, searchText: "")
    }
    
    // MARK: - Cross Button Tapped
    @IBAction func closeButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Done Button Tapped
    @IBAction func applyBtnTapped(_ sender: UIButton) {
        
        self.dismiss(animated: true) {
            self.delegate?.setAndApplySelectedFilter(tagListSelected: self.tagListSelected)
        }
    }
}

// MARK: - TableView Configuration
extension TagListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.tagList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell") as? TagCell else {
            return UITableViewCell()
        }
        
        cell.configureCell(self.tagList[indexPath.row])
        
        if self.tagList[indexPath.row].isSelected ?? false {
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
//        if indexPath.row == self.tagList.count - 10 && self.tagList.count < self.viewModel.tagListResponse?.recordCount ?? 0 {
//            self.pageNumber += 1
//            self.fetchTagList()
//        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //        if self.destinationController == .groupAVCallingVC { // restrict selected member to 5 when calling.
        //
        //            if self.memberListFiltered[indexPath.row].IsInCall ?? false {
        //
        //                self.tableView.deselectRow(at: indexPath, animated: false)
        //
        //                return
        //            }
        //
        //            if self.selectionCount == 5 {
        //
        //                self.tableView.deselectRow(at: indexPath, animated: false)
        //
        //                guard let callType = self.additionalParams[.callType] as? CallType else {
        //                    dismissOnErrorAlert("Call type missing")
        //                    return
        //                }
        //                self.showToast(message: "Only 5 members are allowed for group \(callType == .videoGroup ? "video" : "audio") calling", toastType: .red)
        //                return
        //            }
        //
        //        }
                
                self.tagList[indexPath.row].isSelected = true
                
                self.insertObjectInTagListSelected(object: self.tagList[indexPath.row])
    }
    
    // MARK: - Insert select object in correct(sorted) position.
    func insertObjectInTagListSelected(object: TagDM) {
        
        guard let id = object.id else { return }
        
        var indexToInsert: Int?
        
        for (i, selectedFriend) in self.tagListSelected.enumerated() {
            
            if let selectedFriendId = selectedFriend.id {
                
                if id > selectedFriendId { continue }
                
                if id < selectedFriendId {
                    indexToInsert = i
                    break
                }
            }
        }
        
        if let indexToInsert {
            self.tagListSelected.insert(object, at: indexToInsert)
        } else {
            self.tagListSelected.insert(object, at: self.tagListSelected.count)
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        self.tagList[indexPath.row].isSelected = false
        
        if let index = getIndexOfObjectInList(list: self.tagListSelected, object: self.tagList[indexPath.row]) {
            
            if let index = getIndexOfObjectInList(list: self.tagListSelectedFiltered, object: self.tagList[indexPath.row]) {
                
                self.tagListSelectedFiltered.remove(at: index)
            }
            
            self.tagListSelected.remove(at: index)
        }
    }
}

extension TagListVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        self.searchTF.resignFirstResponder()
        
        if textField.text!.isEmpty {
            
//            Alert.sharedInstance.alertOkWindow(title: "Error", message: "Please type something to search") { result in
//                if result {
//                    self.searchTF.becomeFirstResponder()
//                }
//            }
            return false
        }
        
        self.isSearching(true)
        
        self.pageNumber = 1
        self.fetchTagList()
        return true
    }
    
    func isSearching(_ flag: Bool) {
        
        if flag {
            self.searchBtn.isHidden = true
            self.actIndView.startAnimating()
            self.searchTF.isEnabled = false
        } else {
            self.searchBtn.isHidden = false
            self.actIndView.stopAnimating()
            self.searchTF.isEnabled = true
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.isEmpty {
            textField.text!.removeLast()
        }
        
        if textField.text!.isEmpty && string.isEmpty {
            
            self.isSearching(true)
            
            self.searchTF.resignFirstResponder()
            self.pageNumber = 1
            self.fetchTagList()
        }
        
        if string.isEmpty {
            return false
        }
        
        return true
    }
}

extension TagListVC: NetworkResponseProtocols {
    
    // MARK: - Trending Circle Category List Response
    func didGetTrendingCircleCategoryList() {
        
        DispatchQueue.main.async {
            self.tableView.flashScrollIndicators()
        }
        
        self.hideLoader()
        
        self.isSearching(false)
        
        if let unwrappedList = self.viewModel.trendingCircleCategoryListResponse?.data {

            self.pageNumber == 1 ? self.tagList.removeAll() : ()

            let syncedList = self.syncSelectionInFetchedList(fetchedList: unwrappedList)

            self.tagList.append(contentsOf: syncedList)

            self.tagList.isEmpty ? self.tableView.setEmptyView("No Data Found", "") : self.tableView.restore()

            self.tableView.reloadData()

        } else {
            self.dismissOnErrorAlert("\(self.viewModel.trendingCircleCategoryListResponse?.message ?? "Something went wrong")")
        }
    }
    
    // MARK: Sync selection in current fetched list and return that list.
    func syncSelectionInFetchedList(fetchedList: [TagDM]) -> [TagDM] {
        
        var fetchedList = fetchedList
        
        fetchedList.sort { a, b in // remove this if array is already sorted
            a.id! < b.id!
        }

        /*
         If fetched list is greater than 'tag list selected filtered' then:
         loop on 'tag list selected filtered' and search in fetched list, and vice versa.
         */

        if fetchedList.count > self.tagListSelectedFiltered.count {
            
            var indicesToDelete: [Int] = [] // to delete object in friendListSelectedFiltered if they are already found, this will reduce number of iterations below when api is hit with next page number.
            
            for (i, selectedTag) in self.tagListSelectedFiltered.enumerated() {
                if let index = self.getIndexOfObjectInList(list: fetchedList, object: selectedTag) {
                    fetchedList[index].isSelected = true
                    indicesToDelete.append(i)
                }
            }
            
            for i in stride(from: indicesToDelete.count - 1, to: 0, by: -1) {
                self.tagListSelectedFiltered.remove(at: indicesToDelete[i])
            }

        } else {
            for (i, tag) in fetchedList.enumerated() {
                if let index = self.getIndexOfObjectInList(list: self.tagListSelectedFiltered, object: tag) {
                    fetchedList[i].isSelected = true
                    self.tagListSelectedFiltered.remove(at: index)
                    
                    if self.tagListSelectedFiltered.isEmpty {
                        break
                    }
                }
            }
        }
        
        return fetchedList
    }
    
    func getIndexOfObjectInList(list: [TagDM], object: TagDM) -> Int? {
        
        if list.isEmpty {
            return nil
        }
        
        guard let id = object.id else { return nil }
        
        var lowerIndex = 0
        var upperIndex = list.count - 1
        
        while (true) { // using binary search algorithm for faster search.
            
            let currentIndex = (lowerIndex + upperIndex)/2
            
            if(list[currentIndex].id == id) {
                return currentIndex
                
            } else if (lowerIndex > upperIndex) {
                return nil
                
            } else {
                
                if ((list[currentIndex].id ?? -1) > id) {
                    upperIndex = currentIndex - 1
                } else {
                    lowerIndex = currentIndex + 1
                }
            }
        }
    }
}






