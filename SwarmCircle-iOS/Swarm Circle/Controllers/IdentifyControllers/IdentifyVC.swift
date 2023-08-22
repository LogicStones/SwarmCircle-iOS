//
//  IdentifyVC.swift
//  Swarm Circle
//
//  Created by Macbook on 05/06/2023.
//

import UIKit

class IdentifyVC: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.setBackButtonIcon()
    }
    

    override func setBackButtonIcon() {
        self.navigationController?.navigationBar.tintColor = UIColor.white // to change the all text color in navigation bar or navigation
        self.navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func continueBtnTapped(_ sender: Any) {
        if let vc = AppStoryboard.Identify.instance.instantiateViewController(withIdentifier: "DocumentTypeVC") as? DocumentTypeVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}
