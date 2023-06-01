//
//  ViewModifier.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 1/21/21.
//  Copyright © 2021 PragCore. All rights reserved.
//

import Foundation
import SwiftUI

public enum Modifier {
    
    public struct Demo: View {
        @State private var text = ""
        @State private var isTextMasked = true
        @State private var isImageMasked = true
        
        public var body: some View {
            List {
                Section(header: Text("Clear Button")) {
                    VStack {
                        TextField("Type something...", text: $text)
                            .modifier(Modifier.ClearButton(text: $text))
                        Text("Entered text: \(text)")
                    }
                }
                Section(header: Text("Animating Mask")) {
                    VStack {
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer eget arcu sit amet tellus auctor consequat. Praesent et leo quam. Etiam rutrum magna at risus lobortis ornare. Sed eu turpis justo. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Vivamus feugiat eros in nisl vulputate, vel interdum turpis sagittis. Proin ullamcorper sapien risus, non accumsan leo ultrices ac.")
                            .animatingMask(isMasked: isTextMasked)
                        Toggle("Mask Text", isOn: $isTextMasked)
                        
                        AutoImage("sun.max.fill")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.yellow)
                            .animatingMask(isMasked: isImageMasked)
                        Toggle("Mask Image", isOn: $isImageMasked)
                    }
                }
            }
#if !os(watchOS)
            .listStyle(GroupedListStyle())
#endif
        }
        
        public init() {}
    }
    
    // MARK: - ALL MODIFIERS
    
    struct ClearButton: ViewModifier {
        
        @Binding var text: String
        
        public init(text: Binding<String>) {
            self._text = text
        }
        
        public func body(content: Content) -> some View {
            HStack(alignment: .center) {
                content
                
                Spacer()
                
                if !text.isEmpty {
                    Button(action: {
                        withAnimation {
                            self.text = ""
                        }
                    }) {
                        AutoImage("delete.left")
                            .foregroundColor(Color.blue)
                    }
                    .padding()
                }
            }
        }
    }
    
    struct AnimatingMask: ViewModifier {
        @State private var maskPosition: CGFloat = 0
        let isMasked: Bool
        
        func body(content: Content) -> some View {
            if isMasked {
                
                content
                    .mask(
                        GeometryReader { geometry in
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: Color.clear, location: 0),
                                            .init(color: Color.black.opacity(0.5), location: 0.5),
                                            .init(color: Color.clear, location: 1)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .offset(x: maskPosition)
                                .onAppear {
                                    maskPosition = -geometry.size.width
                                    withAnimation(Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                                        maskPosition = geometry.size.width
                                    }
                                }
                                .onDisappear {
                                    maskPosition = -geometry.size.height
                                }
                        }
                    )
                    .opacity(isMasked ? 1 : 0)
                
            } else {
                content
            }
        }
    }
    
}

extension View {
    public func clearButton(text: Binding<String>) -> some View {
        modifier(Modifier.ClearButton(text: text))
    }
    
    public func animatingMask(isAnimated: Bool = true, isMasked: Bool = true) -> some View {
        modifier(Modifier.AnimatingMask(isMasked: isMasked))
    }
}

public struct GradientMaskModifier: ViewModifier {
    let colors: [Color]
    
    public func body(content: Content) -> some View {
        content
            .mask(LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .top,
                endPoint: .bottom
            ))
    }
}

public extension View {
    func gradientMask(colors: [Color] = [.clear, .black.opacity(0.5), .green.opacity(0.5)]) -> some View {
        self.modifier(GradientMaskModifier(colors: colors))
    }
}


public struct BackgroundImageFillBlur: ViewModifier {
    
    let imageResource: String
    let height: Double
    
    public func body(content: Content) -> some View {
        
        content
            .background(
                
                ZStack {
                    
                    AutoImage(imageResource)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .blur(radius: 20)
                    
                    AutoImage(imageResource)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                        .frame(height: height, alignment: .center)
                        .mask(Rectangle().edgesIgnoringSafeArea(.top))
                    
                }
                    .padding(0)
            )
    }
}

public extension View {
    func backgroundImageFillBlur(imageResource: String, height: Double) -> some View {
        self.modifier(BackgroundImageFillBlur(imageResource: imageResource, height: height))
    }
}


// MARK: - TopImageFillModifier

public struct TopImageFillModifier<Header: View>: ViewModifier {
    let imageResource: String
    let height: Double
    let header: () -> Header
    
    public init(imageResource: String, height: Double, @ViewBuilder header: @escaping () -> Header) {
        self.imageResource = imageResource
        self.height = height
        self.header = header
    }
    
    public func body(content: Content) -> some View {
        content
            .modifier(TopImageFill(imageResource: imageResource, height: height, header: header))
    }
}

extension View {
    public func topImageFill<Header: View>(imageResource: String, height: Double, @ViewBuilder header: @escaping () -> Header) -> some View {
        self.modifier(TopImageFillModifier(imageResource: imageResource, height: height, header: header))
    }
}

public struct TopImageFill<Header: View>: ViewModifier {
    let imageResource: String
    let height: Double
    let header: () -> Header
    
    public init(imageResource: String, height: Double, @ViewBuilder header: @escaping () -> Header) {
        self.imageResource = imageResource
        self.height = height
        self.header = header
    }
    
    public func body(content: Content) -> some View {
        VStack {

            VStack {
                header()
                    .frame(height: height)
            }
            .backgroundImageFillBlur(imageResource: imageResource, height: height)
            .listRowInsets(EdgeInsets())
            
            content
                .textCase(nil)
                .listRowInsets(EdgeInsets())
                .navigationBarTitleDisplayMode(.automatic)
                .listStyle(PlainListStyle())
        }
    }
}
