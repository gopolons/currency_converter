//
//  CommissionRule.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 11/02/2023.
//

import Foundation

struct CommissionRule {
    /*
     Condition will take the account data and based on the outcome of
     a particular check will decide if the comission will need to be applied
     */
    
    private let condition: (AccountData) -> Bool
    
    private let commission: (ExchangeRate, Conversion) -> Double
    
    func calculateComission(_ accountData: AccountData, rate: ExchangeRate, conversion: Conversion) -> Double {
        if condition(accountData) {
            return commission(rate, conversion)
        } else {
            return 0
        }
    }
    
    init(condition: @escaping (AccountData) -> Bool, commission: @escaping (ExchangeRate, Conversion) -> Double) {
        self.condition = condition
        self.commission = commission
    }
}
