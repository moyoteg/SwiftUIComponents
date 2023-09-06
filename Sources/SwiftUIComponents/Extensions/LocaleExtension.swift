//
//  LocaleExtension.swift
//  
//
//  Created by Moi Gutierrez on 9/5/23.
//

import Foundation

public extension Locale {
    static var preferredLanguageCode: String {
        guard let preferredLanguage = preferredLanguages.first,
              let code = Locale(identifier: preferredLanguage).language.languageCode?.identifier else {
            return "en"
        }
        return code
    }
    
    static var preferredLanguageCodes: [String] {
        return Locale.preferredLanguages.compactMap({Locale(identifier: $0).language.languageCode?.identifier})
    }
}
