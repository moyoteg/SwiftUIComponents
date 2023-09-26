//
//  Region.swift
//
//
//  Created by Moi Gutierrez on 9/20/23.
//

import Foundation

public extension Locale.Region {
    var emojiFlag: String {
        let base: UInt32 = 127397
        var s = ""
        for v in identifier.unicodeScalars {
            s.unicodeScalars.append(UnicodeScalar(base + v.value)!)
        }
        return s
    }
}
