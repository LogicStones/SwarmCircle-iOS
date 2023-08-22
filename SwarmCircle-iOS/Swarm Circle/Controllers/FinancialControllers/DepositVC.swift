//
//  DepositVC.swift
//  Swarm Circle
//
//  Created by Macbook on 08/07/2022.
//

import UIKit

class DepositVC: BaseViewController {

    @IBOutlet weak var depositLBL: UILabel!
    @IBOutlet weak var textFieldView: UIView!
    @IBOutlet weak var amountTF: UITextField!
    @IBOutlet weak var amountLBL: UILabel!
    @IBOutlet weak var amountView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.initUI()
    }
    

    // MARK: - Configuring UI when loading
    func initUI(){
        self.amountTF.text = ""
        self.amountTF.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
//        self.amountTF.se
        self.navigationController?.navigationBar.topItem?.backButtonTitle = "Back To Deposit"
    }
    
    @IBAction func nextPressed(_ sender: UIButton) {
        
        self.view.endEditing(true)
        
        if self.amountTF.text != "" && self.amountView.isHidden == true {
            self.amountLBL.text = "$\(Double(amountTF.text!)!)"
            self.depositLBL.isHidden = true
            self.textFieldView.isHidden = true
            self.amountView.isHidden = false
        } else {
            if self.validateFields() {
                if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "DepositByCardVC") as? DepositByCardVC {
                    vc.amount = Double(amountTF.text!)!
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    // MARK: - Validate Fields on button Tap
    func validateFields() -> Bool {
        
        if amountTF.text!.isEmpty {
            self.showToast(message: "Please Enter an amount", toastType: .red)
            return false
        }
        else if Double(amountTF.text!)! < 1.00 {
            self.showToast(message: "Amount must be at least $1.00 usd", toastType: .red)
            return false
        }
        return true
    }
    
    
    @IBAction func editButtonPressed(_ sender: Any) {
        self.depositLBL.isHidden = false
        self.textFieldView.isHidden = false
        self.amountView.isHidden = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

// MARK: - TextField Configuration
extension DepositVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField.text! == "" && string == "." {
            return false
        }
        
//        if string == "0" && textField.text! == "" {
//            return false
//        }
        if string != "" {
            if "\(textField.text ?? "")\(string)".split(separator: ".")[0].count > 8 {
                return false
            }
        }
        
        // only allow one decimal point
        if string == "." && textField.text!.contains(".") {
            return false
        }
        
        // Don't allow more than two digits after a decimal point
        if textField.text!.contains(".") && textField.text!.split(separator: ".").count == 2 {
            if textField.text!.split(separator: ".")[1].count == 2 && string != "" {
                return false
            }
        }
        return true
    }
}
