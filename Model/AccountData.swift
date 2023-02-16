//
//  AccountData.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 10/02/2023.
//

import Foundation

struct CurrencyWallet: Hashable {
    let currency: String
    var availableAmount: Double
    
    func updateBalance(sold: Double = 0, bought: Double = 0) -> CurrencyWallet {
        var ca = self
        
        ca.availableAmount -= sold
        ca.availableAmount += bought
        
        return ca
    }
}

final class AccountData {
    var wallet: [CurrencyWallet]
    var history: [OperationHistory]

    func processConversion(_ conversion: Conversion) {
        let date = Date()
        let conversion = conversion
        
        self.history.append(OperationHistory(date: date, operation: conversion))
        
        let tradedAcc = self.wallet.first { $0.currency == conversion.sellCurrency }
        
        guard let ta = tradedAcc else {
            fatalError("Error when fetching traded account for \(conversion.sellCurrency)")
        }
        
        let newta = ta.updateBalance(sold: conversion.sellAmount)
        
        let ix = self.wallet.firstIndex(of: ta)!
        self.wallet.remove(at: ix)
        
        var boughtAcc = self.wallet.first { $0.currency == conversion.buyCurrency }
        
        guard let boughtAmount = conversion.buyAmount else {
            fatalError("Unexpectedly found nil when fetching conversion buy amount")
        }
        
        if boughtAcc == nil {
            boughtAcc = CurrencyWallet(currency: conversion.buyCurrency, availableAmount: boughtAmount)
            
            let newba = boughtAcc!
            
            self.wallet.append(newta)
            self.wallet.append(newba)
        } else {
            let ix = self.wallet.firstIndex(of: boughtAcc!)!
            self.wallet.remove(at: ix)
            
            let newba = boughtAcc!.updateBalance(bought: boughtAmount)
            
            self.wallet.append(newta)
            self.wallet.append(newba)
        }
    }
    
    init() {
        self.wallet = [CurrencyWallet(currency: "EUR", availableAmount: 1000)]
        self.history = []
    }
    
    init(wallets: [CurrencyWallet], history: [OperationHistory]) {
        self.wallet = wallets
        self.history = history
    }
}
