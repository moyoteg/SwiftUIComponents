//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 8/18/23.
//

import SwiftUI
    
public struct DragIndicator: View {
    
    let color: Color
    
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 68, height: 3)
            .foregroundColor(color)
    }
    
    public init(color: Color = .white) {
        self.color = color
    }
}
