//
//  CustomNavController.swift
//  Swarm Circle
//
//  Created by Macbook on 13/10/2022.
//

import UIKit

class CustomNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.

//        let appearance = UINavigationBarAppearance()
//        // set back image
//        appearance.setBackIndicatorImage(UIImage(named: "backIcon"), transitionMaskImage: UIImage(named: "backIcon"))
//
//        // set appearance to one NavigationController
//        self.navigationBar.standardAppearance = appearance
//        self.navigationBar.scrollEdgeAppearance = appearance
//
//        // or you can config for all navigation bar
//        UINavigationBar.appearance().standardAppearance = appearance
//        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        self.navigationBar.topItem?.backButtonTitle = "Back to \(self.viewControllers[0].title)"
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
