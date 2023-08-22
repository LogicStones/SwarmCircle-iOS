//
//  IdentificationStatusVC.swift
//  Swarm Circle
//
//  Created by Macbook on 06/06/2023.
//

import UIKit

class IdentificationStatusVC: BaseViewController {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var continueView: UIView!
    @IBOutlet weak var statusMessageLBL: UILabel!
    @IBOutlet weak var statusTitleLBL: UILabel!
    @IBOutlet weak var statusIV: UIImageView!
    
    private let viewModel = ViewModel()
    
    var selectedDocType = ""
    var passport: Data?
    var front: Data?
    var back: Data?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
        self.initVariable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setBackButtonIcon()
    }
    
    // MARK: - Load UI
    func initUI() {
        
//        self.setUIFromType(docType: selectedDocType)
//        self.setBackButtonIcon()
        self.continueView.isHidden = true
        self.activityIndicator.startAnimating()
        self.navigationController?.isNavigationBarHidden = true
        
        
    }
    
    // MARK: - Load Data
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        if let passportData = passport{
            self.uploadSelectedDocument(front: passportData, back: nil)
        }
        if let frontData = front{
            self.uploadSelectedDocument(front: frontData, back: back)
        }
    }
    
    override func setBackButtonIcon() {
        self.navigationController?.navigationBar.tintColor = UIColor.white // to change the all text color in navigation bar or navigation
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }

    @IBAction func continueBtnTapped(_ sender: Any) {
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    
    deinit {
        self.activityIndicator.stopAnimating()
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
extension IdentificationStatusVC{
    
    func uploadSelectedDocument(front: Data, back: Data?){
        self.viewModel.uploadIdentificationDoc(frontImage: front, backImage: back)
    }
    
}
extension IdentificationStatusVC: NetworkResponseProtocols{
    
    func didIdentityVerificationDoc() {
        print(viewModel.identityVerificationDocResponse)
        if viewModel.identityVerificationDocResponse?.isSuccess == false {
            self.statusTitleLBL.text = "Verification Failed"
            self.statusMessageLBL.text = viewModel.identityVerificationDocResponse?.message ?? "Something went wrong"
            self.statusIV.image = UIImage(named: "verificationFailedImage")
            self.continueView.isHidden = false
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            
        } else {
            if viewModel.identityVerificationDocResponse?.data == true{
                self.statusTitleLBL.text = "Successfully Verified"
                self.statusMessageLBL.text = viewModel.identityVerificationDocResponse?.message ?? "Something went wrong"
                self.statusIV.image = UIImage(named: "verifiedImage")
                self.continueView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            } else {
                print("Status Succeed but not verified.")
                self.statusTitleLBL.text = "Verification Process Completed"
                self.statusMessageLBL.text = viewModel.identityVerificationDocResponse?.message ?? "Something went wrong"
                self.continueView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
            
        }
    }
    
}
