//
//  NetworkStatusUtility.swift
//  TwentyFourApp
//
//  Created by Muhammad Zubair on 4/18/19.
//  Copyright © 2019 Muhammad Zubair. All rights reserved.
//
import UIKit
import Alamofire

class NetworkStatusUtility {
    let reachabilityManager:NetworkReachabilityManager?
    
    //shared instance
    static let shared = NetworkStatusUtility()
    
    private init() {
        reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    }
    
    func isConnected() -> Bool {
        return reachabilityManager?.isReachable ?? true
    }
    
    func shouldProceed(from:BaseViewController) -> BooleanLiteralType{
        if isConnected() {
            return true
        }else {
            from.makeBasicToastWith(text: "NETWORK_CONNECTION_ERROR".localize(), position: .center)
            return false
        }
    }
    
    func startNetworkReachabilityObserver() {
        
        reachabilityManager?.listener = { status in
            switch status {
            case .notReachable, .unknown:
                print("The network is not reachable")
            case .reachable(.ethernetOrWiFi), .reachable(.wwan):
                print("Connected to Network")
            }
            NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "NetworkReachAbilityChanged")))
        }
        
        // start listening
        if let manager = reachabilityManager {
            print("Starting Reachability Listener")
            manager.startListening()
        }
    }
}


