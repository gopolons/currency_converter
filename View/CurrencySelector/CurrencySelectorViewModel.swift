//
//  CurrencySelectorViewModel.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 14/02/2023.
//

import Foundation
import Combine

enum CurrencySelectorViewType {
    case selectSell
    case selectBuy
}

protocol CurrencySelectorViewModelProtocol: ObservableObject {
    var type: CurrencySelectorViewType { get set }
    
    var availableCurrencies: [String] { get set } 
    
    func selectCurrency(_ currency: String)
}

final class CurrencySelectorViewModel: CurrencySelectorViewModelProtocol {
    var type: CurrencySelectorViewType
    
    // for selecting buy currency - data repository's exchange rates
    // for selecting sell currency - wallet's available currencies
    var availableCurrencies: [String]
    
    var navigationCancellable: AnyCancellable?
    
    var exchangeDataCancellable: AnyCancellable?
    var accountDataCancellable: AnyCancellable?
    
    func selectCurrency(_ currency: String) {
        NotificationManager.sendNotification(.navigationEvent, object: CoordinatorFlow.converter, userInfo: ["fromType" : type, "currency" : currency])
    }
    
    private func requestRates() {
        NotificationManager.sendNotification(.exchangeRateRequestedEvent)
    }
    
    private func setupForNotification() {
        self.navigationCancellable = NotificationCenter.default
            .publisher(for: .navigationEvent)
            .sink(receiveValue: { notif in
                guard let obj = notif.object as? CoordinatorFlow, let info = notif.userInfo, obj == CoordinatorFlow.selector else {
                    return
                }
                
                guard let type = info["fromType"] as? CurrencySelectorViewType else {
                    fatalError("CurrencySelectorViewModel received navigation event with a missing type")
                }
              
                // the navigation event arrives with data regarding the purpose of the selected currency
                // after, the currencies are requested from the data repository
                
                // account data wallet for selecting sell currencies
                // exchange data currencies for selecting buy currencies
                
                if type == .selectSell {
                    NotificationManager.sendNotification(.accountDataRequestedEvent)
                } else {
                    NotificationManager.sendNotification(.exchangeRateRequestedEvent)
                }
                
                self.type = type
            })
       
        // receiving exchange data from data repository for displaying available buy currencies
        self.exchangeDataCancellable = NotificationCenter.default
            .publisher(for: .exchangeRateProvidedEvent)
            .map { $0.object as? ExchangeRate }
            .sink(receiveValue: { rate in
                guard let rate = rate else {
                    return
                }
                
                var currencies = [String]()
                
                for x in rate.rates {
                    currencies.append(x.key)
                }
                
                self.availableCurrencies = currencies
//                print(self.availableCurrencies)
            })
        
        // receiving wallet from data repository for displaying available sell currencies
        self.accountDataCancellable = NotificationCenter.default
            .publisher(for: .accountDataChangedEvent)
            .compactMap { $0.object as? AccountData }
            .sink(receiveValue: { accountData in
                var currencies = [String]()
                
                for x in accountData.wallet {
                    currencies.append(x.currency)
                }
                
                self.availableCurrencies = currencies
//                print(self.availableCurrencies)
            })
    }
    
    init() {
        self.type = .selectBuy
        self.availableCurrencies = ["EUR", "USD"]
        self.setupForNotification()
        NotificationManager.sendNotification(.exchangeRateRequestedEvent)
    }
}

// mock view model used for previews
final class MockCurrencySelectorViewModel: CurrencySelectorViewModelProtocol {
    var type: CurrencySelectorViewType
    
    var availableCurrencies: [String]
    
    func selectCurrency(_ currency: String) {
        
    }
    
    func goTo(_ destination: CoordinatorFlow) {
        
    }
    
    init() {
        self.type = .selectBuy
        
        self.availableCurrencies = ["EUR", "USD"]
    }
}
