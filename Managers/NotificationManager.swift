//
//  NotificationManager.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import Foundation
import Combine

extension Notification.Name {
    // navigation events
    static var navigationEvent = Notification.Name("NavigationEvent")
    
    // view model events
    static var conversionDataChangedEvent = Notification.Name("ConversionDataChangedEvent")
    static var accountDataRequestedEvent = Notification.Name("AccountDataRequestedEvent")
        
    static var exchangeRateRequestedEvent = Notification.Name("ExchangeRateRequestedEvent")
    static var exchangeRateProvidedEvent = Notification.Name("ExchangeRateProvidedEvent")
    
    // data repo events
    static var conversionCalculationEvent = Notification.Name("ConversionCalculationEvent")
    static var conversionExecutionRequestEvent = Notification.Name("ConversionExecutionRequestEvent")
    static var accountDataChangedEvent = Notification.Name("AccountDataChangedEvent")
    
    // network status events
    static var networkStatusChangedEvent = Notification.Name("NetworkStatusChangedEvent")
}

final class NotificationManager {
    static func sendNotification(_ name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
}
