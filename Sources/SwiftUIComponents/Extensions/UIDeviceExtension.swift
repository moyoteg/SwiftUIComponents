//
//  UIDeviceExtension.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 10/15/20.
//

#if !os(tvOS) && !os(watchOS)
import UIKit

import DeviceKit

public extension UIDevice {
    
    static var model: DeviceKit.Device {
        return Device.current
    }
    
    /// pares the deveice name as the standard name
    static var modelName: String {
        return "\(Device.current.description)"
    }
    
}

public extension UIDevice {
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machine = Mirror(reflecting: systemInfo.machine).children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        return machine
    }
}

#endif
