//
//  ProviderDelegate.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/11/2022.
//

import Foundation
import UIKit
import CallKit
import AVFoundation
import OpenTok
import SwiftSignalRClient

final class ProviderDelegate: NSObject, CXProviderDelegate {

    let callManager: SpeakerboxCallManager
    private let provider: CXProvider
    
    var callCutTimerCounter = 30
    var callCutTimer: Timer? = nil

    var callerIdentifier = ""
    
    var userInfo: [AnyHashable: Any?] = [:]
    
    var callType: CallType?
    
    init(callManager: SpeakerboxCallManager) {
        self.callManager = callManager
        provider = CXProvider(configuration: type(of: self).providerConfiguration)

        super.init()
        
        provider.setDelegate(self, queue: nil)
    }
    
    // in case user closed the controller, this won't happen in this scenerio
    deinit {
        self.callCutTimer?.invalidate()
        self.callCutTimer = nil
    }

    /// The app's provider configuration, representing its CallKit capabilities
    static var providerConfiguration: CXProviderConfiguration {
        let localizedName = NSLocalizedString("CallKitDemo", comment: "Name of application")
        let providerConfiguration = CXProviderConfiguration(localizedName: localizedName)

        providerConfiguration.supportsVideo = false
        
//        providerConfiguration.

        providerConfiguration.maximumCallsPerCallGroup = 1

        providerConfiguration.supportedHandleTypes = [.phoneNumber]

//        providerConfiguration.iconTemplateImageData = #imageLiteral(resourceName: "IconMask").pngData()

        providerConfiguration.ringtoneSound = "Ringtone.caf"
        
        return providerConfiguration
    }
    
    lazy var signalRConnection: HubConnection? = {
//        var connectionHub: HubConnection?
        guard let connectionHub = SignalRService.signalRService.connection else {
            var signalRConnection: HubConnection?
            SignalRService.signalRService.initializeSignalR { connection in
                signalRConnection = connection
            }
            
            return signalRConnection
        }
        
        return connectionHub
    }()
    

    // MARK: Incoming Calls

    /// Use CXProvider to report the incoming call to the system
//    func reportIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, userInfo: NSDictionary, completion: ((NSError?) -> Void)? = nil) {
//        // Construct a CXCallUpdate describing the incoming call, including the caller.
//        let update = CXCallUpdate()
//        update.remoteHandle = CXHandle(type: .generic, value: handle)
//        update.hasVideo = hasVideo
//        isVideo = hasVideo
//        self.uuid = uuid
//        self.userInfo = userInfo
//        // pre-heat the AVAudioSession
//        //OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
//
//        // Report the incoming call to the system
//        provider.reportNewIncomingCall(with: uuid, update: update) { error in
//            /*
//                Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
//                since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
//             */
//            if error == nil {
//                if !hasVideo {
//                    let call = SpeakerboxCall(uuid: uuid)
//                    call.handle = handle
//
//                    self.callManager.addCall(call, hasVideo: hasVideo)
//                }
//                self.callCutTimerCounter = 30
//                self.callCutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callCutTimerFunction), userInfo: nil, repeats: true)
//            }
//
//            completion?(error as NSError?)
//        }
//    }
    
//
//    func reportIncomingCallwithIdentifier(uuid: UUID, handle: String, callType: CallType, userInfo: NSDictionary, identifier: String,completion: ((NSError?) -> Void)? = nil) {
//        // Construct a CXCallUpdate describing the incoming call, including the caller.
//        let update = CXCallUpdate()
//        update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
//        update.hasVideo = callType == .audioSingle ? false : true
//        isVideo = callType == .audioSingle ? false : true
//        self.callType = callType
//        self.uuid = uuid
//        self.callerIdentifier = identifier
//        self.userInfo = userInfo
//        // pre-heat the AVAudioSession
//        //OTAudioDeviceManager.setAudioDevice(OTDefaultAudioDevice.sharedInstance())
//
//        // Report the incoming call to the system
//        provider.reportNewIncomingCall(with: uuid, update: update) { error in
//            /*
//                Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
//                since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
//             */
//            if error == nil {
//                if callType == .audioSingle ? true : false {
//                    let call = SpeakerboxCall(uuid: uuid)
//                    call.handle = handle
//
//                    self.callManager.addCall(call, hasVideo: callType == .audioSingle ? false : true)
//                }
//                self.callCutTimerCounter = 30
//                self.callCutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callCutTimerFunction), userInfo: nil, repeats: true)
//            }
//
//            completion?(error as NSError?)
//        }
//    }

    // MARK: CXProviderDelegate

    func providerDidReset(_ provider: CXProvider) {
        print("Provider did reset")
        /*
            End any ongoing calls if the provider resets, and remove them from the app's list of calls,
            since they are no longer valid.
         */
    }

    var outgoingCall: SpeakerboxCall?
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {        // Create & configure an instance of SpeakerboxCall, the app's model class representing the new outgoing call.
        let call = SpeakerboxCall(uuid: action.callUUID, isOutgoing: true)
        call.handle = action.handle.value

        /*
            Configure the audio session, but do not start call audio here, since it must be done once
            the audio session has been activated by the system after having its priority elevated.
         */
        // https://forums.developer.apple.com/thread/64544
        // we can't configure the audio session here for the case of launching it from locked screen
        // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
        // please look for  * pre-heat the AVAudioSession *
        configureAudioSession()
        
        /*
            Set callback blocks for significant events in the call's lifecycle, so that the CXProvider may be updated
            to reflect the updated state.
         */
        call.hasStartedConnectingDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, startedConnectingAt: call.connectingDate)
        }
        call.hasConnectedDidChange = { [weak self] in
            self?.provider.reportOutgoingCall(with: call.uuid, connectedAt: call.connectDate)
        }

        self.outgoingCall = call
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    var answerCall: SpeakerboxCall?

    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }

        // Update the SpeakerboxCall's underlying hold state.
        call.isOnHold = action.isOnHold

        // Stop or start audio in response to holding or unholding the call.
        call.isMuted = call.isOnHold

        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
            action.fail()
            return
        }
        
        call.isMuted = action.isMuted
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }

    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        print("Timed out \(#function)")

        // React to the action timeout if necessary, such as showing an error UI.
    }

    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        print("Received \(#function)")
        
        // If we are returning from a hold state
        if answerCall?.hasConnected ?? false {
            //configureAudioSession()
            // See more details on how this works in the OTDefaultAudioDevice.m method handleInterruptionEvent
            sendFakeAudioInterruptionNotificationToStartAudioResources();
            return
        }
        if outgoingCall?.hasConnected ?? false {
            //configureAudioSession()
            // See more details on how this works in the OTDefaultAudioDevice.m method handleInterruptionEvent
            sendFakeAudioInterruptionNotificationToStartAudioResources()
            return
        }
        
        // Start call audio media, now that the audio session has been activated after having its priority boosted.
        outgoingCall?.startCall(withAudioSession: audioSession) { [weak self] success in
            guard let outgoingCall = self?.outgoingCall else { return }
            if success {
                self?.callManager.addCall(outgoingCall)
                self?.outgoingCall?.startAudio()
            } else {
                self?.callManager.end(call: outgoingCall)
            }
        }
        
        answerCall?.answerCall(withAudioSession: audioSession) { success in
            if success {
                self.answerCall?.startAudio()
            }
        }
    }

    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        print("Received \(#function)")

        /*
             Restart any non-call related audio now that the app's audio session has been
             de-activated after having its priority restored to normal.
         */
        if outgoingCall?.isOnHold ?? false || answerCall?.isOnHold ?? false {
            print("Call is on hold. Do not terminate any call")
            return
        }
        
        outgoingCall?.endCall()
        outgoingCall = nil
        answerCall?.endCall()
        answerCall = nil
        callManager.removeAllCalls()
    }
    
    
    
    func sendFakeAudioInterruptionNotificationToStartAudioResources() {
        var userInfo = Dictionary<AnyHashable, Any>()
        let interrupttioEndedRaw = AVAudioSession.InterruptionType.ended.rawValue
        userInfo[AVAudioSessionInterruptionTypeKey] = interrupttioEndedRaw
        NotificationCenter.default.post(name: AVAudioSession.interruptionNotification, object: self, userInfo: userInfo)
    }
    
    func configureAudioSession() {
        // See https://forums.developer.apple.com/thread/64544
        let session = AVAudioSession.sharedInstance()
        do {
//            try session.setMode(.default)
            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: .default, options: [.duckOthers, .allowBluetoothA2DP, .allowBluetooth] )
            try session.setMode(AVAudioSession.Mode.default)
            try session.setPreferredSampleRate(44100.0)
            try session.setPreferredIOBufferDuration(0.005)
            try session.setActive(true)
        } catch {
            print(error)
        }
    }
}
// MARK: - Signal R Methods
extension ProviderDelegate{
    
    // MARK: - This Signal R method will be invoke when receiver end the call
    private func signalRCallDropByReceiverInvoke() {
        
        self.signalRConnection?.invoke(method: "CallDeclinedByReceiver", self.userInfo["callerIdentifier"] as? String ?? "") { error in
            if let error {
                // show some error if required
                print("\(self.getCallTypeStringForDebugging())Call drop by receiver error: \(error.localizedDescription)")
            } else {
                // do nothing
                print("\(self.getCallTypeStringForDebugging())Call drop by receiver succesfully invoked")
            }
        }
    }
}

// extension created to seperate calling code
extension ProviderDelegate {
    
    // MARK: - User Accepts the Call
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        
        if PreferencesManager.isDeviceLocked() {
            self.generatePushNotificationForCall()
            guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
                action.fail()
                return
            }

            /*
                Configure the audio session, but do not start call audio here, since it must be done once
                the audio session has been activated by the system after having its priority elevated.
             */
            
            // https://forums.developer.apple.com/thread/64544
            // we can't configure the audio session here for the case of launching it from locked screen
            // instead, we have to pre-heat the AVAudioSession by configuring as early as possible, didActivate do not get called otherwise
            // please look for  * pre-heat the AVAudioSession *

            self.answerCall = call
            // Signal to the system that the action has been successfully performed.
            action.fulfill()
            
        } else {
            self.callCutTimer?.invalidate()
            self.callCutTimer = nil
            
            let dictionary = [
                "isAccepted": true,
                "callType": self.callType,
                "uuID": action.uuid, // send uuid back, this will be used to end the call although we are currently using "callManager.callController.callObserver.calls.first?.uuid" to end the call from controller, but if this cause issues in future, we can used this uuid (action.uuid).
                "userName": self.userInfo["userName"] ?? nil, // will be used in SingleAVCallingVC
                "displayURL": self.userInfo["displayURL"] ?? nil // will be used in SingleAVCallingVC
            ] as [String : Any?]
            
            NotificationCenter.default.post(name: .actionForCall, object: dictionary) // Defined in AppDelegate
            
            // Signal to the system that the action has been successfully performed.
            action.fulfill()
            
        }
    }
    
    func generatePushNotificationForCall() {
        
        var date = Date()
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        let notificationCenter = UNUserNotificationCenter.current()

        for i in 0...14 { // Generate 10 notification for 40 seconds total, (1 notification per 4 seconds), remove previous notification before presenting new notification to avoid duplication of                     notification.
            let content = UNMutableNotificationContent()
            
            content.title = "Incoming call from \((self.userInfo["userName"] as? String) ?? "Swarm Circle User")"
            content.body = "Unlock your phone to and tap here to attend the call"
            
            self.userInfo["isAccepted"] = true
            self.userInfo["callType"] = "\(self.callType?.rawValue ?? "")"
            
            content.userInfo = self.userInfo as [AnyHashable : Any]
            
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            
            let secondsToAdd = 2 // this value will decide the frequency of notification, (4 means, 1 notification every 4 seconds)
            
            dateComponents.second = secondsToAdd
            guard let futureDate = dateComponents.calendar?.date(byAdding: dateComponents, to: date),
                  let futureDateComponents = dateComponents.calendar?.dateComponents([.day, .hour, .minute, .second], from: futureDate) else { return }
            date = futureDate

            // Create the trigger as a repeating event.
            let trigger = UNCalendarNotificationTrigger(
                dateMatching: futureDateComponents, repeats: true)
            
            // Create the request
            let notificationIdentifier = "lockScreenCallNotification,\(i)" // you can use this indentifier if you want to cancel a notification
            let request = UNNotificationRequest(identifier: notificationIdentifier,
                                                content: content, trigger: trigger)
            
            // Schedule the request with the system.
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print("Add local notification error: \(error!)")
                }
            }
        }

        
        //        var i = 0
        ////        userInfo["body"] = ""
        //            let kNotificationReminder = "unlock device to attend call"//userInfo["body"] as! String
        //        while !Utils.isProtectedDataAvailable() {
        //              let center = UNUserNotificationCenter.current()
        ////                  center.delegate = self
        //                  center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
        //                    // Enable or disable features based on authorization.
        //                    if error != nil {
        //                      print("Request authorization failed!")
        //                    } else {
        //                      print("Request authorization succeeded!")
        //                      let content = UNMutableNotificationContent()
        //                      content.title = ""
        //                      content.body = kNotificationReminder
        //                      content.sound = UNNotificationSound.default
        //                      content.badge = 1
        //        //              let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: true)
        //                      let request = UNNotificationRequest(identifier: "notification.id.\(i)", content: content, trigger: nil)
        //                      // 4
        //                      UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        //                    }
        //                  }
        //              i = +1
        //            }
    }

    // MARK: - User Rejects the Call
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        
        self.callCutTimer?.invalidate()
        self.callCutTimer = nil
        
        let dictionary = [
            "isAccepted": false,
            "callType": self.callType
        ] as [String : Any?]
        
        // Invoke SignalR on single audio/video calling if receiver(user) ends the call.
        if self.callType == .audioSingle || self.callType == .videoSingle {
            self.signalRCallDropByReceiverInvoke()
        }
        
        if self.answerCall != nil {
            self.answerCall?.endCall()
            self.answerCall = nil
        }
        
        NotificationCenter.default.post(name: .actionForCall, object: dictionary) // Defined in AppDelegate
        
        // Signal to the system that the action has been successfully performed.
        action.fulfill()
    }
    
    // MARK: - Use CXProvider to report the incoming call to the system
    func reportIncomingCall(callType: CallType, uuID: UUID, userInfo: [AnyHashable: Any?], completion: ((NSError?) -> Void)? = nil) {
        
        self.callType = callType // replace this later by using a class or something that maintains all the incoming call.
        self.userInfo = userInfo
        
        // Construct a CXCallUpdate describing the incoming call, including the caller.
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: (userInfo["userName"] as? String) ?? "User")
        update.hasVideo = (callType == .videoGroup || callType == .videoSingle) ? true : false
        
        // pre-heat the AVAudioSession
//        let audioTrack = DefaultAudioDevice()
//        OTAudioDeviceManager.setAudioDevice(AVAudioSession.sharedInstance() as? OTAudioDevice)
//        OTAudioDeviceManager.setAudioDevice(audioTrack)
        
        // Report the incoming call to the system
        provider.reportNewIncomingCall(with: uuID, update: update) { error in
            /*
                Only add incoming call to the app's list of calls if the call was allowed (i.e. there was no error)
                since calls may be "denied" for various legitimate reasons. See CXErrorCodeIncomingCallError.
             */
            guard let error else {
                // Start Countdown
                self.callCutTimerCounter = 60 // CallKit notification dismiss timer
                self.callCutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callCutTimerFunction), userInfo: ["uuID": uuID], repeats: true) // set timer for incoming call, and dismiss after given number of second if the call is not picked up by the user.
                return
            }
            completion?(error as NSError?)
        }
    }
    
    // MARK: - Timer Function to end the call if the call is not picked.
    @objc func callCutTimerFunction() {
        
        self.callCutTimerCounter -= 1
        
        print("\(self.getCallTypeStringForDebugging()): \(self.callCutTimerCounter) seconds left before notification is removed")
        
        if self.callCutTimerCounter <= 0 {
            
            print("\(self.getCallTypeStringForDebugging()): Removing notification now...")
            
            var uuID: UUID?
            
            if let timerDictionary = callCutTimer?.userInfo as? NSMutableDictionary {
                uuID = timerDictionary["uuID"] as? UUID
            }
            
            self.callCutTimer?.invalidate()
            self.callCutTimer = nil
            
            self.callManager.endCall(call: self.callManager.callController.callObserver.calls.first?.uuid ?? uuID ?? UUID()) // for now we are using call call observer to get uuid because it is tested, later on we can instead flip the conditional binding and use timer dictionary value.
        }
    }
}

// this extension will have all the function for debugging.
extension ProviderDelegate {
    
    // MARK: - Get call type string for debugging
    func getCallTypeStringForDebugging() -> String {
        
        if let callType {
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
        return "Nil Call"
    }
}


//self.callsInfo.append((uuID: uuID, callType: callType, timer: 40)) // maintain all incoming call uuIDs, to end call
