//
//  CoordinatorObject.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import SwiftUI
import Combine

protocol CoordinatorObjectProtocol: ObservableObject {
    var currentFlow: CoordinatorFlow { get set }
}

final class CoordinatorObject: CoordinatorObjectProtocol {
    @Published var currentFlow: CoordinatorFlow

    private var flowCancellable: AnyCancellable?
    
    private func setupForNotifications() {
        self.flowCancellable = NotificationCenter.default
            .publisher(for: .navigationEvent)
            .compactMap { $0.object as? CoordinatorFlow }
            .sink(receiveValue: { flow in
                self.currentFlow = flow
            })
    }
    
    init(launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        self.currentFlow = .converter
        self.setupForNotifications()
    }
}


final class MockCoordinatorObject: CoordinatorObjectProtocol {
    @Published var currentFlow: CoordinatorFlow = .converter
    
    func setupForNotifications() {
        
    }
}
