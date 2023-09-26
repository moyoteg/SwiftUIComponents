//
//  StringValidations.swift
//
//
//  Created by Moi Gutierrez on 9/20/23.
//

import Foundation

public extension String {
    
    /// Check if a string is a valid first name.
    var isValidFirstName: Bool {
        let nameRegex = "^[A-Za-z]{2,}$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: self)
    }
    
    /// Check if a string is a valid last name.
    var isValidLastName: Bool {
        let nameRegex = "^[A-Za-z]{2,}$"
        let nameTest = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: self)
    }
}

public extension String {
    var isValidEmail: Bool {
        // Add your email regex validation here
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }
    
    /// Check if a string is a valid phone number.
    var isValidPhoneNumber: Bool {
        // Regular expression pattern for a more comprehensive phone number validation
        let phoneNumberRegex = #"^(?:(?:\+|00)[1-9]\d{0,3}(?:[\s.-]?\d{3,}){1,}|0\d{9,11})(?:[\s.-]?\d{1,5})?$"#
        return NSPredicate(format: "SELF MATCHES %@", phoneNumberRegex).evaluate(with: self)
    }

}
