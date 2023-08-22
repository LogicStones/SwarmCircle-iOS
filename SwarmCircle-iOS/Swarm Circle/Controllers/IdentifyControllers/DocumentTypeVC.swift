//
//  DocumentTypeVC.swift
//  Swarm Circle
//
//  Created by Macbook on 05/06/2023.
//

import UIKit

class DocumentTypeVC: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var objectList: [(UIImage, String, String)] = []
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Load UI
    func initUI() {
        
        self.tableView.register(UINib(nibName: "DocumentTypeCell", bundle: nil), forCellReuseIdentifier: "DocumentTypeCell")
    }


    // MARK: - Load Data
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.showLoader()
        self.viewModel.getUploadOptions()
    }


    @IBAction func nextBtnTapped(_ sender: Any) {
        if self.tableView.indexPathForSelectedRow?.row == nil{
            self.showToast(message: "Please select document type.", toastType: .red)
            return
        }
        if let vc = AppStoryboard.Identify.instance.instantiateViewController(withIdentifier: "UploadDocumentVC") as? UploadDocumentVC {
            vc.selectedDocType = self.objectList[tableView.indexPathForSelectedRow!.row].1
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
extension DocumentTypeVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectList.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTypeCell", for: indexPath) as? DocumentTypeCell else { return UITableViewCell()}
        
        cell.configureCell(self.objectList[indexPath.row])
        
        return cell
    }
    
    
}
extension DocumentTypeVC: NetworkResponseProtocols{
    
    func diduploadOptions() {
        self.hideLoader()
        if self.viewModel.getUploadOptionsResponse?.isSuccess ?? false{
            if let uploadOptions = self.viewModel.getUploadOptionsResponse?.data{
                if uploadOptions.isPassportVisible ?? false{
                    self.objectList.append((UIImage(named: "passportIcon")!, "PASSPORT", ""))
                }
                if uploadOptions.isDrivingVisible ?? false{
                    self.objectList.append((UIImage(named: "licenseIcon")!, "DRIVING LICENSE", ""))
                }
                if uploadOptions.isIDCardVisible ?? false{
                    self.objectList.append((UIImage(named: "idCardIcon")!, "ID CARD", ""))
                }
                self.tableView.reloadData()
            }
        } else {
            self.showToast(message: self.viewModel.getUploadOptionsResponse?.message ?? "Something went wrong", toastType: .red)
        }
            
    }
}
