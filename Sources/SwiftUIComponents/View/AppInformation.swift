//
//  AppInformation.swift
//  SwiftUtilities
//
//  Created by Moi Gutierrez on 8/22/22.
//

import Foundation

import SwiftUtilities
import SwiftyUserDefaults

public enum AppInformation {
    
    public static var launchCount: Int {
        return Defaults[\.launchCount]
    }
    
    public static var version: String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "no version available"
    }
    
    public static var build: String {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "no build available"
    }
    
    public static var versionLastRun: String? {
        return Defaults[\.versionLastRun]
    }
    
    public static var buildLastRun: String? {
        return Defaults[\.buildLastRun]
    }
    
    public static var isRunningFromDebugger: Bool {
        return SwiftUtilities.isRunningFromXcodeDebugger()
    }
}
