//
//  GroupAVCallingVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 05/12/2022.
//

import UIKit
import OpenTok

class GroupAVCallingVC: BaseViewController {
    
    @IBOutlet weak var videoPlayerView: UIView!
    @IBOutlet weak var profilePicImgView: CircleImage!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var bigCircleImgView: UIImageView!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var videoBtn: UIButton!
    @IBOutlet weak var callDropBtn: UIButton!
    @IBOutlet weak var mircrophoneBtn: UIButton!
    @IBOutlet weak var flipCameraBtn: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    var callType: CallType? // used to start call session & set buttons, set audio device and video track
    var callMembers: String? // used to start call session
    
    var circleIdentifier: String? // used to broadcast call
    var callIdentifier: String? // used to broadcast call
    
    var broadCastId: String? // Retrieved for broastCast API. (Obtained when starting a call, for now we are not using it because there is not admin system in group call)
    
    var isCallInitiater = false
    
    var viewModel = ViewModel()
    
    var uuID: UUID? = nil // UUID used to end CallKit
    
//    let speakerAudio = DefaultAudioDevice() // Audio Driver used for Speaker
//
//    let handsetAudio = OTDefaultAudioDevice() // Audio driver used for handset
    
    lazy var handsetAudio: OTDefaultAudioDevice? = {
        return OTDefaultAudioDevice()
    }()
    
    lazy var speakerAudio: DefaultAudioDevice? = {
        return DefaultAudioDevice()
    }()
    
    var callCutTimerCounter = 60 // controller will be dismissed if no one picks up the call in 45 seconds
    var callCutTimer: Timer? = nil
    
    var player: AVAudioPlayer?
    
    var session: OTSession?
    var publishers: OTPublisher?
    
    var subscribers: [(subscriber: OTSubscriber, isMuted: Bool)] = []
    
    let signalRConnection = SignalRService.signalRService.connection
    
    deinit {
        self.viewModel.callMemberStop() // drop call session from server in case user closed the controller.
//        OTAudioDeviceManager.setAudioDevice(nil)
        self.destroySession()
        Utils.unconfigureAudioSession()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        print("Session ID: \(sessionId)")
        print("Session ID Token: \(tokenId)")
        self.initUI()
        self.initVariable()
    }
    
    // MARK: - Initialization UI
    func initUI() {
        
        self.collectionViewHeightConstraint.constant = self.collectionView.frame.width / 4 // remove this later, use animation
        
        self.profilePicImgView.kf.indicatorType = .activity
        
        if let imgURL = Utils.getCompleteURL(urlString: PreferencesManager.getUserModel()?.displayImageURL) {
            self.profilePicImgView.kf.setImage(with: imgURL, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.profilePicImgView.image = UIImage(named: "defaultProfileImage")!
        }
        
        self.userNameLbl.text = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
        
        // Check if call type is passed from previous controller
        if self.callType == nil {
            dismissOnErrorAlert("Call Type Missing")
        }
        
        if self.callType == .audioGroup {
            self.videoBtn.isHidden = true
            self.flipCameraBtn.isHidden = true
        } else {
            self.speakerBtn.isHidden = true
        }
        
        self.collectionView.register(UINib(nibName: "GroupAVCallingCell", bundle: nil), forCellWithReuseIdentifier: "GroupAVCallingCell")
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
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
            
        } else if self.callType == .videoGroup && AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == .denied {
            Alert.sharedInstance.alertOkWindow(title: "Alert", message: "Please allow camera access from device settings to continue") { result in
                if result {
                    self.dismiss(animated: true)
                }
            }
            return
        }
        
        self.viewModel.delegateNetworkResponse = self
        
        if !self.isCallInitiater {
            self.notifyReceiveCall()
            self.session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
            NotificationCenter.default.addObserver(self, selector: #selector(self.callKitAction(_:)), name: .actionForCall, object: nil)
        }
        
        
        self.setupAudioType()
        self.startGroupCallSession()
    }
    
    func notifyReceiveCall() {
        self.viewModel.receiveCall()
    }
    
////    // MARK: - Setup speaker based on call type.
//    func setupAudioType() {
//
//        if callType == .audioGroup {
//            OTAudioDeviceManager.setAudioDevice(handsetAudio)
//        } else {
//            OTAudioDeviceManager.setAudioDevice(speakerAudio)
//        }
//    }
    
    // MARK: - Setup speaker based on call type.
    func setupAudioType() {
        //        if callType == .audioGroup {
        ////                      OTAudioDeviceManager.setAudioDevice(handsetAudio)
        //            Utils.configureAudioSessionType(sessionMode: .voiceChat)
        //        } else {
        ////                      OTAudioDeviceManager.setAudioDevice(speakerAudio)
        //            Utils.configureAudioSessionType(sessionMode: .videoChat)
        //        }
        self.speakerBtn.isSelected = true
        Utils.configureAudioSessionType(sessionMode: .videoChat)
    }
    
    @objc func callCutTimerFunction() {
        
        self.callCutTimerCounter -= 1
        
        print("Group Call Initiater: \(self.callCutTimerCounter) seconds left before GroupAVCallingVC is closed.")
        
        if self.callCutTimerCounter == 0 {
            
            self.callCutTimer?.invalidate()
            self.callCutTimer = nil
            
            self.viewModel.callMemberStop()
            
            self.dismiss(animated: true) {
                Alert.sharedInstance.alertOkWindow(title: "Call Failed", message: "No one joined your session") { _ in }
            }
        }
    }
    
    // MARK: - Start Group Call Session
    func startGroupCallSession() {
        
        if !self.isCallInitiater {
            self.connectSession() // Subscriber connect session
            return
        }
        
        guard let circleIdentifier else {
            dismissOnErrorAlert("Circle Identifier Missing")
            return
        }
        
        guard let callMembers else {
            dismissOnErrorAlert("Call Members Missing")
            return
        }
        
        self.showLoader()
        self.viewModel.startGroupCallSession(callToCircle: circleIdentifier, callType: self.callType == .videoGroup ? 1 : 2, callMembers: callMembers)
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

        self.showToastThenLoader(msg: "Connecting session...") // show loader after 1 second (this allows user to read the toast message)
        self.session?.connect(withToken: tokenId, error: &error)
//        self.broadCastCall() // Broadcast call on members side (generate push notification on member's screen)
        print("Session Id: \(sessionId)")
        print("Token Id: \(tokenId)")
        print("API key Id: \(apiKey)")
        
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
        settings.videoTrack = self.callType == .videoGroup ? true : false
        
        self.publishers = OTPublisher.init(delegate: self, settings: settings)
        
        self.session?.publish(publishers!, error: &error)
        
        self.collectionView.reloadData()
        
//        self.showSelfVideo()
    }
    
    fileprivate func showSelfVideo() {
        // Start Showing self video
        if var pubView = self.publishers?.view {
            
            pubView.frame = CGRect(x: 0, y: 0, width: self.videoPlayerView.frame.width, height: self.videoPlayerView.frame.height)
            
            pubView.tag = 101
            self.videoPlayerView.addSubview(pubView)
            self.videoPlayerView.sendSubviewToBack(pubView)
            self.videoPlayerView.sendSubviewToBack(self.bigCircleImgView)
            self.videoPlayerView.sendSubviewToBack(self.userNameLbl)
        
            self.videoPlayerView.sendSubviewToBack(self.profilePicImgView)
            self.view.bringSubviewToFront(self.collectionView)
            
            pubView.widthAnchor.constraint(equalTo: self.videoPlayerView.widthAnchor).isActive = true
            pubView.heightAnchor.constraint(equalTo: self.videoPlayerView.heightAnchor).isActive = true
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
        self.session?.subscribe(subscriber, error: &error)
        
        var indexToRemove: Int?

        if let stringArrayNew = stream.name?.split(separator: ",") {
            
            if stringArrayNew.count == 3 {
                
                for i in stride(from: 0, to: self.subscribers.count, by: 1) {
                    
                    if let stringArrayOld = self.subscribers[i].subscriber.stream?.name?.split(separator: ",") {
                        
                        if stringArrayOld.count == 3 {
                            
                            if "\(stringArrayNew[2])" == "\(stringArrayOld[2])" {
                                
                                indexToRemove = i
                                
                                break
                            }
                        }
                    }
                }
            }
        }

        if let indexToRemove {
            self.subscribers.remove(at: indexToRemove)
        }
        
        self.subscribers.append((subscriber: subscriber, isMuted: false))
        
        self.collectionView.reloadData()
    }
    
    fileprivate func cleanupSubscriber(_ stream: OTStream) {
        self.subscribers = self.subscribers.filter { $0.subscriber.stream?.streamId != stream.streamId }
        self.collectionView.reloadData()
        
        if self.subscribers.count == 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.stopCallNDismiss()
            }
        }
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
    
    // MARK: - Video Button Tapped
    @IBAction func videoBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        self.publishers?.publishVideo = !(self.publishers?.publishVideo ?? false)
        
        if let pubView = self.publishers?.view {
            pubView.isHidden = !pubView.isHidden
        }
    }
    
    // MARK: - Call End Button Tapped
    @IBAction func callEndBtnTapped(_ sender: UIButton) {
        
        if self.isCallInitiater {
            self.callCutTimer?.invalidate()
            self.callCutTimer = nil
        }
        
        if self.isCallInitiater && self.subscribers.count == 0 { // Only invoke when there are no subscriber and you are call initiater.
            self.signalRGroupCallDropByCallerInvoke()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.stopCallNDismiss()
        }
    }
    
    // MARK: - SignalR Group Call Drop By Caller
    private func signalRGroupCallDropByCallerInvoke() {
        
        let callMembersIdentifierArray = Utils.convertCommaSeperatedStringToStringArray(self.callMembers!)
        
        for identifier in callMembersIdentifierArray {
            
            self.signalRConnection?.invoke(method: "CallDeclinedByCaller", identifier) { error in
                
                if let error {
                    print("Group call drop by caller error for user: \(identifier), error: \(error.localizedDescription)")
                } else {
                    print("Group call drop by caller succesfully invoked for user: \(identifier)")
                }
            }
        }
    }
    
    // MARK: - Microphone Button Tapped
    @IBAction func microphoneBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        self.publishers?.publishAudio = !(self.publishers?.publishAudio ?? false)
        self.openTokSendSignalToAllClients(typeOfSignal: "\(!(self.publishers?.publishAudio ?? false))", PreferencesManager.getUserModel()?.identifier ?? "") // send signal to all connected user that this user has changed the microphone status
    }
    
    // MARK: - Camera Flip Button Tapped
    @IBAction func cameraFlipBtnTapped(_ sender: UIButton) {
        
        switch self.publishers?.cameraPosition {
        case .back:
            self.publishers?.cameraPosition = .front
        case .front:
            self.publishers?.cameraPosition = .back
        case .unspecified:
            self.publishers?.publishVideo = false
        case .none:
            self.publishers?.publishVideo = false
        @unknown default:
            self.publishers?.publishVideo = false
        }
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

// MARK: - Collection View Action and Data Configuration
extension GroupAVCallingVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.subscribers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupAVCallingCell", for: indexPath) as? GroupAVCallingCell else {
            return UICollectionViewCell()
        }
        
        cell.configureCell(subscriber: self.subscribers[indexPath.row])
        return cell
    }
}

// MARK: - Collection View UI Configuration
extension GroupAVCallingVC: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width - 5) / 4, height: collectionView.frame.height - 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Session Delegates
extension GroupAVCallingVC: OTSessionDelegate {
    
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        PreferencesManager.saveCallState(isCallActivated: true)
        self.hideLoader()
        self.showToast(message: "Session connected", toastType: .green)

        DispatchQueue.main.async {
            self.broadCastCall() // Broadcast call on members side (generate push notification on member's screen)
            self.startPublishing() // Start Publishing A/V Stream after session is connected.
            
            
            
        }
    }
    
    // MARK: - BroadCast Call Mobile (Generate Push Notification on Subscribers(friends) Side)
    func broadCastCall() {
        
        if !self.isCallInitiater {
            return
        }
        
        guard let callIdentifier else {
            dismissOnErrorAlert("Call Identifier Missing")
            return
        }
        guard let circleIdentifier else {
            dismissOnErrorAlert("Circle Identifier Missing")
            return
        }
        self.showToast(message: "Broadcasting call...", toastType: .green)
        
        self.viewModel.broadCastCall(callIdentifier: callIdentifier, circleIdentifier: circleIdentifier)
    }
    
    func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        
        guard let userIdentifier = string else {
            return
        }
        
        var status: Bool? = nil
        if type?.lowercased() == "true" || type?.lowercased() == "false" {
            status = type?.lowercased() == "true" ? true : false
        }
        
        self.reflectMuteStatusOnScreen(userIdentifier: userIdentifier, muteStatus: status)
    }
    
    // MARK: - Reflect mute status on screen if a client has change their mute status
    fileprivate func reflectMuteStatusOnScreen(userIdentifier: String, muteStatus: Bool?) {
        
        for i in stride(from: 0, to: self.subscribers.count, by: 1) {
            
            if let identifier = self.subscribers[i].subscriber.stream?.name?.split(separator: ",") {
                
                
                
                if identifier.count == 3 {
                    
                    print("xxx: \(userIdentifier) yyy: \(identifier[2])")
                    
                    if "\(identifier[2])" == userIdentifier {
                        
                        print("matched xxx yyy")
                        
                        self.subscribers[i].isMuted = muteStatus ?? !self.subscribers[i].isMuted
                        self.collectionView.reloadData()
                        break
                    }
                }
            }
        }
    }
    
    func sessionDidDisconnect(_ session: OTSession) {
        self.publishers?.view?.removeFromSuperview()
        print("Session disconnected")
    }
    
    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
        self.subscribe(stream)
    }
    
    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        self.cleanupSubscriber(stream)
        
    }
    
    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
}

// MARK: - Publisher Delegates
extension GroupAVCallingVC: OTPublisherKitDelegate {
    
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
//        let settings = Pu
//        let settings = OTPublisherSettings()
//        settings.audioTrack = true
//        self.publishers = OTPublisher(delegate: self, settings: settings)!
        self.showSelfVideo()
    }
    
    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        
    }
    
    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - Subscriber Delegates
extension GroupAVCallingVC: OTSubscriberKitDelegate {
    
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
//        self.publishers.publishVideo = true
        self.callCutTimer?.invalidate()
        self.callCutTimer = nil
        
        
        
        self.mircrophoneBtn.isEnabled = true
        
//        self.showSubsriberList()
        self.collectionView.reloadData()
    }
    
    fileprivate func showSubsriberList() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 1.0) {
                self.collectionViewHeightConstraint.constant = (self.collectionView.frame.width / 4)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }
    
    func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        print("Subscriber disconnected")
        
        if self.subscribers.count == 0 && self.callCutTimer == nil { // && self.isCallInitiater (not neccesary because of note)
            /* Dismiss controller if (a subscriber disconnect and there is no subscriber left) and call cut timer is nil.
             Note: Timer will be nil for all the clients.
             Timer Check Reason:
             Suppose you are User "A" and you invite user "B", "C" and "D"
             "B" joins but leaves after 5 seconds
             if this condition is not placed then the controller will be dismissed but notification will still be shown to user "C" and "D"
             */
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.stopCallNDismiss()
            }
        }
        self.collectionView.reloadData()
    }
    
    func subscriberVideoEnabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        self.collectionView.reloadData()
    }
    
    func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        self.collectionView.reloadData()
    }
}

extension GroupAVCallingVC: NetworkResponseProtocols {
    
    // MARK: - Start Group Call Session Response
    func didGetGroupCallSession() {
        
        self.hideLoader()
        
        if let data = self.viewModel.groupCallSessionResponse?.data {
            
            guard let sessionID = data.sessionID else {
                dismissOnErrorAlert("Session ID missing")
                return
            }
            guard let tokenID = data.tokenID else {
                dismissOnErrorAlert("Token ID missing")
                return
            }
            guard let APIKey = data.apiKey else {
                dismissOnErrorAlert("API key missing")
                return
            }
            guard let callIdentifier = data.identifier else {
                dismissOnErrorAlert("Call identifier missing")
                return
            }
            
            sessionId = sessionID
            tokenId = tokenID
            apiKey = APIKey
            self.callIdentifier = callIdentifier
            
            self.session = OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)
            
            self.connectSession()
        }
        else {
            self.showToast(message: self.viewModel.groupCallSessionResponse?.message ?? "Something went wrong", toastType: .red)
        }
    }
    
    // MARK: - BroadCast Call Response
    func didBroastCastCall() {
        
        if let broadCastData = self.viewModel.broadCastCallResponse?.data {
            
//            self.broadCastId = broadCastData.broadcastID

            self.showToast(message: "Successfully broadcasted call", toastType: .green)
            
            // After broadcasting call, controller will be dismissed in 60 seconds if no one picks up the call.
            self.callCutTimerCounter = 60
            self.callCutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callCutTimerFunction), userInfo: nil, repeats: true)
            
            guard
                let joinLink = broadCastData.joinLink,
                let displayURL = broadCastData.displayURL,
                let name = broadCastData.name
            else {
                self.showToast(message: self.viewModel.broadCastCallResponse?.message ?? "Something went wrong", toastType: .red)
                return
            }
            self.signalRBroadCastCall(joinLink: joinLink, displayURL: displayURL, name: name)

        } else {
            Alert.sharedInstance.alertOkWindow(title: "Error", message: self.viewModel.broadCastCallResponse?.message ?? "Something went wrong") { result in
                if result {
                    self.dismiss(animated: true)
                }
            }
        }
    }
    
    // MARK: - BroadCast Call Web (Generate Notification on Subscribers(friends) Side)
    func signalRBroadCastCall(joinLink: String, displayURL: String, name: String) {
 
        let identifierArray = Utils.convertCommaSeperatedStringToStringArray(self.callMembers!)

        for identifier in identifierArray {
            
            let params = [
                "JoinLink": joinLink,
                "DisplayURL": displayURL,
                "Name": name,
                "Identifier": circleIdentifier!
            ]
            
            self.signalRConnection?.send(method: "SendGroupCallNotification", identifier, params) { error in

                if let e = error {
                    self.showToast(message: "Error: \(e)", toastType: .red)
                }
            }
            
        }
    }
    
    // MARK: - Stop Call
    private func stopCallNDismiss() {
        
        if !self.isCallInitiater {
            
            // Remove call from callkit (Note: CallKit will only be shown to receivers)
            let callManager = SpeakerboxCallManager()
            callManager.endCall(call: callManager.callController.callObserver.calls.first?.uuid ?? self.uuID ?? UUID())
        }
        
        self.dismiss(animated: true)
    }
}

extension GroupAVCallingVC {
    
    // MARK: - Send StreamID to all clients
    func openTokSendSignalToAllClients(typeOfSignal: String? = nil, _ string: String) {
        
        var error: OTError?

        session?.signal(withType: typeOfSignal, string: string, connection: nil, error: &error)

        if let error {
            print("Signal Error \(error)")
        } else {
            print("Signal Sent")
        }
    }
}

extension GroupAVCallingVC {
    
    // MARK: - CallKit Action for group audio/video (fired when the user rejects call from CallKit screen)
    @objc func callKitAction(_ notification: NSNotification) {
        
        print("GroupAVCalling Observer Called")
        defer {
            NotificationCenter.default.removeObserver(Notification.Name.actionForCall)
            print("GroupAVCalling Observer Removed")
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
    
    // MARK: - Stop Call
    private func destroySession() {
        
        var error: OTError?
        
        if self.publishers != nil {
            session?.unpublish(self.publishers!, error: &error)
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
