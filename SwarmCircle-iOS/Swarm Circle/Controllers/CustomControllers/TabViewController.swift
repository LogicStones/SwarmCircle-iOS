//
//  TabViewController.swift
//  Swarm Circle
//
//  Created by Macbook on 29/04/2022.
//

import UIKit

class TabViewController: UITabBarController {
    
    @IBOutlet weak var notifBarBtn: BadgeBarButtonItem!
    
    var customBar: UINavigationBar = UINavigationBar()
    private let button = UIButton(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
    
    var indicator = UIActivityIndicatorView()
    var blurEffectView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterial), intensity: 0)
    
    let viewModel = ViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //        initUI()
        self.setupMiddleButton()
        self.initVariable()
    }

    override func viewDidAppear(_ animated: Bool) {
        self.getNotificationCount()
    }
    
    // MARK: - UI initialization
    func initUI(){
        
        // Add bar button item
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action:  #selector(backAction))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(backAction))
        
        self.customBar.frame = CGRect(x:0, y:0, width:view.frame.width, height:(navigationController?.navigationBar.frame.height)! + 50)
        self.customBar.backgroundColor = UIColor.green
        self.view.addSubview(customBar)
        //        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor : UIColor.black], for: UIControl.State.selected)
        indicator = UIActivityIndicatorView.customIndicator(at: self.view.center)
        
    }

    // MARK: - Load data from API
    func initVariable() {
        self.viewModel.delegateNetworkResponse = self
        self.getWalletInfo()
    }
    
    // MARK: - Get Wallet Info
    func getWalletInfo() {
        self.viewModel.getWalletDetail()
    }
    
    // MARK: - Get Notification List
    func getNotificationCount() {
        self.viewModel.getNotificationCount { count in
            self.notifBarBtn.badgeNumber = count
        }
    }
    
    // MARK: - Notification Button Tapped
    @IBAction func notificationBtnTapped(_ sender: UIBarButtonItem) {
        
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func messengerButtonTapped(_ sender: Any) {
        
        print("Working")
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "MessengerVC") as? MessengerVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    @IBAction func viewWalletBtnTapped(_ sender: UIButton) {
        self.hideLoader()
        if PreferencesManager.getUserDetailModel()?.isAMLSuccess ?? false {
            self.showWalletScreen()
        } else {
            self.showLoader()
            self.getUserDetails()
        }
    }
    
    
    func showWalletScreen(){
        if let vc = AppStoryboard.Finance.instance.instantiateViewController(withIdentifier: "WalletDetailVC") as? WalletDetailVC {
            vc.modalPresentationStyle = .overFullScreen
            vc.modalTransitionStyle = .crossDissolve
            self.present(vc, animated: true)
        }
    }
    
    func showIdentificationScreen(){
        if let vc = AppStoryboard.Identify.instance.instantiateViewController(withIdentifier: "IdentifyVC") as? IdentifyVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @objc func backAction () {
        // do the magic
    }
    
    func setupMiddleButton() {
        let circularView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))
        
        let cornerRadius = circularView.frame.width/2
        circularView.cornerRadius = cornerRadius
        let shadowPath = UIBezierPath(roundedRect: circularView.bounds, cornerRadius: cornerRadius)
        var circularViewFrame = circularView.frame
        circularViewFrame.origin.y = -25
        circularViewFrame.origin.x = view.bounds.width/2 - circularViewFrame.size.width/2
        circularView.frame = circularViewFrame
        
        circularView.layer.masksToBounds = false
        circularView.layer.shadowColor = UIColor.secondarySystemBackground.cgColor
        circularView.layer.shadowOffset = CGSize(width: 0, height: 2)
        circularView.layer.shadowOpacity = 1
        circularView.layer.shadowPath = shadowPath.cgPath
        
        
        button.setImage(UIImage(named: "homeTab"), for: .normal)
        button.tintColor = UIColor.white
        circularView.addSubview(button)
        tabBar.addSubview(circularView)
        
        
        tabBar.layoutIfNeeded()
        button.addTarget(self, action: #selector(menuButtonAction(sender:)), for: .touchUpInside)
        self.selectedIndex = 2
    }
    
    @objc private func menuButtonAction(sender: UIButton) {
        self.selectedIndex = 2
    }
}

extension TabViewController{
    // MARK: - Get User Details
    func getUserDetails() {
        self.viewModel.getUserDetails()
    }
    
}

extension TabViewController: NetworkResponseProtocols {
    
    // MARK: - User Details Response
    func didGetUserDetails() {
        
        self.hideLoader()
        if let data = self.viewModel.userDetailsResponse?.data {
            PreferencesManager.saveUserDetailsModel(user: data)
            if data.isAMLSuccess ?? false{
                self.showWalletScreen()
            } else {
                self.showIdentificationScreen()
            }
        } else {
//            popOnErrorAlert(self.viewModel.userDetailsResponse?.message ?? "")
        }
    }
    
    // MARK: - Wallet Detail Response
    func didGetWalletDetail() {
        if let walletDetail = viewModel.walletDetailResponse?.data {
            PreferencesManager.saveWalletDetail(info: walletDetail)
        } else {
//            self.showToast(message: viewModel.walletDetailResponse?.message ?? "Some error occured", delay: 2, toastType: .red)
        }
    }
}

// MARK: - Activity Indicator For Tab Bar
extension TabViewController{
    
    
    // MARK: - Show Activity Indicator
    func showLoader(){
        self.indicator.startAnimating()
        blurEffectView = Utils.getBlurView(effect: .systemUltraThinMaterial, intensity: 0.13)
        
        blurEffectView.frame = view.bounds
        
        
        self.view.addSubview(self.blurEffectView)
        self.view.addSubview(self.indicator)
        
    }
    
    // MARK: - Hide Activity Indicator
    func hideLoader(){
        indicator.stopAnimating()
        self.blurEffectView.removeFromSuperview()
        self.indicator.removeFromSuperview()
        
    }
}
