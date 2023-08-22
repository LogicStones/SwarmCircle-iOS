//
//  SignalRService.swift
//  Swarm Circle
//
//  Created by Macbook on 07/11/2022.
//

import Foundation
import SwiftSignalRClient

class SignalRService {
    
    static let signalRService = SignalRService()
    
    var connection: HubConnection?
    
    var chatHubConnectionDelegate: HubConnectionDelegate?
    
    private init() {}
    
    func initializeSignalR(completion: @escaping(HubConnection?) -> Void) {
        
       
        
//        self.connection = HubConnectionBuilder(url: URL(string: "http://\(AppConstants.serverURL):\(AppConstants.serverPort)/chatHub")!) // testing url
        self.connection = HubConnectionBuilder(url: URL(string: "\(AppConstants.baseURL)chatHub")!) // live url
            .withLogging(minLogLevel: .debug)
            .withAutoReconnect()
            .withHubConnectionDelegate(delegate: chatHubConnectionDelegate!)
            .build()
        connection?.start()
        
//        connection?.start()
        completion(self.connection)
    }
}

