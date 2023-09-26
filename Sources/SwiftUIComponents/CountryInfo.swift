//
//  CountryInfo.swift
//
//
//  Created by Moi Gutierrez on 9/20/23.
//

import SwiftUI

import PhoneNumberKit

public struct CountryInfo: Hashable {
    public let flag: String
    public let phoneCode: String
    public let code: String
    public let name: String
    
    public static func defaultCountry() -> CountryInfo {
        return CountryInfo(flag: "🇺🇸", phoneCode: "+1", code: "US", name: "United States")
    }
    
    public static func getAllCountries() -> [CountryInfo] {
        let regionCodes = Locale.Region.isoRegions
        var countries: [CountryInfo] = []
        let phoneNumberKit = PhoneNumberKit()
        
        for region in regionCodes {
            guard let countryCode = phoneNumberKit.countryCode(for: region.identifier) else { continue }
            let phoneCode = "+\(countryCode)"
            
            // Using Locale to get the name of the country in English
            let countryName = Locale(identifier: "en_US").localizedString(forRegionCode: region.identifier) ?? ""
            
            countries.append(CountryInfo(flag: region.emojiFlag, phoneCode: phoneCode, code: region.identifier, name: countryName))
        }
        
        return countries
    }
}
