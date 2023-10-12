//
//  JailbreakSecurity.swift
//
//
//  Created by Moi Gutierrez on 10/11/23.
//

import Foundation
import SwiftUI

public struct JailbreakSecurity {
    
    // Check for signs of jailbreak using multiple methods
    
    public static func isJailbroken() -> Bool {
        return hasCydia() || isFilePresent() || isSuspiciousPath() || isRootAccess()
    }
    
    // Check if Cydia app is installed
    
    private static func hasCydia() -> Bool {
        let cydiaURL = URL(string: "cydia://package/com.example.package")
        return UIApplication.shared.canOpenURL(cydiaURL!)
    }
    
    // Check for the presence of common jailbreak files
    
    private static func isFilePresent() -> Bool {
        let fileManager = FileManager.default
        let paths = [
            "/Applications/Cydia.app",
//            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/private/var/lib/cydia",
            "/private/var/stash"
        ]
        for path in paths {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    // Check for suspicious file paths
    
    private static func isSuspiciousPath() -> Bool {
        let suspiciousPaths = [
//            "/Applications",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            "/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            "/private/var/tmp/cydia.log",
            "/private/var/lib/cydia"
        ]
        let fileManager = FileManager.default
        for path in suspiciousPaths {
            if fileManager.fileExists(atPath: path) {
                return true
            }
        }
        return false
    }
    
    // Check for root access
    
    private static func isRootAccess() -> Bool {
        if getuid() == 0 {
            return true
        }
        return false
    }
}
