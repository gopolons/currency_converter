//
//  Conversion.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 11/02/2023.
//

import Foundation

struct Conversion {
    let sellCurrency: String
    let buyCurrency: String
    let sellAmount: Double
    var buyAmount: Double?
    var commission: Double?
    
    init(sellCurrency: String = "EUR", buyCurrency: String = "USD", sellAmount: Double = 0.00) {
        self.sellCurrency = sellCurrency
        self.buyCurrency = buyCurrency
        self.sellAmount = sellAmount
    }
    
    init(sellCurrency: String, buyCurrency: String, sellAmount: Double, buyAmount: Double, commission: Double) {
        self.sellCurrency = sellCurrency
        self.buyCurrency = buyCurrency
        self.sellAmount = sellAmount
        self.buyAmount = buyAmount
        self.commission = commission
    }
}
