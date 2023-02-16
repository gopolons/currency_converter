//
//  ExchangeRate.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 11/02/2023.
//

import Foundation

struct ExchangeRate: Decodable {
    let base: String
    let rates: [String : Double]
    
    init(base: String, rates: [String : Double]) {
        self.base = base

        var emp: [String : Double] = [:]
        
        for x in rates {
            emp[x.key] = x.value
        }
        
        self.rates = emp
    }
}
