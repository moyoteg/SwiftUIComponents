//
//  Biometric.swift
//  SwiftUtilities
//
//  Created by Moi Gutierrez on 8/18/22.
//

import Foundation
import LocalAuthentication

public enum Biometric {
#if !os(tvOS) && !os(watchOS)
    public static let type = LAContext().biometryType
#endif
}

//
//  BiometricType.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 6/22/22.
//

import Foundation
import SwiftUI

#if !os(tvOS) && !os(watchOS)
import LocalAuthentication

import SwiftUtilities

public extension Biometric {
    
    static var image: Image {
        
        switch Biometric.type {
        case .none: return SwiftUI.Image("questionmark.app.dashed")
        case .touchID: return SwiftUI.Image("touchid")
        case .faceID: return SwiftUI.Image("faceid")
        @unknown default: return SwiftUI.Image("questionmark.app.dashed")
        }
    }
    
    static var name: String? {
        switch Biometric.type {
        case .none: return nil
        case .touchID: return "Touch Id"
        case .faceID: return "Face Id"
        @unknown default: return nil
        }
    }
}
#endif
