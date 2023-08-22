//
//  AddCardVC.swift
//  Swarm Circle
//
//  Created by Macbook on 18/07/2022.
//

import UIKit

class AddCardVC: BaseViewController {

    @IBOutlet weak var confirmButtonBottom: NSLayoutConstraint!
    @IBOutlet weak var cardTypeIcon: UIImageView!
    @IBOutlet weak var expiryLBL: UILabel!
    @IBOutlet weak var cardNameLBL: UILabel!
    @IBOutlet weak var cardNumberLBL: UILabel!
    @IBOutlet weak var cvvTF: UITextField!
    @IBOutlet weak var expiryTF: UITextField!
    @IBOutlet weak var cardNumberTF: UITextField!
    @IBOutlet weak var cardNameTF: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.initUI()
    }
    
    // MARK: - Configuring UI when loading
    func initUI(){
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    // MARK: - Setting scrollview for keyboard
    @objc func handleKeyboardNotification(notification: NSNotification){
        
        if let userInfo = notification.userInfo {
            
            // get the size of keyboard
            let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            // checking keyboard status weather it's showing or hidden
            if isKeyboardShowing {
                print("Keyboard Showing")
                
                let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height - keyboardSize.height, right: 0)
                
                self.confirmButtonBottom.constant = keyboardSize.height - 35
                self.scrollView.contentInset = contentInsets
                self.scrollView.scrollIndicatorInsets = contentInsets
                
                
            }else{
                print("Keyboard Hidden")
                
                self.confirmButtonBottom.constant = 20
                self.scrollView.contentInset = .zero
                self.scrollView.scrollIndicatorInsets = .zero
            }
            
            view.layoutIfNeeded()
            
        }
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
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
