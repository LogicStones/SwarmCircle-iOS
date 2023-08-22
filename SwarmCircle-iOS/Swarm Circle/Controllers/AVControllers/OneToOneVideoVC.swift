//
//  OneToOneVideoVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 30/11/2022.
//

import UIKit
import OpenTok

class OneToOneVideoVC: BaseViewController {
    
    var kWidgetHeight = 320.0
    var kWidgetWidth = 240.0
    
    let signalRConnection = SignalRService.signalRService.connection
    
    var viewModel = ViewModel()
    var userName: String?
    var imgUrl: String?
    var uuID: UUID? = nil
    
    var isCaller = false
    
    var identifier = ""
    
    @IBOutlet weak var profilePicImgView: CircleImage!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var swrmCircleImage: UIImageView!
    @IBOutlet weak var callEndButton: UIButton!
    @IBOutlet weak var subscriberVideoView: UIView!
    
    let customAudioDevice = DefaultAudioDevice()
    
    var callCutTimerCounter = 30
    var callCutTimer: Timer? = nil
    
    lazy var session: OTSession = {
        return OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)!
    }()
    
    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? ""), \(PreferencesManager.getUserModel()?.displayImageURL ?? "")"
        settings.audioTrack = true
        return OTPublisher(delegate: self, settings: settings)!
    }()
    
    var subscriber: OTSubscriber?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initUI()
        OTAudioDeviceManager.setAudioDevice(customAudioDevice)
        doConnect()
        
        if self.isCaller {
            self.callCutTimerCounter = 30
            self.callCutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callCutTimerFunction), userInfo: nil, repeats: true)
        }
        
    }
    
    // in case user closed the controller
    deinit {
//        self.callCutTimer?.invalidate()
//        self.callCutTimer = nil
        viewModel.callMemberStop()
    }
    
    @objc func callCutTimerFunction() {
        
        self.callCutTimerCounter -= 1
        print("121 Video Calling \(self.callCutTimerCounter) seconds left")
        if self.callCutTimerCounter == 0 {
            
            self.showToast(message: "\(userName ?? "User") did not pick up the call", toastType: .red)
            
            self.callEndButton.isEnabled = false
            if isCaller{
                self.signalRCallDropByCallerInvoke()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.dismissNEndCall()
            }
            
            self.callCutTimer?.invalidate()
            self.callCutTimer = nil
            
        }
    }
    
    
    func initUI() {
        self.kWidgetHeight = self.view.frame.height / 5
        self.kWidgetWidth = self.view.frame.width / 3
        //        self.signalRCallDropByReceiverOnReceive()
        self.signalRCallDropByReceiver()
        
        PreferencesManager.saveCallState(isCallActivated: true)
        
        //        if let info = subscriber?.stream?.name {
        //
        //            if let imgUrl = Utils.getCompleteURL(urlString: (String(info[1]))) {
        //                self.profilePicImgView.kf.setImage(with: imgUrl, placeholder: UIImage(named: "defaultProfileImage"))
        //            } else {
        //                self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        //            }
        //
        //            self.nameLbl.text = String(info[0])
        //        }
        
        if let imgUrl = Utils.getCompleteURL(urlString: self.imgUrl) {
            self.profilePicImgView.kf.setImage(with: imgUrl, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        if let userName {
            self.nameLbl.text = userName
        }
    }
    
    func dismissNEndCall() {
        //        if let publisher = publisher {
        
        var error: OTError?
        
        session.unpublish(self.publisher, error: &error)
        if error != nil {
            print(error!)
        }
        session.disconnect(&error)
        if error != nil {
            print(error!)
        }
        if let subscriber = subscriber {
            session.unsubscribe(subscriber, error: &error)
            print(error!)
        }
        
        self.dismiss(animated: true) {
            
            self.viewModel.callMemberStop()
            if !self.isCaller{
                let callManager = SpeakerboxCallManager()
                callManager.endCall(call: self.uuID ?? UUID())
            }
        }
    }
    
    @IBAction func speakerBtnTapped(_ sender: UIButton) {
        //        self.subscriber.
    }
    
    @IBAction func micBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.publisher.publishAudio = !self.publisher.publishAudio
    }
    
    @IBAction func callDropBtnTapped(_ sender: UIButton) {
        self.callEndButton.isEnabled = false
        if isCaller{
            self.callCutTimer?.invalidate()
            self.callCutTimer = nil
            self.signalRCallDropByCallerInvoke()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.dismissNEndCall()
        }
    }
    
    
    //    #3B5998
    @IBAction func videoBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.publisher.publishVideo = !self.publisher.publishVideo
    }
    
    @IBAction func swapBtnTapped(_ sender: UIButton) {
        self.publisher.cameraPosition = self.publisher.cameraPosition == .back ? .front : .back
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
        
        session.connect(withToken: tokenId, error: &error)
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
        
        session.publish(publisher, error: &error)
        
        if let pubView = publisher.view {
            pubView.frame = CGRect(x: self.view.frame.maxX - self.kWidgetWidth, y: 0, width: self.kWidgetWidth, height: self.kWidgetHeight)
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
        self.subscriberVideoView.subviews.first?.removeFromSuperview()
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
        self.dismissNEndCall()
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
extension OneToOneVideoVC: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
        self.dismissNEndCall()
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        DispatchQueue.main.async {
            if self.subscriber == nil {
                self.doSubscribe(stream)
            }
        }
        //        OTAudioDeviceManager.currentAudioDevice()?.setAudioBus(OTDefaultAudioDevice.kAudioDeviceHeadset as? OTAudioBus)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        if let subStream = subscriber?.stream, subStream.streamId == stream.streamId {
            cleanupSubscriber()
            cleanupPublisher()
            
            ViewModel().callMemberStop()
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
    
}

// MARK: - OTPublisher delegate callbacks
extension OneToOneVideoVC: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        print("Publishing")
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        cleanupPublisher()
        if let subStream = self.publisher.stream, subStream.streamId == stream.streamId {
            cleanupPublisher()
        }
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension OneToOneVideoVC: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
        
        self.callCutTimer?.invalidate()
        self.callCutTimer = nil
        
        if let subsView = self.subscriber?.view {
            subsView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
            self.subscriberVideoView.addSubview(subsView)
        }
    }
    
    func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        //        self.dismissNEndCall()
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
}
// MARK: - Signal R Methods
extension OneToOneVideoVC {
    
    // MARK: - Signal R Caller Drop Call By Caller
    private func signalRCallDropByCallerInvoke() {
        
        self.signalRConnection?.invoke(method: "CallDeclinedByCaller", self.identifier) { error in
            if let error {
                // show some error if required
                print("Call drop by caller error: \(error.localizedDescription)")
            } else {
                // do nothing
                print("Call drop by caller succesfully invoked")
            }
        }
    }
    
    private func signalRCallDropByReceiver() {
        self.signalRConnection?.on(method: "CallDeclinedCallerClient") { (user: String) in
            self.showToast(message: "\(user.capitalized) is busy.", toastType: .red)
            self.dismissNEndCall()
            print("signalRCallDropByReceiver is called from OneToOne Video Calling")
            
        }
    }
}
