//
//  SpeakerboxCallManager.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/11/2022.
//

import UIKit
import CallKit
import OpenTok

final class SpeakerboxCallManager: NSObject {
    
    enum Call: String {
        case start = "startCall"
        case end = "endCall"
        case hold = "holdCall"
        case muted = "muteCall"
    }

    let callController = CXCallController()

    // MARK: Actions

    func startCall(handle: String, video: Bool = false) {
        
        let handle = CXHandle(type: .phoneNumber, value: handle)
        
        let startCallAction = CXStartCallAction(call: UUID(), handle: handle)

        startCallAction.isVideo = video

//        guard let appDelegate = AppDelegate().providerDelegate else { return }
//        appDelegate.
        let transaction = CXTransaction()
        transaction.addAction(startCallAction)

        requestTransaction(transaction, action: Call.start.rawValue)
    }
    
    
    func startCalling(with uuid: UUID, calleeID: String, hasVideo: Bool, completionHandler: ((NSError?) -> Void)? = nil) {
        // 1
        let handle = CXHandle(type: .generic, value: calleeID)
        let startCallAction = CXStartCallAction(call: uuid, handle: handle)
        
        // 2
        startCallAction.isVideo = hasVideo
        
        // 3
        self.requestCallTransaction(with: startCallAction, completionHandler: completionHandler)
    }

    func end(call: SpeakerboxCall) {
        let endCallAction = CXEndCallAction(call: call.uuid)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)

        requestTransaction(transaction, action: Call.end.rawValue)
    }
    
    func endCall(call: UUID) {
        let endCallAction = CXEndCallAction(call: call)
        let transaction = CXTransaction()
        transaction.addAction(endCallAction)

        requestTransaction(transaction, action: Call.end.rawValue)
    }

    func setHeld(call: SpeakerboxCall, onHold: Bool) {
        let setHeldCallAction = CXSetHeldCallAction(call: call.uuid, onHold: onHold)
        let transaction = CXTransaction()
        transaction.addAction(setHeldCallAction)

        requestTransaction(transaction, action: Call.hold.rawValue)
    }
    
    func setMute(call: SpeakerboxCall, isMuted: Bool) {
        let setMutedCallAction = CXSetMutedCallAction(call: call.uuid, muted: isMuted)
        let transaction = CXTransaction()
        transaction.addAction(setMutedCallAction)

        requestTransaction(transaction, action: Call.muted.rawValue)
    }
       
    private func requestTransaction(_ transaction: CXTransaction, action: String = "") {
        
        callController.request(transaction) { error in
            if let error = error {
                print("Error requesting transaction: \(error)")
            } else {
                print("\(action) Notification Removed")
                print("Requested transaction \(action) successfully")
            }
        }
    }
    
    private func requestCallTransaction(with action: CXCallAction, completionHandler: ((NSError?) -> Void)?) {
        let transaction = CXTransaction(action: action)
        callController.request(transaction) { error in
            completionHandler?(error as NSError?)
        }
    }

    // MARK: Call Management

    static let CallsChangedNotification = Notification.Name("CallManagerCallsChangedNotification")

    private(set) var calls = [SpeakerboxCall]()

    func callWithUUID(uuid: UUID) -> SpeakerboxCall? {
        guard let index = calls.firstIndex(where: { $0.uuid == uuid }) else {
            return nil
        }
        return calls[index]
    }

    func addCall(_ call: SpeakerboxCall, hasVideo: Bool = false) {
        calls.append(call)

        call.stateDidChange = { [weak self] in
            self?.postCallsChangedNotification()
            
        }
        
        call.hasConnectedDidChange = { [weak self] in
            print("hasConnectedDidChange")
            self?.postCallsChangedNotification(userInfo: ["action": Call.start.rawValue, "hasVideo": hasVideo])
            
        }
        

        postCallsChangedNotification(userInfo: ["action": Call.start.rawValue])
    }

    func removeCall(_ call: SpeakerboxCall) {
        calls = calls.filter {$0 === call}
        postCallsChangedNotification(userInfo: ["action": Call.end.rawValue])
    }

    func removeAllCalls() {
        calls.removeAll()
        postCallsChangedNotification(userInfo: ["action": Call.end.rawValue])
    }

    private func postCallsChangedNotification(userInfo: [String: Any]? = nil) {
        NotificationCenter.default.post(name: type(of: self).CallsChangedNotification, object: self, userInfo: userInfo)
        print(userInfo)
//        NotificationCenter.default.post(name: Notification.Name.popController, object: self, userInfo: userInfo)
    }
}
