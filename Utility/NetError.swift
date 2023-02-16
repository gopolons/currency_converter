//
//  NetError.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 11/02/2023.
//

import Foundation

enum NetError: Error {
    case noConnection
    case serverTimeout
    case badGateway
    case encodingError
    case unknownError(String? = nil)
    
    func displayDescription() -> String {
        switch self {
        case .noConnection:
            return "zeyi.popup.error.connection".localized()
        case .serverTimeout:
            return "zeyi.popup.error.timeout".localized()
        case .badGateway:
            return "zeyi.popup.error.gateway".localized()
        case .encodingError:
            return "zeyi.popup.error.encoding".localized()
        case .unknownError(let string):
            if let msg = string {
                return msg
            } else {
                return "zeyi.popup.default.failure".localized()
            }
        }
    }
}
