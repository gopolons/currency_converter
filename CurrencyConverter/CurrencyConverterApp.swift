//
//  CurrencyConverterApp.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import SwiftUI

@main
struct CurrencyConverterApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            CoordinatorView(coordinatorObject: appDelegate.fetchCoordinator())
        }
    }
}
