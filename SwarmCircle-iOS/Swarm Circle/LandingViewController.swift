//
//  ViewController.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import UIKit
import Kingfisher

class LandingViewController: UIViewController {
    
    private let networkManager = APIManager()
    
    let viewModel = ViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
       
//        self.initVariable()
    }
    
//    // MARK: - Load data from API
//    func initVariable() {
//    }
    
    fileprivate func prefetchNSavePost() {
        
        self.networkManager.getPostList(pageNumber: 1, pageLimit: Utils.feedsPageLimit, postId: 0, profileIdentifier: "", hashtag: "") { result in
            
            switch result {
            case .success(let apiResponse):
                print(apiResponse)
                if let postList = apiResponse.data {
                    PreferencesManager.saveInitial50Posts(list: postList)
                    self.showDashboardVC()
                }
            case .failure(let error):
                print(error.localizedDescription)
                UserDefaults.standard.removeObject(forKey: PreferencesManager.initial50Posts)
                self.showDashboardVC()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if PreferencesManager.isUserLoggedIn() {
            self.prefetchNSavePost()
        } else {
            //            let domain = Bundle.main.bundleIdentifier!
            //            UserDefaults.standard.removePersistentDomain(forName: domain)
            //            UserDefaults.standard.synchronize()
            //            self.dismiss(animated: true)
            self.showLoginVC()
        }
    }

    func showLoginVC() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            let nav =  UINavigationController()
            
            if let vc = AppStoryboard.Login.instance.instantiateViewController(withIdentifier: "LoginVC") as? LoginVC {
                nav.viewControllers = [vc]
                nav.modalPresentationStyle = .fullScreen
                nav.modalTransitionStyle = .crossDissolve
                self.present(nav, animated: true, completion: nil)
            }
        }
        
    }
    func showDashboardVC(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 0) {
//            let nav =  UINavigationController()
            
            if let vc = AppStoryboard.Main.instance.instantiateViewController(withIdentifier: "NavigationController") as? NavigationController {
//                nav.viewControllers = [vc]
                vc.modalPresentationStyle = .fullScreen
                vc.modalTransitionStyle = .crossDissolve
                self.present(vc, animated: true, completion: nil)
            }
        }
        
    }
    
    
}

