//
//  Constants.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 09/02/2023.
//

import Foundation

final class UtilityConstants {
    static let localizationUserDefaultsKey = "preferred_localization"
    
    static let defaultBaseURL = "https://api.apilayer.com/"
}

protocol APIEndpointProtocol {
    func url() -> String
}

enum APIEndpoint: APIEndpointProtocol {
   
    case exchangeRate
    
    func url() -> String {
        let base = UtilityConstants.defaultBaseURL
        
        switch self {
        case .exchangeRate:
            return base + "exchangerates_data/latest"
        }
    }
}
