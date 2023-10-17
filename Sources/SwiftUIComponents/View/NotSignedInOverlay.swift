//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 10/12/23.
//

import SwiftUI

import CloudyLogs

public struct NotSignedInOverlay<OverlayContent: View>: ViewModifier {
    let isSignedIn: Bool
    let overlayContent: () -> OverlayContent
    
    public func body(content: Content) -> some View {
        ZStack {
            if isSignedIn {
                content
            } else {
                content
                    .disabled(true)
                    .blur(radius: 3)
                overlayContent()
            }
        }
    }
}

public extension View {
    func notSignedInOverlay<Overlay: View>(
        isSignedIn: Bool,
        @ViewBuilder overlay: @escaping () -> Overlay
    ) -> some View {
        self.modifier(NotSignedInOverlay(isSignedIn: isSignedIn, overlayContent: overlay))
    }
}

