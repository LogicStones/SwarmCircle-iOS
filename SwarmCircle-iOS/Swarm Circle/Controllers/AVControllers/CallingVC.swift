//
//  CallingVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/11/2022.
//

import UIKit
import OpenTok

//let kWidgetHeight = 240
//let kWidgetWidth = 320

class CallingVC: BaseViewController {
    let kWidgetHeight = 240
    let kWidgetWidth = 320
    // *** Fill the following variables using your own Project info  ***
    // ***            https://tokbox.com/account/#/                  ***
    // Replace with your OpenTok API key
    var kApiKey = "47605761"
    // Replace with your generated session ID
    var kSessionId = "1_MX40NzYwNTc2MX5-MTY2ODUwNjcyOTk2N35pa3JzM2xyN0F6NlRteWdCazNKVVFPdVp-fg"
    // Replace with your generated token
    var kToken = "T1==cGFydG5lcl9pZD00NzYwNTc2MSZzaWc9NzFiZDJjYjVmNjA0M2IxZWRmOTI3NWM1NDg3MDJlYTI4M2Y4OWU5ZjpzZXNzaW9uX2lkPTFfTVg0ME56WXdOVGMyTVg1LU1UWTJPRFV3TmpjeU9UazJOMzVwYTNKek0yeHlOMEY2TmxSdGVXZENhek5LVlZGUGRWcC1mZyZjcmVhdGVfdGltZT0xNjY4NTA2NjkyJm5vbmNlPTkxNzk5OCZyb2xlPVBVQkxJU0hFUg=="
    
    lazy var session: OTSession = {
        return OTSession(apiKey: kApiKey, sessionId: kSessionId, delegate: self)!
    }()
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = UIDevice.current.name
        settings.audioTrack = true
        settings.videoCapture = .none
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscriber: OTSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doConnect()
    }
    
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    fileprivate func doConnect() {
        var error: OTError?
        defer {
            processError(error)
        }
        
        session.connect(withToken: kToken, error: &error)
    }
    
    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    fileprivate func doPublish() {
        var error: OTError?
        defer {
            processError(error)
        }
        self.publisher.publishVideo = false
        self.publisher.publishAudio = true
        session.publish(publisher, error: &error)
        
        if let pubView = publisher.view {
            pubView.frame = CGRect(x: Int(self.view.frame.width / 2) - Int(kWidgetWidth / 2), y: Int(self.view.frame.height / 2) - kWidgetHeight, width: kWidgetWidth, height: kWidgetHeight)
            view.addSubview(pubView)
        }
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    fileprivate func doSubscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            processError(error)
        }
        subscriber = OTSubscriber(stream: stream, delegate: self)
        
        session.subscribe(subscriber!, error: &error)
    }
    
    fileprivate func cleanupSubscriber() {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
    }
    
    fileprivate func cleanupPublisher() {
        publisher.view?.removeFromSuperview()
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            DispatchQueue.main.async {
                let controller = UIAlertController(title: "Error", message: err.localizedDescription, preferredStyle: .alert)
                controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
}
// MARK: - OTSession delegate callbacks
extension CallingVC: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        if subscriber == nil {
            doSubscribe(stream)
        }
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
    
}

// MARK: - OTPublisher delegate callbacks
extension CallingVC: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing")
        publisher.publishVideo = false
        publisher.publishAudio = true
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension CallingVC: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        DispatchQueue.main.async {
            if let subsView = self.subscriber?.view {
                subsView.frame = CGRect(x: 0, y: Int(self.view.frame.height / 2) + self.kWidgetHeight, width: self.kWidgetWidth, height: self.kWidgetHeight)
                self.view.addSubview(subsView)
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
}

