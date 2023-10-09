//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 10/2/23.
//

import SwiftUI

// A ScrollView wrapper that tracks scroll offset changes.
public struct ObservableScrollView<Content>: View where Content : View {
    @Namespace var scrollSpace
    
    @Binding var scrollOffset: CGFloat
    let content: () -> Content
    
    public init(scrollOffset: Binding<CGFloat>,
         @ViewBuilder content: @escaping () -> Content) {
        _scrollOffset = scrollOffset
        self.content = content
    }
    public var body: some View {
        ScrollView {
            content()
                .background(GeometryReader { geo in
                    let offset = -geo.frame(in: .named(scrollSpace)).minY
                    Color.clear
                        .preference(key: ScrollViewOffsetPreferenceKey.self,
                                    value: offset)
                })
        }
        .coordinateSpace(name: scrollSpace)
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
    }
}
// Simple preference that observes a CGFloat.
public struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    public static var defaultValue = CGFloat.zero
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}
