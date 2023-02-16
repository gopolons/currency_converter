//
//  Double.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 11/02/2023.
//

import Foundation

//Rounds the double to decimal places value

extension Double {
    func roundToDecimal(_ fractionDigits: Int) -> Double {
        let multiplier = pow(10, Double(fractionDigits))
        return Darwin.round(self * multiplier) / multiplier
    }
}

extension Double {
    func truncate(places: Int) -> String {
        return String(format: "%.\(places)f", self.roundToDecimal(places))
    }
}
