//
//  Reachability.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 11/02/2023.
//

import Foundation
import SystemConfiguration
import Network

final class Reachability {
    static let shared = Reachability()
   
    private var isConnected: Bool = false
    
    private let reachability = SCNetworkReachabilityCreateWithName(nil, UtilityConstants.defaultBaseURL)

    private func isNetworkReachable(with flags: SCNetworkReachabilityFlags) -> Bool {
        let isReachable = flags.contains(.reachable)
        let connectionRequired = flags.contains(.connectionRequired)
        let canConnectAutomatically = flags.contains(.connectionOnDemand) || flags.contains(.connectionOnTraffic)
        let canConnectWithoutIntervention = canConnectAutomatically && !flags.contains(.interventionRequired)
        return isReachable && (!connectionRequired || canConnectWithoutIntervention)
    }
    
    @discardableResult
    func checkConnection() -> Bool {
        var flags = SCNetworkReachabilityFlags()
        SCNetworkReachabilityGetFlags(reachability!, &flags)
        
        let oldStatus = self.isConnected
        let newStatus = isNetworkReachable(with: flags)
        
        if oldStatus != newStatus {
            NotificationManager.sendNotification(.networkStatusChangedEvent, object: newStatus)
            self.isConnected = newStatus
        } 

        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.checkConnection()
        })
        
        return newStatus
    }
    
    init() {
        self.checkConnection()
    }
}
