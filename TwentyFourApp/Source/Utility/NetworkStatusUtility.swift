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
    
    init() {
    }
    
    func isConnected() -> Bool {
        return Alamofire.NetworkReachabilityManager()?.isReachable ?? false
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
        
        Alamofire.NetworkReachabilityManager()?.listener = { status in
            switch status {
            case .notReachable, .unknown:
                print("The network is not reachable")
            case .reachable(.ethernetOrWiFi), .reachable(.wwan):
                NotificationCenter.default.post(Notification.init(name: Notification.Name(rawValue: "NetworkReachAbilityChanged")))
                print("Connected to Network")
            }
            
        }
        
        // start listening
        Alamofire.NetworkReachabilityManager()?.startListening()
    }
}


