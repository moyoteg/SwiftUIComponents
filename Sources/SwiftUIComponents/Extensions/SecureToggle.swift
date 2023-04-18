//
//  SecureToggle.swift
//  UI
//
//  Created by Moi Gutierrez on 12/9/20.
//

import SwiftUI
import UIKit

import CloudyLogs
import Introspect

public extension View {
    
    func secureToggle(foregroundColor: Color = .blue) -> some View {
        self.modifier(SecureToggle(foregroundColor: foregroundColor))
    }
}
    
public struct SecureToggle: ViewModifier {
    
    @State private var isSecure: Bool = true {
        didSet {
            Logger.log("SecureToggle: didSet: isSecure: \(isSecure)")
        }
    }
    
    var foregroundColor: Color
    
    public func body(content: Content) -> some View {
        
        HStack(alignment: .center) {
            
            if isSecure {
                content
                    .introspectTextField { (textField) in
                        textField.isSecureTextEntry = isSecure
                    }
                    .padding([.trailing], 0)
                    .padding([.top, .bottom, .leading])
            } else {
                content
                    .introspectTextField { (textField) in
                        textField.isSecureTextEntry = isSecure
                    }
                    .padding([.trailing], 0)
                    .padding([.top, .bottom, .leading])
            }
            
            Spacer()
            
            SwiftUI.Button(action: {
                
                isSecure.toggle()
                
            }) {
                
                URLImage(systemName: isSecure ? "eye.slash":"eye")
                    .foregroundColor(foregroundColor)
            }
            .padding([.leading], 0)
            .padding([.top, .bottom, .trailing])
        }
    }
}

