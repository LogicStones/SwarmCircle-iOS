//
//  SingleAVCallingVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 14/12/2022.
//

import UIKit
import OpenTok
import AVFoundation

class SingleAVCallingVC: BaseViewController {
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var profilePicImgView: CircleImage!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var bigCircleImgView: UIImageView!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var callDropBtn: UIButton!
    @IBOutlet weak var mircrophoneBtn: UIButton!
    @IBOutlet weak var flipCameraBtn: UIButton!
    @IBOutlet weak var inCallTimeLbl: UILabel!
    
    var (inCallMinutes, inCallHours) = (0, 0)
    
    var inCallTimer: Timer? = nil
    var inCallTimerCounter = 0
    
    var callType: CallType? // used to start call session & set buttons, set audio device and video track
    var userInfo: [UserInfoKey: Any?] = [:] // used to display user (caller) information on the screen.
    
    enum UserInfoKey: String { // This will make sure that user has used the correct key when passing data from previous controller
        case userName
        case displayURL
        case callToIdentifier // used start call session (person identifier, you are calling to)
    }
    
    var isCallInitiater = false
    
    var viewModel = ViewModel()
    
    var uuID: UUID? = nil // UUID used to end CallKit
    
//    lazy var speakerAudio = DefaultAudioDevice() // Audio Driver used for Speaker
//
//    lazy var handsetAudio = OTDefaultAudioDevice() // Audio driver used for handset
    
    var callCutTimerCounter = 60 // controller will be dismissed if no one picks up the call in 45 seconds
    var callCutTimer: Timer? = nil
    
//    lazy var session: OTSession = {
//        return OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)!
//    }()
    
    var session: OTSession?
    var publisher: OTPublisher?
    
//    lazy var publisher: OTPublisher = {
//        var settings = OTPublisherSettings()
//        settings.name = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? ""),\(PreferencesManager.getUserModel()?.displayImageURL ?? ""),\(PreferencesManager.getUserModel()?.identifier ?? "")"
////        settings.audioTrack = true
//        settings.videoTrack = self.callType == .videoSingle ? true : false
//        return OTPublisher(delegate: self, settings: settings)!
//    }()
    
    var player: AVAudioPlayer?
    
    var subscriber: OTSubscriber?
    
    let signalRConnection = SignalRService.signalRService.connection

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.initUI()
        self.initVariable()
    }
    
    
    deinit {
        print(self.viewModel)
        self.viewModel.callMemberStop()
        self.destroySession()
        Utils.unconfigureAudioSession()
        
//        self.stopCallNDismiss()
       
    }
    
    // MARK: - Initialization UI
    func initUI() {
        
        self.profilePicImgView.kf.indicatorType = .activity
        
        if let imgUrl = Utils.getCompleteURL(urlString: self.userInfo[.displayURL] as? String) {
            self.profilePicImgView.kf.setImage(with: imgUrl, placeholder: UIImage(named: "defaultProfileImage"))
            
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        if let userName = self.userInfo[.userName] as? String {
            self.userNameLbl.text = userName // the person you are calling to.
        }
        
        // Check if call type is passed from previous controller
        if self.callType == nil {
            dismissOnErrorAlert("Call Type Missing")
        }
        
        if self.callType == .audioSingle {
            self.videoBtn.isHidden = true
            self.flipCameraBtn.isHidden = true
            if self.isCallInitiater {
                self.inCallTimeLbl.text = "Ringing"
            }
        } else {
            self.speakerBtn.isHidden = true
        }
        
        self.mircrophoneBtn.isEnabled = !self.isCallInitiater
    }
    
    // MARK: - Load data
    func initVariable() {
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.audio) == .denied {
            
            Alert.sharedInstance.alertOkWindow(title: "Alert", message: "Please allow microphone access from device settings to continue") { result in
                if result {
                    self.dismiss(animated: true)
                }
            }
            return
            
        } else if self.callType == .videoSingle && AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .denied {
            Alert.sharedInstance.alertOkWindow(title: "Alert", message: "Please allow camera access from device settings to continue") { result in
                if result {
                    self.dismiss(animated: true)
                }
            }
            return
        }
        
        self.viewModel.delegateNetworkResponse = self
        
        if self.isCallInitiater {
            self.signalRCallDropByReceiverOn()
        }
        else {
            self.notifyReceiveCall()
            self.session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
            NotificationCenter.default.addObserver(self, selector: #selector(self.callKitAction(_:)), name: .actionForCall, object: nil)
        }
        
        self.setupAudioType()
        self.startSingleCallSession()
    }
    
    
    func notifyReceiveCall() {
        self.viewModel.receiveCall()
    }
    
    // MARK: - Setup speaker based on call type.
    func setupAudioType() {
        if callType == .audioSingle {
//            OTAudioDeviceManager.setAudioDevice(handsetAudio)
            Utils.configureAudioSessionType(sessionMode: .voiceChat)
        } else {
//            OTAudioDeviceManager.setAudioDevice(speakerAudio)
            Utils.configureAudioSessionType(sessionMode: .videoChat)
        }
    }
    
    @objc func callCutTimerFunction() {
        
        self.callCutTimerCounter -= 1
        
        print("Single Call Initiater: \(self.callCutTimerCounter) seconds left before SingleAVCallingVC is closed.")
        
        if self.callCutTimerCounter == 0 {
            
            self.callCutTimer?.invalidate()
            self.callCutTimer = nil
            
            self.stopCallNDismiss()
            
            self.dismiss(animated: true) {
                
                self.viewModel.callMemberStop()
                
                Alert.sharedInstance.alertOkWindow(title: "Call Ended", message: "\(self.userInfo[.userName] as? String ?? "User") did not picked up your call") { _ in }
            }
        }
    }
    
    // MARK: - Start Single Call Session
    func startSingleCallSession() {
        
        if !self.isCallInitiater {
            self.connectSession() // Subscriber connect session
            return
        }
        
        guard let callToIdentifier = self.userInfo[.callToIdentifier] as? String else {
            dismissOnErrorAlert("User Identifier Missing")
            return
        }
        
        self.showLoader()
        self.viewModel.startCallSession(callTo: callToIdentifier, callType: self.callType == .videoSingle ? 1 : 2)
    }
    
    /**
     * Asynchronously begins the session connect process. Some time later, we will
     * expect a delegate method to call us back with the results of this action.
     */
    fileprivate func connectSession() {
        
        var error: OTError?
        defer {
            self.processError(error)
        }
        if self.isCallInitiater{
            self.playDialingTone()
        }
        
        self.showToastThenLoader(msg: "Connecting session...") // show loader after 1 second (this allows user to read the toast message)
        self.session?.connect(withToken: tokenId, error: &error)
    }

    /**
     * Sets up an instance of OTPublisher to use with this session. OTPubilsher
     * binds to the device camera and microphone, and will provide A/V streams
     * to the OpenTok session.
     */
    fileprivate func startPublishing() {
        var error: OTError?
        defer {
            self.processError(error)
        }
        
        let settings = OTPublisherSettings()
        settings.name = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? ""),\(PreferencesManager.getUserModel()?.displayImageURL ?? ""),\(PreferencesManager.getUserModel()?.identifier ?? "")"
//        settings.audioTrack = true
        settings.videoTrack = self.callType == .videoSingle ? true : false
        self.publisher = OTPublisher.init(delegate: self, settings: settings)
        
        self.session?.publish(publisher!, error: &error)

        self.showSelfVideo()
    }
    
    fileprivate func showSelfVideo() {
        // Start Showing self video
        
        if let pubView = publisher?.view {
            pubView.frame = CGRect(x: self.view.frame.maxX - self.view.frame.width / 3, y: 0, width: self.view.frame.width / 3, height: self.self.view.frame.height / 5)
            view.addSubview(pubView)
        }
    }
    
    /**
     * Instantiates a subscriber for the given stream and asynchronously begins the
     * process to begin receiving A/V content for this stream. Unlike doPublish,
     * this method does not add the subscriber to the view hierarchy. Instead, we
     * add the subscriber only after it has connected and begins receiving data.
     */
    fileprivate func subscribe(_ stream: OTStream) {
        var error: OTError?
        defer {
            self.processError(error)
        }
        guard let subscriber = OTSubscriber(stream: stream, delegate: self) else {
            print("Error while subscribing")
            return
        }
        
        session?.subscribe(subscriber, error: &error)
        
        self.subscriber = subscriber
    }
    
    fileprivate func cleanupSubscriber(_ stream: OTStream) {
        subscriber?.view?.removeFromSuperview()
        subscriber = nil
        self.stopCallNDismiss()
    }
    
    fileprivate func cleanupPublisher(_ stream: OTStream){
        
        self.videoPlayerView.subviews.first?.removeFromSuperview()
        for item in self.videoPlayerView.subviews{
            if item.tag == 100 {
                item.removeFromSuperview()
            }
        }
        self.publisher?.view?.removeFromSuperview()
    }
    
    fileprivate func processError(_ error: OTError?) {
        if let error {
            Alert.sharedInstance.alertOkWindow(title: "Error", message: error.localizedDescription) { result in
                if result {
                    // Do something after error is displayed
                }
            }
        }
    }
    
    // MARK: - Speaker Button Tapped
    @IBAction func speakerBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        if sender.isSelected {
            Utils.configureAudioSessionType(sessionMode: .videoChat)
        } else {
            Utils.configureAudioSessionType(sessionMode: .voiceChat)
        }
    }
    
    @IBAction func microphoneBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.publisher!.publishAudio = !self.publisher!.publishAudio
    }
    
    // MARK: - Camera Flip Button Tapped
    @IBAction func cameraFlipBtnTapped(_ sender: UIButton) {
        
        switch self.publisher?.cameraPosition {
        case .back:
            self.publisher?.cameraPosition = .front
        case .front:
            self.publisher!.cameraPosition = .back
        case .unspecified:
            self.publisher!.publishVideo = false
        case .none:
            self.publisher!.publishVideo = false
        @unknown default:
            self.publisher!.publishVideo = false
        }
    }
    
    // MARK: - Video Button Tapped
    @IBAction func videoBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        self.publisher!.publishVideo = !self.publisher!.publishVideo
        
        if let pubView = publisher?.view {
            pubView.isHidden = !pubView.isHidden
        }
    }
    
    // MARK: - Call End Button Tapped
    @IBAction func callEndBtnTapped(_ sender: UIButton) {
        self.player?.stop()
        if self.isCallInitiater {
            self.callCutTimer?.invalidate()
            self.callCutTimer = nil
        }
        
        if self.isCallInitiater {
            self.signalRCallDropByCallerInvoke()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.stopCallNDismiss()
        }
    }
    
    // MARK: - Stop Call
    private func stopCallNDismiss() {
        
        if self.isCallInitiater {
            
            // This will turnoff microphone/video etc
            var error: OTError?
            
            self.player?.stop()
            
            if let subscriber = subscriber {
                session?.unsubscribe(subscriber, error: &error)
                print(error.debugDescription.localizedLowercase)
                if error != nil {
                    print(error!)
                }
            }
            
            if self.publisher != nil{
                session?.unpublish(self.publisher!, error: &error)
                if error != nil {
                    print(error!)
                }
            }
           
            
            session?.disconnect(&error)
            if error != nil {
                print(error!)
            }
            
        } else {
            // Remove call from callkit (Note: CallKit will only be shown to receivers)
            let callManager = SpeakerboxCallManager()
            callManager.endCall(call: callManager.callController.callObserver.calls.first?.uuid ?? self.uuID ?? UUID())
        }
        
        self.dismiss(animated: true)
    }
    
    // MARK: - Play Dial Tone When call dialed.
    private func playDialingTone(){
        do {
            player = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "dialTone", ofType: "mp3")!))
            var doSetProperty = UInt32(truncating: true)
            player?.numberOfLoops = -1
            try AVAudioSession.sharedInstance().setMode(AVAudioSession.Mode.default)
            player?.play()
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: - Session Delegates
extension SingleAVCallingVC: OTSessionDelegate {
    
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        PreferencesManager.saveCallState(isCallActivated: true)
        self.hideLoader()
        self.showToast(message: "Session connected", toastType: .green)
        self.startPublishing() // Start Publishing A/V Stream after session is connected.
        
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        self.subscribe(stream)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        self.dismiss(animated: true) {
            self.cleanupSubscriber(stream)
            var error: OTError?
            session.unpublish(self.publisher!, error: &error)
        }
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
}

// MARK: - Publisher Delegates
extension SingleAVCallingVC: OTPublisherKitDelegate {
    
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        
    }
        
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        self.viewModel.callMemberStop()
        self.cleanupPublisher(stream)
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - Subscriber Delegates
extension SingleAVCallingVC: OTSubscriberKitDelegate {
    
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
        self.player?.stop()
        if self.callType == .audioSingle {
            self.inCallTimerCounter = 0
            self.inCallTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.inCallTimerFunction), userInfo: nil, repeats: true)
        }
        
        self.callType == .audioSingle ? Utils.configureAudioSessionType(sessionMode: .voiceChat) : Utils.configureAudioSessionType(sessionMode: .videoChat)
        
        self.callCutTimer?.invalidate()
        self.callCutTimer = nil
        
//        self.setupAudioType()
        
        self.mircrophoneBtn.isEnabled = true
        
        if self.callType == .videoSingle {
            
            if let subView = self.subscriber?.view {
                
                subView.frame = CGRect(x: 0, y: 0, width: self.videoPlayerView.frame.width, height: self.videoPlayerView.frame.height)
                subView.tag = 100
                self.videoPlayerView.addSubview(subView)
                self.videoPlayerView.sendSubviewToBack(subView)
                self.videoPlayerView.sendSubviewToBack(self.userNameLbl)
                self.videoPlayerView.sendSubviewToBack(self.profilePicImgView)
                self.videoPlayerView.sendSubviewToBack(self.bigCircleImgView)
                
                subView.widthAnchor.constraint(equalTo: self.videoPlayerView.widthAnchor).isActive = true
                subView.heightAnchor.constraint(equalTo: self.videoPlayerView.heightAnchor).isActive = true
            }
        }
    }
    
    @objc func inCallTimerFunction() {
        
        self.inCallTimerCounter += 1
        
        if self.inCallTimerCounter == 60 {
            
            self.inCallTimerCounter = 0
            self.inCallMinutes += 1
            
            if self.inCallMinutes == 60 {
                
                self.inCallMinutes = 0
                self.inCallHours += 1
            }
        }
        
        self.inCallTimeLbl.text = "\(self.inCallHours) : \(self.inCallMinutes) : \(self.inCallTimerCounter)"
    }

    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        print("Subscriber disconnected")
        
        self.inCallTimer?.invalidate()
        self.inCallTimer = nil
        
        self.dismiss(animated: true)
    }
}



extension SingleAVCallingVC {
    
    // MARK: - CallKit Action for single audio/video (fired when the user rejects call from CallKit screen)
    @objc func callKitAction(_ notification: NSNotification) {
        
        print("SingleAVCalling Observer Called")
        defer{
            NotificationCenter.default.removeObserver(Notification.Name.actionForCall)
            print("SingleAVCalling Observer Removed")
        }
        
        
        guard let dictionary = notification.object as? NSDictionary else {
            return
        }

        guard let isAccepted = dictionary["isAccepted"] as? Bool else {
            return
        }

        if !isAccepted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.stopCallNDismiss()
            }
        }
    }
}

// MARK: - SignalR Methods
extension SingleAVCallingVC {
    
    // MARK: - SignalR call drop by caller 'invoke'
    private func signalRCallDropByCallerInvoke() {
        
        self.signalRConnection?.invoke(method: "CallDeclinedByCaller", (self.userInfo[.callToIdentifier] as? String) ?? "") { error in
            if let error {
                // show some error if required
                self.showToast(message: "\(error.localizedDescription)", toastType: .red)
                print("SignalR Single Calling: Call drop by caller invoke error: \(error.localizedDescription)")
            } else {
                // do nothing
                print("SignalR Single Calling: Call drop by caller succesfully invoked")
            }
        }
    }
    
    // MARK: - SignalR call drop by receiver 'on'
    private func signalRCallDropByReceiverOn() { // register
        
        self.signalRConnection?.on(method: "CallDeclinedCallerClient") { (user: String) in
            
            self.dismiss(animated: true) {
                self.player?.stop() // call ringtone was still ringing after call is dismissed by the receiver, not tested yet cause both iphone are occupied by QA.
                self.callCutTimer?.invalidate()
                self.callCutTimer = nil
                
                self.viewModel.callMemberStop()
                
                //                Alert.sharedInstance.alertOkWindow(title: "Call Ended", message: "\(self.userInfo[.userName] as? String ?? "User") declined your call") { _ in }
            }
        }
    }
    
    // MARK: - Stop Call
    private func destroySession() {
        
        var error: OTError?
        
        if self.publisher != nil {
            session?.unpublish(self.publisher!, error: &error)
            if error != nil {
                print(error!)
            }
        }
        
        if let subscriber = self.subscriber{
            session?.unsubscribe(subscriber, error: &error)
            if error != nil {
                print(error!)
            }
        }
        
        session?.disconnect(&error)
        if error != nil {
            print(error!)
        }
            
    }
}

extension SingleAVCallingVC: NetworkResponseProtocols {
    
    // MARK: - Start Call Session Response
    func didStartCallSession() {
        
        self.hideLoader()
        
        if let data = self.viewModel.startCallSessionResponse?.data {
            
            guard let sessionID = data.sessionID else {
                self.viewModel.callMemberStop()
                dismissOnErrorAlert("Session ID missing")
                return
            }
            guard let tokenID = data.tokenID else {
                self.viewModel.callMemberStop()
                dismissOnErrorAlert("Token ID missing")
                return
            }
            guard let APIKey = data.apiKey else {
                self.viewModel.callMemberStop()
                dismissOnErrorAlert("API key missing")
                return
            }
            
            sessionId = sessionID
            tokenId = tokenID
            apiKey = APIKey
            
            self.session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
            
            self.connectSession()
            
            self.signalRSendSingleCallNotificationOnWebInvoke(callInfo: data)
            
            self.callCutTimerCounter = 60
            self.callCutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callCutTimerFunction), userInfo: nil, repeats: true)
            
        } else {
            dismissOnErrorAlert(self.viewModel.startCallSessionResponse?.message ?? "Something went wrong")
        }
    }
    
    // MARK: - SignalR send notification to web after session is created.
    func signalRSendSingleCallNotificationOnWebInvoke(callInfo: StartCellSessionDM) {
        
        guard
            let joinLink = callInfo.joinLink,
            let displayURL = callInfo.displayURL,
            let name = callInfo.name,
            let identifier = callInfo.identifier,
            let callerIdentifier = callInfo.callerIdentifier,
            let callType = callInfo.callType,
            let callToIdentifier = self.userInfo[.callToIdentifier] as? String
        else {
            self.showToast(message: "Single Calling: Couldn't send notification to web, due to some missing data", toastType: .red)
            return
        }
        
        let params = [
            "CallType": callType == 1 ? "Video" : "Audio",
            "JoinLink": joinLink,
            "DisplayURL": displayURL,
            "Name": name,
            "Identifier": identifier,
            "CallerIdentifier": callerIdentifier
        ]
        
        self.signalRConnection?.send(method: "SendNotification", callToIdentifier, params) { error in
            
            if let e = error {
                self.showToast(message: "SignalR Single Calling (for web) error: \(e)", toastType: .red)
                
            }
        }
    }
}


