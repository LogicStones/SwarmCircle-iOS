//
//  UploadDocumentVC.swift
//  Swarm Circle
//
//  Created by Macbook on 06/06/2023.
//

import UIKit

class UploadDocumentVC: BaseViewController {

    @IBOutlet weak var subtitleLBL: UILabel!
    @IBOutlet weak var passportSelectedImage: UIImageView!
    @IBOutlet weak var passportUploadView: UIView!
    @IBOutlet weak var frontSelectedImage: UIImageView!
    @IBOutlet weak var backSelectedImage: UIImageView!
    @IBOutlet weak var singleDocView: UIView!
    @IBOutlet weak var multiDocView: UIStackView!
    @IBOutlet weak var docTypeIV: UIImageView!
    @IBOutlet weak var verifyTitleLBL: UILabel!
    @IBOutlet weak var backIcon: UIImageView!
    @IBOutlet weak var frontIcon: UIImageView!
    @IBOutlet weak var uploadBackLBL: UILabel!
    @IBOutlet weak var uploadFrontLBL: UILabel!
    @IBOutlet weak var backUploadView: UIView!
    @IBOutlet weak var frontUploadView: UIView!
    @IBOutlet weak var frontView: UIView!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var uploadedViewBack: UIView!
    @IBOutlet weak var uploadedViewFront: UIView!
    
    var selectedDocType = ""
    var passport: Data?
    var front: Data?
    var back: Data?
    
    private let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    // MARK: - Load UI
    func initUI() {
        
        self.setUIFromType(docType: selectedDocType)

    }
    
    // MARK: - Load Data
    func initVariable() {

    }
    
    // MARK: - Set UI As Per Previous Selected Options
    func setUIFromType(docType: String){
        
        switch docType {
        case "PASSPORT":
            print("PASSPORT")
            self.docTypeIV.image = UIImage(named: "passportImage")
            self.verifyTitleLBL.text = "Verify Your Identity with a Passport"
            self.subtitleLBL.text = "Please upload the front page of your passport, which contains all your necessary information."
            self.uploadFrontLBL.text = "Take Photo Of Your Passport"
            self.multiDocView.isHidden = true
            self.singleDocView.isHidden = false

        case "DRIVING LICENSE":
            print("DRIVING LICENSE")
            self.docTypeIV.image = UIImage(named: "licenseImage")
            self.verifyTitleLBL.text = "Verify Your Identity with a Driving License"
            self.subtitleLBL.text = "Please provide both the front and back images of your driver's license for verification."
            self.uploadFrontLBL.text = "Take Photo Of Your Front License"
            self.uploadBackLBL.text = "Take Photo Of Your Back License"
            self.multiDocView.isHidden = false
            self.singleDocView.isHidden = true
        case "ID CARD":
            print("ID CARD")
            self.docTypeIV.image = UIImage(named: "IdImage")
            self.verifyTitleLBL.text = "Verify Your Identity with a Identity Card"
            self.subtitleLBL.text = "Please provide both the front and back images of your identity card for verification."
            self.uploadFrontLBL.text = "Take Photo Of Your Front ID Card"
            self.uploadBackLBL.text = "Take Photo Of Your Back ID Card"
            self.multiDocView.isHidden = false
            self.singleDocView.isHidden = true
            
        default:
            print("Nothing")
        }
    }

    @IBAction func passportUploadBtnTapped(_ sender: Any) {
        ImageCaptureManager().pickImage(self) { image in
            self.passportSelectedImage.image = image
            self.passportUploadView.isHidden = true
            if let imageData = image.jpeg(.low) {
                self.passport = imageData
            }
        }
    }
    
    @IBAction func frontUploadBtnTapped(_ sender: Any) {
        ImageCaptureManager().pickImage(self) { image in
            self.frontSelectedImage.image = image
            self.frontUploadView.isHidden = true
            if let imageData = image.jpeg(.low) {
                self.front = imageData
            }
        }
    }
    
    @IBAction func backUploadBtnTapped(_ sender: Any) {
        ImageCaptureManager().pickImage(self) { image in
            self.backSelectedImage.image = image
            self.backUploadView.isHidden = true
            if let imageData = image.jpeg(.low) {
                self.back = imageData
            }
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
    @IBAction func verifyTapped(_ sender: Any) {
        
        
        if self.selectedDocType == "PASSPORT"{
            if let passportData = self.passport {
                if let vc = AppStoryboard.Identify.instance.instantiateViewController(withIdentifier: "IdentificationStatusVC") as? IdentificationStatusVC {
                    vc.passport = passportData
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                self.showToast(message: "Please select passport picture.", toastType: .red)
                return
            }
        } else {
            if let frontData = self.front {
                if let backData = self.back{
                    if let vc = AppStoryboard.Identify.instance.instantiateViewController(withIdentifier: "IdentificationStatusVC") as? IdentificationStatusVC {
                        vc.front = frontData
                        vc.back = backData
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                } else {
                    self.showToast(message: "Please select front & back", toastType: .red)
                    return
                }
            } else {
                self.showToast(message: "Please select front & back", toastType: .red)
                return
            }
        }
        
        
    }
    
}

