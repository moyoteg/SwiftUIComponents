//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 8/18/23.
//

import SwiftUI
    
public struct DragIndicator: View {
    public var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .frame(width: 68, height: 3)
            .foregroundColor(Color.white)
    }
    
    public init() {}
}
