//
//  String.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 10/02/2023.
//

import Foundation

extension String {
    func localized() -> String {

        let lang = LocalizationManager.shared.getLocaleCode()
        
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)

        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}
