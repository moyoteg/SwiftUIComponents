//
//  ClearButton.swift
//
//  Created by Moi Gutierrez on 2/26/20.
//

import SwiftUI

import CloudyLogs

public extension View {
    
    func clearButton(text: Binding<String>, foregroundColor: Color = .blue) -> some View {
        self.modifier(ClearButton(text: text, foregroundColor: foregroundColor))
    }
}

public struct ClearButton: ViewModifier {
    
    @Binding var text: String
    
    var foregroundColor: Color
    
    public init(text: Binding<String>, foregroundColor: Color) {
        self._text = text
        self.foregroundColor = foregroundColor
    }
    
    public func body(content: Content) -> some View {
        HStack() {
            content
                .padding([.trailing], 0)
                .padding([.top, .bottom, .leading])
                        
            SwiftUI.Button(action: {
                withAnimation {
                    self.text = ""
                }
            }) {
                Image(systemName: "delete.left")
                    .foregroundColor(foregroundColor)
            }
            .opacity(text.isEmpty ? 0:1)
            .padding([.leading], 0)
            .padding([.top, .bottom, .trailing])
        }
        .fixedSize(horizontal: false, vertical: false)
    }
}

