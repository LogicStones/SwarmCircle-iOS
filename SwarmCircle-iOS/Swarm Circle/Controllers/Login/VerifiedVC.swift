//
//  VerifiedVC.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import UIKit

class VerifiedVC: UIViewController {
    
    @IBOutlet weak var nextBtn: UIButton!
    
    var didVerified2FA: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        initUI()
    }
    
    func initUI() {
        if didVerified2FA {
            nextBtn.setTitle("Go To Dashboard", for: .normal)
        } else {
            nextBtn.setTitle("Go To Login", for: .normal)
        }
        
        // hide navigation bar
        navigationController?.navigationBar.isHidden = true
        
        // disable back swipe gesture
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @IBAction func nextBtnTapped(_ sender: UIButton) {
        
        if didVerified2FA {
            self.dismiss(animated: true)
        }
        else {
            self.navigationController?.popToRootViewController(animated: true)
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
