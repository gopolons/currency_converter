//
//  ConverterViewModel.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import SwiftUI
import Combine

// public interface declaration
protocol ConverterViewModelProtocol: ObservableObject {
    var isConversionAvailable: Bool { get set }
    
    var sellCurrency: String { get set }
    var sellAmount: String { get set }
    
    var commissionAmount: String { get set }
    
    var buyCurrency: String { get set }
    var buyAmount: String { get set }
    
    var wallet: [CurrencyWallet]? { get set }
    
    var performedConversion: Conversion? { get set }
    var showAlert: Bool { get set }
    
    func executeConversion()
    func selectCurrency(_ type: CurrencySelectorViewType)
    
    func dismissAlert()
}

final class ConverterViewModel: ConverterViewModelProtocol {
    @Published var showAlert: Bool
    
    @Published var sellCurrency: String
    @Published var sellAmount: String

    @Published var commissionAmount: String

    @Published var buyCurrency: String
    @Published var buyAmount: String
    @Published var wallet: [CurrencyWallet]?
    
    @Published var performedConversion: Conversion?
   
    @Published var isConversionAvailable: Bool
    
    // used for receiving notifications from data repository and currency selector view model
    private var sellAmountChangeCancellable: AnyCancellable?
    private var conversionCalculationCancellable: AnyCancellable?
    private var accountDataChangedCancellable: AnyCancellable?
    private var selectedCurrencyChangedCancellable: AnyCancellable?
    
    // after the user taps on the currency selection buttons,
    // the navigation method is called with the
    // desired currency type to be selected
    func selectCurrency(_ type: CurrencySelectorViewType) {
        let info: [AnyHashable : Any] = ["fromType" : type]
        
        NotificationManager.sendNotification(.navigationEvent, object: CoordinatorFlow.selector, userInfo: info)
    }
    
    // method for dismissing the currency confirmation alert
    func dismissAlert() {
        self.showAlert = false
        self.performedConversion = nil
    }
   
    // collects the data for the display of the conversion status prompt and sends
    // the notification for the conversion to be processed by the data repository
    func executeConversion() {
        let sc = self.sellCurrency
        let bc = self.buyCurrency
        guard let sa = Double(self.sellAmount), let ba = Double(self.buyAmount), let ca = Double(self.commissionAmount) else {
            return
        }
        
        let conversion = Conversion(sellCurrency: sc, buyCurrency: bc, sellAmount: sa, buyAmount: ba, commission: ca)
        self.performedConversion = conversion
        
        self.showAlert = true
        
        NotificationManager.sendNotification(.conversionExecutionRequestEvent)
        
    }
    
    private func setupForNotification() {
        self.sellAmountChangeCancellable = $sellAmount
            .map { $0.lowercased() }
            .sink(receiveValue: { amount in
                let x = amount
                
                // checking that the value is double and is of correct format
                guard x != "", Double(x) != 0, let sellAmount = Double(x) else {
                    self.isConversionAvailable = false
                    return
                }
                
                let sellCurrency = self.sellCurrency
                let buyCurrency = self.buyCurrency
                
                let conversion = Conversion(sellCurrency: sellCurrency, buyCurrency: buyCurrency, sellAmount: sellAmount)
                
                NotificationManager.sendNotification(.conversionDataChangedEvent, object: conversion)
            })
        
        
        self.conversionCalculationCancellable = NotificationCenter.default
            .publisher(for: .conversionCalculationEvent)
            .compactMap { $0.object as? Conversion }
            .sink { conversion in
                guard let buyAmount = conversion.buyAmount, let commission = conversion.commission else {
                    return
                }
                
                self.buyAmount = "\(buyAmount.truncate(places: 2))"
                self.commissionAmount = "\(commission.truncate(places: 2))"
                
                guard let sellWallet = self.wallet?.first(where: { cw in
                    cw.currency == self.sellCurrency
                }) else {
                    fatalError("Could not find wallet for sold currency")
                }
                
                guard let commission = Double(self.commissionAmount), let sell = Double(self.sellAmount) else {
                    self.isConversionAvailable = false
                    return
                }
                
                let balance = sellWallet.availableAmount - (commission + sell)
                
                if balance < 0 {
                    self.isConversionAvailable = false
                } else {
                    self.isConversionAvailable = true
                }
            }
        
        self.accountDataChangedCancellable = NotificationCenter.default
            .publisher(for: .accountDataChangedEvent)
            .compactMap { $0.object as? AccountData }
            .sink(receiveValue: { accountData in
                self.wallet = accountData.wallet
            })
        
        self.selectedCurrencyChangedCancellable = NotificationCenter.default
            .publisher(for: .navigationEvent)
            .sink(receiveValue: { notif in
                guard let info = notif.userInfo else {
                    return
                }
                
                guard let fromType = info["fromType"] as? CurrencySelectorViewType, let currency = info["currency"] as? String else {
                    return
                }
                
                switch fromType {
                case .selectSell:
                    self.sellCurrency = currency
                    if self.buyCurrency == currency {
                        self.buyCurrency = "EUR"
                    }
                case .selectBuy:
                    self.buyCurrency = currency
                    if self.sellCurrency == currency {
                        self.sellCurrency = "EUR"
                    }
                }
            })
    }
    
    init() {
        self.sellCurrency = "EUR"
        self.sellAmount = "0.00"
        
        self.commissionAmount = "0.00"
        
        self.buyCurrency = "USD"
        self.buyAmount = "0.00"
        
        self.isConversionAvailable = false
        self.showAlert = false
        
        self.setupForNotification()
        
        NotificationManager.sendNotification(.accountDataRequestedEvent)
    }
}

// mock converter built for previews
final class MockConverterViewModel: ConverterViewModelProtocol {
    @Published var showAlert: Bool = false
    
    @Published var performedConversion: Conversion?
    
    var isConversionAvailable: Bool = true
    
    @Published var sellCurrency: String
    @Published var sellAmount: String
    
    @Published var commissionAmount: String
    
    @Published var buyCurrency: String
    @Published var buyAmount: String
    
    @Published var wallet: [CurrencyWallet]?
    
    func goTo(_ destination: CoordinatorFlow) {
        
    }
    
    func dismissAlert() {
        self.showAlert = false
    }
   
    private func setupForNotification() {
        
    }
    
    func executeConversion() {
        
    }
    
    func selectCurrency(_ type: CurrencySelectorViewType) {
        
    }
    
    init() {
        self.sellCurrency = "EUR"
        self.sellAmount = "0.00"
        
        self.commissionAmount = "0.00"
        
        self.buyCurrency = "USD"
        self.buyAmount = "0.00"
        
        self.setupForNotification()
    }
}
