//
//  FullScreenModalView.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 1/17/21.
//  Copyright © 2021 PragCore. All rights reserved.
//

import Foundation
import SwiftUI

#if os(tvOS)
public struct FullScreenModalView: View {
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        VStack {
            Text("This is a modal view")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red)
        .edgesIgnoringSafeArea(.all)
        .onExitCommand(perform: {
            presentationMode.wrappedValue.dismiss()
        })
    }
}
#else
public struct FullScreenModalView: View {
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        VStack {
            Text("This is a modal view")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red)
        .edgesIgnoringSafeArea(.all)
    }
}
#endif
