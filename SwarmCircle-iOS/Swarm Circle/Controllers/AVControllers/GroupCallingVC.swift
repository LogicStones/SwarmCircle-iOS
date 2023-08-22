//
//  GroupCallingVC.swift
//  Swarm Circle
//
//  Created by Rehan Khan's iMac on 23/11/2022.
//

import UIKit
import OpenTok

//private let reuseIdentifier = "videoCell"

//class GroupCallingVC: UICollectionViewController {
class GroupCallingVC: BaseViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var arrowBtn: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    // *** Fill the following variables using your own Project info  ***
    // ***            https://tokbox.com/account/#/                  ***
    // Replace with your OpenTok API key
//    let kApiKey = ""
//    // Replace with your generated session ID
//    let kSessionId = ""
//    // Replace with your generated token
//    let kToken = ""
    
    // *** Fill the following variables using your own Project info  ***
    // ***            https://tokbox.com/account/#/                  ***
    // Replace with your OpenTok API key
//    var kApiKey = "47605761"
    // Replace with your generated session ID
//    var kSessionId = "1_MX40NzYwNTc2MX5-MTY2ODUwNjcyOTk2N35pa3JzM2xyN0F6NlRteWdCazNKVVFPdVp-fg"
    // Replace with your generated token
//    var kToken = "T1==cGFydG5lcl9pZD00NzYwNTc2MSZzaWc9NzFiZDJjYjVmNjA0M2IxZWRmOTI3NWM1NDg3MDJlYTI4M2Y4OWU5ZjpzZXNzaW9uX2lkPTFfTVg0ME56WXdOVGMyTVg1LU1UWTJPRFV3TmpjeU9UazJOMzVwYTNKek0yeHlOMEY2TmxSdGVXZENhek5LVlZGUGRWcC1mZyZjcmVhdGVfdGltZT0xNjY4NTA2NjkyJm5vbmNlPTkxNzk5OCZyb2xlPVBVQkxJU0hFUg=="
    
    var circleIdentifier: String?
    var callIdentifier: String?
    
    let viewModel = ViewModel()
    
    lazy var session: OTSession = {
        return OTSession(apiKey: apiKey, sessionId: sessionId, delegate: self)!
    }()

    lazy var publisher: OTPublisher = {
        let settings = OTPublisherSettings()
        settings.name = "\(PreferencesManager.getUserModel()?.firstName?.capitalized ?? "") \(PreferencesManager.getUserModel()?.lastName?.capitalized ?? "")"
        settings.audioTrack = false
        settings.videoTrack = true // change
        return OTPublisher(delegate: self, settings: settings)!
    }()

    var subscribers: [OTSubscriber] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.initVariable()
        self.initUI()
        
    }
    
    func initUI() {
        self.tableView.register(UINib(nibName: "GroupCallingCell", bundle: nil), forCellReuseIdentifier: "GroupCallingCell")
    }
    
    func initVariable() {
//        guard let _ = circleIdentifier, let _ = callIdentifier else {
//            self.showToast(message: "Circle Identifier or Call Identifier Missing", toastType: .red)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.navigationController?.popViewController(animated: true)
//            }
//             return
//        }
        self.viewModel.delegateNetworkResponse = self
        doConnect()
    }
    
    @IBAction func arrowBtnTapped(_ sender: UIButton) {
        
        sender.isSelected = !sender.isSelected
        
        UIViewPropertyAnimator(duration: 1, curve: .linear) {
            
            if sender.isSelected {
                self.tableViewHeightConstraint.constant = UIScreen.main.bounds.height * 0.25
            }
            else {
                self.tableViewHeightConstraint.constant = 0
            }
        }.startAnimation()
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
    
    func broadCastCall() {
        guard let _ = circleIdentifier, let _ = callIdentifier else {
            return
        }
        self.viewModel.broadCastCall(callIdentifier: self.callIdentifier!, circleIdentifier: self.circleIdentifier!)
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

        collectionView?.reloadData()
        
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
        guard let subscriber = OTSubscriber(stream: stream, delegate: self)
            else {
                print("Error while subscribing")
                return
        }
        session.subscribe(subscriber, error: &error)
        subscribers.append(subscriber)
        collectionView?.reloadData()
    }

    fileprivate func cleanupSubscriber(_ stream: OTStream) {
        subscribers = subscribers.filter { $0.stream?.streamId != stream.streamId }
        collectionView?.reloadData()
    }

    fileprivate func processError(_ error: OTError?) {
        if let err = error {
            showAlert(errorStr: err.localizedDescription)
        }
    }

    fileprivate func showAlert(errorStr err: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: "Error", message: err, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(controller, animated: true, completion: nil)
        }
    }

    // MARK: - UICollectionView methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return subscribers.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath)
        let videoView: UIView? = {
            if (indexPath.row == 0) {
                return publisher.view
            } else {
                let sub = subscribers[indexPath.row - 1]
                return sub.view
            }
        }()

        if let viewToAdd = videoView {
            viewToAdd.frame = cell.bounds
            cell.addSubview(viewToAdd)
        }
        return cell
    }
}

// MARK: - OTSession delegate callbacks
extension GroupCallingVC: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        print("Session connected")
        doPublish()
    }

    func sessionDidDisconnect(_ session: OTSession) {
        print("Session disconnected")
    }

    func session(_ session: OTSession, streamCreated stream: OTStream) {
        print("Session streamCreated: \(stream.streamId)")
//        stream.session.st
        doSubscribe(stream)
    }

    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        print("Session streamDestroyed: \(stream.streamId)")
        cleanupSubscriber(stream)
    }

    func session(_ session: OTSession, didFailWithError error: OTError) {
        print("session Failed to connect: \(error.localizedDescription)")
    }
}

// MARK: - OTPublisher delegate callbacks
extension GroupCallingVC: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        self.broadCastCall()
    }

    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
    }

    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        print("Publisher failed: \(error.localizedDescription)")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension GroupCallingVC: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        print("Subscriber connected")
//        collectionView?.reloadData()
        self.tableView.reloadData()
    }

    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        print("Subscriber failed: \(error.localizedDescription)")
    }

    func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        self.tableView.reloadData()
    }
    
    func subscriberVideoDataReceived(_ subscriber: OTSubscriber) {
        
    }
}

extension GroupCallingVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.subscribers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCallingCell") as? GroupCallingCell else {
            return UITableViewCell()
        }

        cell.configureCell(name: self.subscribers[indexPath.row].stream?.name ?? "")
        cell.microphoneBtn.tag = indexPath.row
        cell.microphoneBtn.addTarget(self, action: #selector(self.microphoneBtnTapped(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc func microphoneBtnTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.subscribers[sender.tag].subscribeToAudio = !self.subscribers[sender.tag].subscribeToAudio
        
//        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
//            print("appdelegate is missing")
//            return
//        }
//        sender.isSelected = !sender.isSelected
//        appdelegate.callManager.setMute(call: appdelegate.callManager.calls[sender.tag], isMuted: sender.isSelected)
    }
}

extension GroupCallingVC: NetworkResponseProtocols {
    func didBroastCastCall() {
//        if let data = self.viewModel.broadCastCallResponse?.data {
//
//
//
//        }
//        else {
//            self.showToast(message: self.viewModel.broadCastCallResponse?.message ?? "Something went wrong", toastType: .red)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                self.navigationController?.popViewController(animated: true)
//            }
//            return
//        }
    }
}

