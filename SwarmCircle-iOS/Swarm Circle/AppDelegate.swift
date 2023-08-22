//
//  AppDelegate.swift
//  Swarm Circle
//
//  Created by Macbook on 27/04/2022.
//

import UIKit
import Stripe
import PayPalCheckout
import Firebase
import CallKit
import PushKit
import OpenTok
import SwiftSignalRClient

//var apiKey = "47633771"
var apiKey = "47700131"
var sessionId = ""
var tokenId = ""

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let callManager = SpeakerboxCallManager()
    var providerDelegate: ProviderDelegate?
    
    var uuID: UUID?
    
//    let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        
        if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            //            DispatchQueue.main.async {
            self.goToNotificationScreen()
            //            }
        }
        
        // Configuration Payment gateways
        self.configPaymentGateways()
              
        // Configuration Firebase Crashlytics
        FirebaseApp.configure()
        
        DispatchQueue.main.async {
            
            self.initFirebaseNotifications(application: application)
            
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("Error fetching FCM registration token: \(error)")
                } else if let token = token {
                    print("FCM registration token: \(token)")
                    //            self.fcmRegTokenMessage.text  = "Remote FCM registration token: \(token)"
                }
            }
           
        }
        
//        UNUserNotificationCenter.current().delegate = self
        
        return true

    }
    
    
    

    

    
    
    


    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


    private func initFirebaseNotifications (application : UIApplication) {
        
        let showCallScreen = UNNotificationCategory(identifier: "CallType", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([showCallScreen])
        
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
    }
}

extension AppDelegate {
    // MARK: - Config Payment Gateways
    func configPaymentGateways() {
        
        // Stripe
//        StripeAPI.defaultPublishableKey = "pk_test_51JrNACDXOF6QaTF3NbqmhAsmYmifwBXjuZNz4EjXZGKldVnZQwQm8T4EiBlpH65x6lmIplgDxuhq2Q9yluoq2qOY00BrJ9tK5W"
   //     StripeAPI.defaultPublishableKey = `````"pk_test_51MgcdqDWLWlgZAJqbv6sXHkDlFqJf3cM30uQO16Ag9kP7HWYwmYLh91eFD9BhYvpsachu0q8QrQ7dC7MsSGpwZl500u6QAX7XC"````` //SandBox Client Account
        StripeAPI.defaultPublishableKey = "pk_test_51Hyea2FcY6Xxn9CwJ6uncXoufEYeIPqKnyDs0eDRtYtBrzfea52dZBhlk2OEmckvpTXFpdkIAdu4usXRJ2lFKZiZ00NrckWKQz"
//        StripeAPI.defaultPublishableKey = "pk_live_51MgcdqDWLWlgZAJqUMDd9RY2r1zeBtbDJDZChFpjCxNg5Dt1RVvpBiWJpF1sA4DdVlottqDfayo3MoqpViA0kLVH00K69MS66C" //Live Client Account
        
        // PayPal
//        let config = CheckoutConfig( // sandbox
//                clientID: "AaO8rG_A1iYraAt3xtHB8Uy0dMsKYpL3tt5sKn1cV-Rzz1FRyNKVry4VRTq-hVFUuWSGRX4ANng5pbzP",
//                environment: .sandbox
//            )
        let config = CheckoutConfig( // sandbox
                clientID: "AR50rzqsyh6gH9MFojA7cqRWO_blw6SSrcYcvPoDHIFNgwDiCsZARFdaXe5_1WxH5JLImb7OODTZS0N7",
                environment: .sandbox
            )
        // PayPal
//        let config = CheckoutConfig( // live
////                clientID: "ATMqAJOdmTDW8wg_Y1qCRTxRUzLdL5MlH85kHSOxjclADt1FkaragDoQ6UxLelFV7CbBMdslsIjXOk_C", //SandBox Client Account
//                clientID: "Afj7A8k-TjfjPWD9JChLt5kfio9lULobw3vbBFjE-o_foe9m4HQIhGD9F2Ttb4BiJxQzMWfR-J-kKFQx", //Live Client Account
////                Client Secret: EO8eS9Y8CRy5TaRiNoSutT-EPuT9hnnlFCCIicpOC55dEla5nBr632bqw7lYTADpOMLlVucGl2yWnzhn
//                environment: .live
//            )
        Checkout.set(config: config)
    }
}

extension AppDelegate : MessagingDelegate, UNUserNotificationCenterDelegate {
    
    
    
    //
        func userNotificationCenter(_ center: UNUserNotificationCenter,
                                    willPresent notification: UNNotification,
          withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            
            let userInfo = notification.request.content.userInfo
            print(userInfo)
          Messaging.messaging().appDidReceiveMessage(userInfo)
                    

          // Change this to your preferred presentation option
            if notification.request.content.categoryIdentifier != "CallType"{
//                completionHandler(UNNotificationPresentationOptions(rawValue: 0))
                completionHandler([.alert, .sound, .badge])
            } else {
//                incomingCall(userName: notification.request.content.title)
                completionHandler([.alert, .sound, .badge])
            }
            
          
        }

    // Perform action after user taps the notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        if let userInfo = response.notification.request.content.userInfo as? [String: Any] {
            
            if let isAccepted = userInfo["isAccepted"] as? Bool  {
                
                guard let callTypeString = userInfo["callType"] as? String else {
                    return
                }
                
                if isAccepted {
                    
                    UNUserNotificationCenter.current().removeAllDeliveredNotifications()
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                    
                    let callType: CallType? = self.convertStringCallTypeToEnum(callTypeString)
                    
                    self.providerDelegate?.callCutTimer?.invalidate()
                    self.providerDelegate?.callCutTimer = nil
                    
                    switch callType {
                        
                    case .audioSingle, .videoSingle:
                        
                        let userInfo = [ // only send relevant data to next controller
                            .userName: userInfo["userName"],
                            .displayURL: userInfo["displayURL"]
                        ] as [SingleAVCallingVC.UserInfoKey: Any?]
                        
                        self.presentSingleCallScreen(callType: callType!, uuID: self.uuID ?? UUID(), userInfo: userInfo)
                        
                    case .audioGroup, .videoGroup:
                        self.presentGroupCallScreen(callType: callType!, uuID: self.uuID ?? UUID())
                    case .none:
                        print("Something went wrong")
                    }
                    
                } else {
                    // do something eg: fire signalR, as of now there is nothing to do for group calling if the user(receiver) has decline the call in group calling.
                    // Note: for single calling we have to invoke signalR, which is already invoked in the ProviderDelegate class.
                }
                
            } else {
                if response.notification.request.content.userInfo.count > 0
                {
                    if let notification = response.notification.request.content.userInfo as? [String : AnyObject] {
                        //                    let userInfo = JSON(notification)
                        print(notification)
                        
                        
                        //                    handleRemoteNotification(notification: notification)
                        self.goToNotificationScreen()
                    }
                    
                }
            }
            
        }
        
        
        //            self.goToNotificationScreen()
        completionHandler()
        
    }
    
    fileprivate func convertStringCallTypeToEnum(_ callTypeString: String) -> CallType? {
        switch callTypeString {
        case "audioSingle":
            return .audioSingle
        case "videoSingle":
            return .videoSingle
        case "audioGroup":
            return .audioGroup
        case "videoGroup":
            return .videoGroup
        default:
            return .none
        }
    }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Oh no! Failed to register for remote notifications with error \(error)")
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
      Messaging.messaging().apnsToken = deviceToken
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        PreferencesManager.saveFirebaseToken(fcmToken ?? "Firebase FCM Token not received")
    }
    
    func goToNotificationScreen() {
        
        if let vc = AppStoryboard.Interaction.instance.instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0, execute: {
                if let app =  UIApplication.getTopController() {
                    app.navigationController?.pushViewController(vc, animated: true)
                } else {
                    UserDefaults.standard.set(true, forKey: "notificationExist")
                }
            })
            
        }else {
            UserDefaults.standard.set(true, forKey: "notificationExist")
        }
    }
}

// Extension created to seperate audio/video single/group calling code
extension AppDelegate {
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
//        UserDefaults.standard.set(userInfo, forKey: "a")
        Messaging.messaging().appDidReceiveMessage(userInfo)

        self.reportIncomingCall(userInfo: userInfo)

//        UserDefaults.standard.set(userInfo, forKey: "a")
//        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        completionHandler(.noData)
    }

    
    // MARK: - Report incoming single/group audio/video call
    func reportIncomingCall(userInfo: [AnyHashable: Any]) {
        
        guard
            let isGroupCall = userInfo["isGroupCall"] as? String,
            let sessionID = userInfo["sessionId"] as? String,
            let tokenID = userInfo["tokenID"] as? String,
            let isVideoCall = userInfo["isVideoCall"] as? Int
        else {
            return
        }
        
        print("Session ID: \(sessionId)")
        print("Session ID Token: \(tokenId)")
        sessionId = sessionID
        tokenId = tokenID
        print("Session ID: \(sessionId)")
        print("Session ID Token: \(tokenId)")
        
        let uuID = UUID() // will be used to start (and maybe end call also)
        
        self.uuID = uuID
        
        self.signalRCallDropByCallerOn(uuID: uuID) // setup signalR function, incase the caller drop the call, this function will be invoked.
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.callKitActionForProvideDelegate(_:)), name: .actionForCall, object: nil) // this observer will be fired after user accepts/reject the call
        
        let userInfo = [
            "userName": userInfo["userName"], // will be used to display caller name on CallKit screen audio/video single/group & 'SingleAVCallingVC' screen.
            "displayURL": userInfo["displayURL"], // will only be used in 'SingleAVCallingVC' screen, only send relevant data to next controller, 'ProviderDelegate' -> 'AppDelegate' -> SingleAVCallingVC
            "callerIdentifier": userInfo["callerIdentifier"]
        ] as [String: Any?]
        
        self.providerDelegate?.reportIncomingCall(callType: self.getCallType(isGroupCall: isGroupCall, isVideoCall: isVideoCall), uuID: uuID, userInfo: userInfo) { error in
            
            print("\(self.getCallTypeStringForDebugging(callType: self.getCallType(isGroupCall: isGroupCall, isVideoCall: isVideoCall)))Error while reporting incoming call, error: \(error?.localizedDescription ?? "")")
        }
    }
    
    // MARK: - Get call type from userInfo dictionary (retrieved from notification)
    func getCallType(isGroupCall: String, isVideoCall: Int) -> CallType {
        if isGroupCall != "True" {
            return isVideoCall == 1 ? .videoSingle : .audioSingle
        } else {
            return isVideoCall == 1 ? .videoGroup : .audioGroup
        }
    }
    
    // MARK: - CallKit Action For Group Audio/Video (fired when the user accepts/rejects call from CallKit screen)
    @objc func callKitActionForProvideDelegate(_ notification: NSNotification) {
        
        print("AppDelegate Observer Called")
        
        defer {
            NotificationCenter.default.removeObserver(self, name: Notification.Name.actionForCall, object: nil)
//            NotificationCenter.default.removeObserver(Notification.Name.actionForCall)
            print("AppDelegate Observer Removed")
        }
        
        
        guard let dictionary = notification.object as? NSDictionary else {
            return
        }

        guard let isAccepted = dictionary["isAccepted"] as? Bool else {
            return
        }
        guard let callType = dictionary["callType"] as? CallType else {
            return
        }
        guard let uuID = dictionary["uuID"] as? UUID else {
            return
        }
        
        if isAccepted {
            
//            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            
            switch callType {
                
            case .audioSingle, .videoSingle:
                
                let userInfo = [ // only send relevant data to next controller
                    .userName: dictionary["userName"],
                    .displayURL: dictionary["displayURL"]
                ] as [SingleAVCallingVC.UserInfoKey: Any?]
                
                self.presentSingleCallScreen(callType: callType, uuID: uuID, userInfo: userInfo)
                
            case .audioGroup, .videoGroup:
                self.presentGroupCallScreen(callType: callType, uuID: uuID)
            }
            
        } else {
            // do something eg: fire signalR, as of now there is nothing to do for group calling if the user(receiver) has decline the call in group calling.
            // Note: for single calling we have to invoke signalR, which is already invoked in the ProviderDelegate class.
        }
    }
    
    // MARK: - Present Single Call Screen after user has picked up the call
    func presentSingleCallScreen(callType: CallType, uuID: UUID, userInfo: [SingleAVCallingVC.UserInfoKey: Any?]) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            
            if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "SingleAVCallingVC") as? SingleAVCallingVC {
                
                let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
                navController.modalTransitionStyle = .crossDissolve
                navController.modalPresentationStyle  = .overFullScreen
                
                vc.callType = callType // used to show/hide call action buttons.
                vc.uuID = uuID // (maybe) used to end call
                
                vc.userInfo = userInfo
                
                guard let topMostController = UIApplication.getTopController() else {
                    self.providerDelegate?.generatePushNotificationForCall()
                    return
                }
                if topMostController is SingleAVCallingVC { // don't show screen if calling screen is already open (resolves double screen open issue), this condition is placed just to be on the safe side, we can remove this later.
                    return
                }
 
                topMostController.present(navController, animated: true)
            }
        }
    }
    
    // MARK: - Present Group Call Screen after user has picked up the call
    func presentGroupCallScreen(callType: CallType, uuID: UUID) {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            
            if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "GroupAVCallingVC") as? GroupAVCallingVC {
                
                let navController = UINavigationController(rootViewController: vc) // Creating a navigation controller with VC1 at the root of the navigation stack.
                navController.modalTransitionStyle = .crossDissolve
                navController.modalPresentationStyle  = .overFullScreen
                
                vc.callType = callType // used to show/hide call action buttons.
                vc.uuID = uuID // (maybe) used to end call
                
                guard let topMostController = UIApplication.getTopController() else {
                    self.providerDelegate?.generatePushNotificationForCall()
                    return
                }
                if topMostController is GroupAVCallingVC { // don't show screen if calling screen is already open (resolves double screen open issue)
                    return
                }
                topMostController.present(navController, animated: true)
            }
        }
    }
    
    // MARK: - SignalR Call Drop By Caller 'on'
    func signalRCallDropByCallerOn(uuID: UUID) {
        
        self.providerDelegate?.signalRConnection?.on(method: "CallDeclinedReceiverClient") { (user: String) in
            
            print("SignalR Call Drop By Caller On -> user: \(user)")
            
            // Remove call from CallKit
            self.callManager.endCall(call: self.uuID ?? UUID())
        }
    }
}

// this extension will have all the function for debugging.
extension AppDelegate {
    
    // MARK: - Get call type string for debugging
    func getCallTypeStringForDebugging(callType: CallType) -> String {
        
        switch callType {
        case .audioSingle:
            return "One to One Audio Call"
        case .videoSingle:
            return "One to One Video Call"
        case .audioGroup:
            return "Group Audio Call"
        case .videoGroup:
            return "Group Video Call"
        }
    }
}

