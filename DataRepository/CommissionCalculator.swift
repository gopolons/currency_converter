//
//  CommissionCalculator.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 11/02/2023.
//

import Foundation
import Combine

// first five exchanges are free of charge, else 0.7% of the traded currency
// if more than 15 exchanges per day, 1.2% + 0.3 Euros value in traded currency

protocol CommissionCalculatorBuilderProtocol {
    func addRule1()
    func addRule2()
}

final class CommissionCalculatorBuilder: CommissionCalculatorBuilderProtocol {
    private var calculator = CommissionCalculator()
    
    func reset() {
        self.calculator = CommissionCalculator()
    }
    
    func addRule1() {
        let rule = CommissionRule { accData in
            let count = accData.history.count
            if count <= 5 {
                return false
            } else {
                return true
            }
        } commission: { exchangeRate, conversion in
            return conversion.sellAmount * 0.007
        }
        
        self.calculator.addRule(rule)
    }
    
    func addRule2() {
        let rule = CommissionRule { accData in
            let calendar = Calendar.current
            var todayOpCount = 0
            
            for x in accData.history {
                if calendar.isDateInToday(x.date) {
                    todayOpCount += 1
                }
            }
            
            if todayOpCount > 15 {
                return true
            } else {
                return false
            }
        } commission: { exchangeRate, conversion in
            var commission: Double = 0

            // find the exchange rate to euro,
            // figure out how much 1 euro is
            // and multiply by 0.3
            
            for x in exchangeRate.rates {
                if x.key == "EUR" {
                    commission = ((1 / x.value) * 0.3)
                }
            }
            
            commission += conversion.sellAmount * 0.012
            return commission
        }
        
        calculator.addRule(rule)
    }
    
    func retrieveCalculator() -> CommissionCalculator {
        let result = self.calculator
        self.reset()
        return result
    }
}

final class CommissionCalculator {
    private var rules = [CommissionRule]()
    
    func addRule(_ rule: CommissionRule) {
        self.rules.append(rule)
    }
    
    func calculateCommission(accountData: AccountData, exchangeRate: ExchangeRate, conversion: Conversion) -> Conversion? {
        var conversion = conversion
        var commission: Double = 0
        
        for x in rules {
            let c = x.calculateComission(accountData, rate: exchangeRate, conversion: conversion)
            commission += c
        }
        
        conversion.commission = commission
        
        return conversion
    }
}
