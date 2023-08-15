//
//  UserDefaults.swift
//  Common
//
//  Created by Moi Gutierrez on 1/17/20.
//

import Foundation

import SwiftyUserDefaults
import SwiftUtilities

public extension DefaultsKeys {

    /// Add all Default values here
    
    /// **********************************
    /// Usage History Settings
    var launchCount: DefaultsKey<Int> { return .init("launchCount", defaultValue: 0) }
    var versionLastRun: DefaultsKey<String?> { return .init("versionLastRun", defaultValue: nil) }
    var isAppStoreVersion: DefaultsKey<Bool?> { return .init("isAppStoreVersion", defaultValue: nil) }
    var buildLastRun: DefaultsKey<String?> { return .init("buildLastRun", defaultValue: nil) }
    var lastAppBecameInactiveDate: DefaultsKey<Date?> { return .init("lastAppBecameInactiveDate", defaultValue: nil) }
    var useDemoData: DefaultsKey<Bool> { return .init("useDemoData", defaultValue: false) }
    var demoDataSource: DefaultsKey<Demo.Data.SourceLocation> { return .init("demoDataSource", defaultValue: .local) }
    var diagnosticsEnabled: DefaultsKey<Bool> { return .init("diagnosticsEnabled", defaultValue: false) }
    /// **********************************
}
