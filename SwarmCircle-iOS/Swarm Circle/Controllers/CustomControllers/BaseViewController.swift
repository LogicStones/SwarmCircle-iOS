//
//  BaseViewController.swift
//  Swarm Circle
//
//  Created by Macbook on 29/04/2022.
//

import UIKit
import Kingfisher

class BaseViewController: UIViewController {

    var indicator = UIActivityIndicatorView()
    
    var refreshControl = UIRefreshControl()
    
    var blurEffectView = CustomIntensityVisualEffectView(effect: UIBlurEffect(style: UIBlurEffect.Style.systemUltraThinMaterial), intensity: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.shadowImage = UIImage()

        // Do any additional setup after loading the view.
        self.initUserInterface()

    }
    func initUserInterface() {
        refreshControl.tintColor = .black
        refreshControl.addTarget(self, action: #selector(pullToRefreshActionPerformed), for: .valueChanged)
        
        indicator = UIActivityIndicatorView.customIndicator(at: self.view.center)
        self.setBackButtonIcon()
    }
    
    // Pull to refresh method
    @objc func pullToRefreshActionPerformed() {
        // Override this child class
    }
    
    // MARK: - Show Activity Indicator
    func showLoader(){
        
        blurEffectView = Utils.getBlurView(effect: .systemUltraThinMaterial, intensity: 0.13)
        
        blurEffectView.frame = view.bounds
        
        
        self.view.addSubview(self.blurEffectView)
        self.view.addSubview(self.indicator)
        self.indicator.startAnimating()
    }
    
    // MARK: - Hide Activity Indicator
    func hideLoader(){
        self.blurEffectView.removeFromSuperview()
        self.indicator.removeFromSuperview()
        indicator.stopAnimating()
    }
    
    // MARK: - Navigation
    func setBackButtonIcon(){
        self.navigationController?.navigationBar.tintColor = UIColor.black // to change the all text color in navigation bar or navigation
        self.navigationController?.navigationBar.barTintColor = UIColor.white // change the navigation background color
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black] // To change only navigation bar title text color
        
        let yourBackImage = UIImage(named: "backIcon")
        self.navigationController?.navigationBar.backIndicatorImage = yourBackImage
        self.navigationController?.navigationBar.backIndicatorTransitionMaskImage = yourBackImage
    }
    
    func scrollViewScrollToBottom(_ scrollView: UIScrollView) {
        let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.height + scrollView.contentInset.bottom)
        scrollView.setContentOffset(bottomOffset, animated: true)
    }
    
    // MARK: - Setting ToolBar on keyboard
    func setToolBarOnKeyboard(textField: UITextField) {
        textField.inputAccessoryView = getToolBar()
    }
    
    // MARK: - Setting ToolBar on keyboard
    func setToolBarOnKeyboard(textView: UITextView) {
        textView.inputAccessoryView = getToolBar()
    }
    
    private func getToolBar() -> UIToolbar {
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.sizeToFit()
        // Adding Button ToolBar
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneClick))
        doneButton.tintColor = UIColor(named: "FontColor")
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([doneButton, spaceButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        return toolBar
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Done for ToolBar
    @objc func doneClick() {
        view.endEditing(true)
    }
    
    // MARK: - Done for ScrollViewContent Tap Gesture
    @objc func myviewTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    var tapGesture = UITapGestureRecognizer()
    
    func addDismissKeyboardOnTapGesture(scrollView: UIScrollView) {
        
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(myviewTapped(_:)))
        tapGesture.numberOfTapsRequired = 1
        scrollView.addGestureRecognizer(tapGesture)
        scrollView.isUserInteractionEnabled = true
    }
    
    func popOnErrorAlert(_ msg: String) {
        Alert.sharedInstance.alertOkWindow(title: "", message: "\(msg)\nPlease try again later") { _ in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func dismissOnErrorAlert(_ msg: String, completion: (()->Void)? = nil) {
        Alert.sharedInstance.alertOkWindow(title: "", message: "\(msg)\nPlease try again later") { _ in
            self.dismiss(animated: true, completion: completion)
        }
    }
    
    func showToastThenLoader(msg: String, toastType: ToastType = .green, delay: Double = 1) {
        
        self.showToast(message: msg, delay: delay, toastType: toastType)
        
        self.view.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            self.view.isUserInteractionEnabled = true
            self.showLoader()
        }
    }
}

