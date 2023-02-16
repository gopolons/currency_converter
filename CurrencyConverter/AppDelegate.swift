//
//  AppDelegate.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import SwiftUI

/*
 Application delegate is initialised at the start of the app.
 It will generate the coordinator, depending on the launch options.
 Such a setup allows us to pass any instruction into the coordinator object, thus making it easier to functionality such as deep links
*/

final class AppDelegate: NSObject, UIApplicationDelegate {
    private var appCoordinator: CoordinatorObject?
    private var dataRepository: DataRepositoryProtocol?
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // initialise the coordinator, perform any setup depending on the launch options
        let ac = CoordinatorObject(launchOptions: launchOptions)
        
        self.appCoordinator = ac
        
        // initialise the data repository
        let dr = DataRepository()
        
        self.dataRepository = dr
        
        return true
    }
}

extension AppDelegate {
    func fetchCoordinator() -> CoordinatorObject {
        guard let ac = self.appCoordinator else {
            fatalError("Could not retrieve mainCoordinator @ AppDelegate")
        }
        
        return ac
    }
}
