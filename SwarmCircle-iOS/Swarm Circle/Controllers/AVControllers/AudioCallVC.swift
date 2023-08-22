//
//  AudioCallVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 25/11/2022.
//

import UIKit
import AVFAudio
import OpenTok

class AudioCallVC: BaseViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var callNameLbl: UILabel!
    @IBOutlet weak var speakerBtn: UIButton!
    @IBOutlet weak var microphoneBtn: UIButton!
    @IBOutlet weak var callEndBtn: UIButton!
    
    var callName: String?
    var callImage: String?
    var identifier = ""
    
//    var callCutTimerCounter = 40
//    var callCutTimer: Timer?
    
    let viewModel = ViewModel()
    let signalRConnection = SignalRService.signalRService.connection
    let customAudio = OTDefaultAudioDevice()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.initUI()
        self.initVariable()
    }
    
    // in case user closed the controller
    deinit {
//        self.callCutTimer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleCallsChangedNotification(notification:)), name: SpeakerboxCallManager.CallsChangedNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func initUI() {
        if let imageUrl = Utils.getCompleteURL(urlString: callImage) {
            self.imgView.kf.setImage(with: imageUrl, placeholder: UIImage(named: "defaultProfileImage"))
        } else {
            self.imgView.image = UIImage(named: "defaultProfileImage")!
        }
        self.callNameLbl.text = self.callName ?? "User(s)"
        
//        self.speakerBtn.tintColor = u

    }
    
    func initVariable() {
//        self.viewModel.delegateNetworkResponse = self
        OTAudioDeviceManager.setAudioDevice(customAudio)
        
        self.signalRCallDropByReceiver() // On method called when Recevier cancel or didn't attend the call
        
        PreferencesManager.saveCallState(isCallActivated: true)
        
        Utils.configureAudioSessionType(sessionMode: .videoChat)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            Utils.configureAudioSessionType(sessionMode: .voiceChat)
        }
        
//        showLoader()
//        self.callCutTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.callCutTimerFunction), userInfo: nil, repeats: true)
    }
    
//    @objc func callCutTimerFunction() {
//
//        self.callCutTimerCounter -= 1
//
//        if self.callCutTimerCounter == 0 {
//            // Signal R invoke on Call End Button Tapped
//            self.signalRCallDropByCallerInvoke()
//
//            //End call from Call Kit
//            self.dismiss(animated: true) {
//                self.endCall()
//            }
//        }
//    }
    
//    let audioQueue = DispatchQueue(label: "audio")
    
    @IBAction func speakerBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        
        self.setSpeaker(sender.isSelected)
    }
    
    func setSpeaker(_ isEnabled: Bool) {
        
        if isEnabled{
            Utils.configureAudioSessionType(sessionMode: .videoChat)
        } else {
            Utils.configureAudioSessionType(sessionMode: .voiceChat)
        }
//        OTDefaultAudioDevice.isSpeaker = isEnabled
        
//        audioQueue.async {
            
//            do {
//
//                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat, options: AVAudioSession.CategoryOptions.mixWithOthers)
//
//                try AVAudioSession.sharedInstance().overrideOutputAudioPort(isEnabled ? .speaker : .none)
//
//                try AVAudioSession.sharedInstance().setActive(isEnabled)
//            } catch {
//                debugPrint(error.localizedDescription)
//            }
//        }
    }
    
    @IBAction func mircrophoneBtnTapped(_ sender: UIButton) {
        //        sender.isSelected = !sender.isSelected
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("appdelegate is missing")
            return
        }
        if appdelegate.callManager.calls.count > 0 {
            //        appdelegate.callManager.setHeld(call: appdelegate.callManager.calls[0], onHold: false)
            sender.isSelected = !sender.isSelected
            print("Call is Muted: \(sender.isSelected)")
            appdelegate.callManager.setMute(call: appdelegate.callManager.calls[0], isMuted: sender.isSelected)
        }
        
        
    }
    
    
    @IBAction func callEndBtnTapped(_ sender: UIButton) {
        
        sender.isEnabled = false
        
        // Signal R invoke on Call End Button Tapped
        self.signalRCallDropByCallerInvoke()
        
        //End call from Call Kit & API
        self.endCall()
    }
    
    func apiEndCall() {
//        self.showLoader()
        self.viewModel.callMemberStop()
    }
    
    fileprivate func endCall() {

            
            self.dismiss(animated: true) {
                
                self.apiEndCall()
                
                guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
                    
                    print("appdelegate is missing")
                    return
                }
                /*
                 End any ongoing calls if the provider resets, and remove them from the app's list of calls,
                 since they are no longer valid.
                 */
                for call in appdelegate.callManager.calls {
                    appdelegate.callManager.end(call: call)
                }
            }
        
    }
    
    @objc func handleCallsChangedNotification(notification: NSNotification) {
        
//        hideLoader()
        
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            
            print("appdelegate is missing")
            return
        }

        
        if (appdelegate.callManager.calls.count > 0)
        {
            let call = appdelegate.callManager.calls[0]
            
            if call.hasEnded {
                self.dismiss(animated: true) {
                    self.apiEndCall()
                }
            }
            
//            call.hasc
            
//            if call.isOnHold {
////                callButton.setTitle(unholdCallText, for: .normal)
//            } else if call.session != nil {
////                callButton.setTitle(endCallText, for: .normal)
////                callButton.setTitleColor(.red, for: .normal)
//            }
//
//            if let hasVideo = notification.userInfo?["hasVideo"] as? Bool{
//                if hasVideo{
//                    if let vc = AppStoryboard.AVCalling.instance.instantiateViewController(withIdentifier: "GroupCallingVC") as? GroupCallingVC {
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                } else {
//
//                }
//            }
//
//            if let action = notification.userInfo?["action"] as? String, action == SpeakerboxCallManager.Call.end.rawValue {
////                callButton.setTitle(makeACallText, for: .normal)
////                callButton.setTitleColor(.white, for: .normal)
////                callButton.isEnabled = true
////                simulateCallButton.setTitle(simulateIncomingCallText, for: .normal)
////                simulateCallButton.setTitleColor(.white, for: .normal)
////                simulateCallButton.isEnabled = true
////                simulateCallButton2.setTitle(simulateIncomingCallThreeSecondsText, for: .normal)
////                simulateCallButton2.setTitleColor(.white, for: .normal)
////                simulateCallButton2.isEnabled = true
//            }
        }
    }
}

extension AudioCallVC: NetworkResponseProtocols {
    
    func didCallMemberStop() {
        
        self.hideLoader()
        
        if self.viewModel.callMemberStopResponse?.isSuccess ?? false {
            
//            self.dismiss(animated: true) {
//                self.endCall()
//            }
//            self.dismiss(animated: true)
        }
        else {
            self.showToast(message: self.viewModel.callMemberStopResponse?.message ?? "Something went wrong", toastType: .red)
        }
    }
}

// MARK: - Signal R Methods
extension AudioCallVC{
    
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
    
    private func signalRCallDropByReceiver(){
        self.signalRConnection?.on(method: "CallDeclinedCallerClient") { (user: String) in
            self.showToast(message: "\(user.capitalized) is busy.", toastType: .red)
            self.endCall()
            
        }
    }
    
    
    func configureAudioSessionForSpeaker() {
        
        let session = AVAudioSession.sharedInstance()
         
        // Configure category and mode
        do {
//            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.videoChat)
            try session.setMode(AVAudioSession.Mode.videoChat)
        } catch let error as NSError {
            print("Unable to set category:  \(error.localizedDescription)")
        }
         
        // Set preferred sample rate
        do {
            try session.setPreferredSampleRate(44_100)
        } catch let error as NSError {
            print("Unable to set preferred sample rate:  \(error.localizedDescription)")
        }
         
        // Set preferred I/O buffer duration
        do {
            try session.setPreferredIOBufferDuration(0.005)
        } catch let error as NSError {
            print("Unable to set preferred I/O buffer duration:  \(error.localizedDescription)")
        }
         
        // Activate the audio session
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Unable to activate session. \(error.localizedDescription)")
        }
         
        // Query the audio session's ioBufferDuration and sampleRate properties
        // to determine if the preferred values were set
        print("Audio Session ioBufferDuration: \(session.ioBufferDuration), sampleRate: \(session.sampleRate)")
        
        // Preferred Mic = Front, Preferred Polar Pattern = Cardioid
        let preferredMicOrientation = AVAudioSession.Orientation.front
        let preferredPolarPattern = AVAudioSession.PolarPattern.cardioid
         
        // Retrieve your configured and activated audio session
//        let session = AVAudioSession.sharedInstance()
         
        // Get available inputs
        guard let inputs = session.availableInputs else { return }
         
        // Find built-in mic
        guard let builtInMic = inputs.first(where: {
            $0.portType == AVAudioSession.Port.builtInMic
        }) else { return }
         
        // Find the data source at the specified orientation
        guard let dataSource = builtInMic.dataSources?.first (where: {
            $0.orientation == preferredMicOrientation
        }) else { return }
         
        // Set data source's polar pattern
        do {
            try dataSource.setPreferredPolarPattern(preferredPolarPattern)
        } catch let error as NSError {
            print("Unable to preferred polar pattern: \(error.localizedDescription)")
        }
         
        // Set the data source as the input's preferred data source
        do {
            try builtInMic.setPreferredDataSource(dataSource)
        } catch let error as NSError {
            print("Unable to preferred dataSource: \(error.localizedDescription)")
        }
         
        // Set the built-in mic as the preferred input
        // This call will be a no-op if already selected
        do {
            try session.setPreferredInput(builtInMic)
        } catch let error as NSError {
            print("Unable to preferred input: \(error.localizedDescription)")
        }
         
        // Print Active Configuration
        session.currentRoute.inputs.forEach { portDesc in
            print("Port: \(portDesc.portType)")
            if let ds = portDesc.selectedDataSource {
                print("Name: \(ds.dataSourceName)")
                print("Polar Pattern: \(ds.selectedPolarPattern)")
            }
        }
    }
    
    func configureAudioSessionForHandSet(){
        
        let session = AVAudioSession.sharedInstance()
         
        // Configure category and mode
        do {
//            try session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.voiceChat)
            try session.setMode(AVAudioSession.Mode.voiceChat)
        } catch let error as NSError {
            print("Unable to set category:  \(error.localizedDescription)")
        }
         
        // Set preferred sample rate
        do {
            try session.setPreferredSampleRate(44_100)
        } catch let error as NSError {
            print("Unable to set preferred sample rate:  \(error.localizedDescription)")
        }
         
        // Set preferred I/O buffer duration
        do {
            try session.setPreferredIOBufferDuration(0.005)
        } catch let error as NSError {
            print("Unable to set preferred I/O buffer duration:  \(error.localizedDescription)")
        }
         
        // Activate the audio session
        do {
            try session.setActive(true)
        } catch let error as NSError {
            print("Unable to activate session. \(error.localizedDescription)")
        }
         
        // Query the audio session's ioBufferDuration and sampleRate properties
        // to determine if the preferred values were set
        print("Audio Session ioBufferDuration: \(session.ioBufferDuration), sampleRate: \(session.sampleRate)")
        
        // Preferred Mic = Front, Preferred Polar Pattern = Cardioid
        let preferredMicOrientation = AVAudioSession.Orientation.front
        let preferredPolarPattern = AVAudioSession.PolarPattern.cardioid
         
        // Retrieve your configured and activated audio session
//        let session = AVAudioSession.sharedInstance()
         
        // Get available inputs
        guard let inputs = session.availableInputs else { return }
         
        // Find built-in mic
        guard let builtInMic = inputs.first(where: {
            $0.portType == AVAudioSession.Port.builtInMic
        }) else { return }
         
        // Find the data source at the specified orientation
        guard let dataSource = builtInMic.dataSources?.first (where: {
            $0.orientation == preferredMicOrientation
        }) else { return }
         
        // Set data source's polar pattern
        do {
            try dataSource.setPreferredPolarPattern(preferredPolarPattern)
        } catch let error as NSError {
            print("Unable to preferred polar pattern: \(error.localizedDescription)")
        }
         
        // Set the data source as the input's preferred data source
        do {
            try builtInMic.setPreferredDataSource(dataSource)
        } catch let error as NSError {
            print("Unable to preferred dataSource: \(error.localizedDescription)")
        }
         
        // Set the built-in mic as the preferred input
        // This call will be a no-op if already selected
        do {
            try session.setPreferredInput(builtInMic)
        } catch let error as NSError {
            print("Unable to preferred input: \(error.localizedDescription)")
        }
         
        // Print Active Configuration
        session.currentRoute.inputs.forEach { portDesc in
            print("Port: \(portDesc.portType)")
            if let ds = portDesc.selectedDataSource {
                print("Name: \(ds.dataSourceName)")
                print("Polar Pattern: \(ds.selectedPolarPattern)")
            }
        }
    }
}

