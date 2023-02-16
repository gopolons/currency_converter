//
//  DataRepository.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import Foundation
import Combine

protocol DataRepositoryProtocol {
    func calculateConversion()
    func executeConversion()
    
    func setupDataFetch()
}

//properties implementation
final class DataRepository {
    // scheduler that is requesting exchange data every 60 seconds from the remote server
    private var timer: Timer?
    
    // boolean that reflects the availability of the network - updated by the networkStateChangedCancellable .sink() method
    private var isNetworkAvailable: Bool
    
    // persistence manager responsible for storing and retrieving persistent data from core data
    private var persistenceManager: PersistenceManagerProtocol
    
    // current conversion - updated values are received from the converter view model
    private var conversion: Conversion
    // commission calculator - responsible for storing rules and calculating the commission depending on the account data
    private var commissionCalculator: CommissionCalculator
    
    // exchange rate data updated by the fetchExchangeRates() method
    private var exchangeRate: ExchangeRate?
    
    // account data fetched from persistent storage, updated and distributed to the view model
    private var accountData: AccountData?
    
    // cancellables responsible for receiving notifications from view model, persistent store, conversion calculator
    private var networkStateChangedCancellable: AnyCancellable?
    private var conversionDataChangedCancellable: AnyCancellable?
    private var conversionExecutionRequestCancellable: AnyCancellable?
    private var accountDataRequestCancellable: AnyCancellable?
    private var exchangeRateRequestedCancellable: AnyCancellable?
    
    init() {
        self.persistenceManager = PersistenceManager()
        self.conversion = Conversion()
        
        let isAvailable = Reachability.shared.checkConnection()
        self.isNetworkAvailable = isAvailable
        
        let builder = CommissionCalculatorBuilder()
        builder.addRule1()
        builder.addRule2()
        self.commissionCalculator = builder.retrieveCalculator()
        
        self.fetchFromPersistentStore()
        
        self.setupForNotification()
        self.setupDataFetch()
    }
}

// private methods implementation
extension DataRepository {
    private func fetchExchangeRates(completion: ((ExchangeRate) -> Void)? = nil) {
        guard isNetworkAvailable else {
            return
        }
        
        let base = conversion.sellCurrency
        
        NetworkHandler.request(method: .get, endpoint: APIEndpoint.exchangeRate, queryParameters: ["base" : base]) { response, error in
            guard error == nil else {
                // MARK: -- TO DO: IMPLEMENT ERROR HANDLING
                return
            }
           
            guard let resp = response else {
                // MARK: -- TO DO: IMPLEMENT UNKNOWN ERROR
                return
            }
            
            guard let d = try? JSONDecoder().decode(ExchangeRate.self, from: resp) else {
                // MARK: -- TO DO: IMPLEMENT DECODING ERROR
                return
            }
            
            self.exchangeRate = d
            
            completion?(d)
        }
    }
    
    private func saveToPersistentStore() {
        guard let data = self.accountData else {
            fatalError("Found nil when trying to save account data to persistent store @ DataRepository")
        }
        
        self.persistenceManager.saveData(data)
    }
    
    private func fetchFromPersistentStore() {
        if self.accountData == nil {
            self.accountData = self.persistenceManager.fetchData()
        }
        
        NotificationManager.sendNotification(.accountDataChangedEvent, object: self.accountData!)
    }
    
    private func setupForNotification() {
        self.networkStateChangedCancellable = NotificationCenter.default
            .publisher(for: .networkStatusChangedEvent)
            .compactMap { $0.object as? Bool }
            .sink { isAvailable in
                // MARK: -- TO DO: IMPLEMENT NETWORK STATUS UPDATE
                isAvailable ? self.setupDataFetch() : self.timer?.invalidate()
            }
        
        self.conversionDataChangedCancellable = NotificationCenter.default
            .publisher(for: .conversionDataChangedEvent)
            .compactMap { $0.object as? Conversion }
            .sink { conversion in
                self.conversion = conversion
                self.calculateConversion()
            }
        
        self.conversionExecutionRequestCancellable = NotificationCenter.default
            .publisher(for: .conversionExecutionRequestEvent)
            .sink(receiveValue: { _ in
                self.executeConversion()
            })
        
        self.accountDataRequestCancellable = NotificationCenter.default
            .publisher(for: .accountDataRequestedEvent)
            .sink(receiveValue: { _ in
                self.fetchFromPersistentStore()
            })
        
        self.exchangeRateRequestedCancellable = NotificationCenter.default
            .publisher(for: .exchangeRateRequestedEvent)
            .sink(receiveValue: { _ in
                let data = self.exchangeRate
                if data == nil {
                    self.fetchExchangeRates { rate in
                        NotificationManager.sendNotification(.exchangeRateProvidedEvent, object: rate)
                    }
                }
                NotificationManager.sendNotification(.exchangeRateProvidedEvent, object: data)
            })
    }
}

// public interface implementation
extension DataRepository: DataRepositoryProtocol {
    func setupDataFetch() {
        self.timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { _ in
            self.fetchExchangeRates()
        })
        self.timer?.fire()
    }
    
    func calculateConversion() {        
        let conversion = self.conversion
        let desiredRate = exchangeRate?.rates.first { $0.key == conversion.buyCurrency }
        
        guard let desiredRate = desiredRate, let er = exchangeRate else {
            // MARK: -- TO DO: CONVERSION RATE NOT FOUND
            return
        }
        
        guard let ad = self.accountData else {
            // MARK: -- TO DO: NIL WHEN FETCHING ACCOUNT DATA
            return
        }

        let buyAmount = desiredRate.value * conversion.sellAmount
        
        guard var newConversion = commissionCalculator.calculateCommission(accountData: ad, exchangeRate: er, conversion: conversion) else {
            // MARK: -- TO DO: COMMISSION CALCULATION ERROR
            return
        }
        
        newConversion.buyAmount = buyAmount
        
        self.conversion = newConversion
            
        // MARK: -- TO DO: SEND OUT A NOTIFICATION TO UPDATE VIEW MODEL
        NotificationManager.sendNotification(.conversionCalculationEvent, object: newConversion)
    }
    
    func executeConversion() {
        guard self.accountData != nil else {
            // MARK: -- TO DO: NIL WHEN FETCHING ACCOUNT DATA
            return
        }
        
        let conversion = self.conversion
        
        self.accountData!.processConversion(conversion)
        
        saveToPersistentStore()
        fetchFromPersistentStore()
        calculateConversion()
    }
}
