//
//  LocalizationManager.swift
//  CurrencyConverter
//
//  Created by Georgy Polonskiy on 10/02/2023.
//

import Foundation

final class LocalizationManager {
    static var shared = LocalizationManager()
    
    private var currentLanguage: String
    
    func getLocaleCode() -> String {
        return currentLanguage
    }
    
    func updateLanguagePreference(_ lang: LocalizationOption, completion: @escaping () -> Void) {
        UserDefaults.standard.set(lang.rawValue, forKey: UtilityConstants.localizationUserDefaultsKey)
        UserDefaults.standard.synchronize()
        
        self.currentLanguage = lang.rawValue
    }
    
    init() {
        if let _ = UserDefaults.standard.string(forKey: UtilityConstants.localizationUserDefaultsKey) {} else {
            // we set a default, just in case
            UserDefaults.standard.set(LocalizationOption.english.rawValue, forKey: UtilityConstants.localizationUserDefaultsKey)
            UserDefaults.standard.synchronize()
        }
        
        let lang = UserDefaults.standard.string(forKey: UtilityConstants.localizationUserDefaultsKey)
        
        guard let lang = lang else {
            fatalError("Error when initialising LocalizationManager")
        }
        
        self.currentLanguage = lang
    }
}

enum LocalizationOption: String {
    case english = "en"
}
