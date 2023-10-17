//
//  ViewModifier.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 1/21/21.
//  Copyright © 2021 PragCore. All rights reserved.
//

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
    
    public struct ClearButton: ViewModifier {
        
        @Binding var text: String
        var gradienMaskColors: [Color]
        
        public init(text: Binding<String>, gradienMaskColors: [Color] = [.primary]) {
            self._text = text
            self.gradienMaskColors = gradienMaskColors
        }
        
        public func body(content: Content) -> some View {
            HStack(alignment: .center) {
                content
                                
                if !text.isEmpty {
                    Image(systemName: "delete.left.fill")
                        .renderingMode(.template)
                        .foregroundStyle(.linearGradient(colors: gradienMaskColors, startPoint: .leading, endPoint: .trailing) )
                        .onTapGesture {
                            withAnimation {
                                self.text = ""
                            }
                        }
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
                                        gradient: Gradient(colors: [
                                            Color.white.opacity(0.1),
                                            Color.black.opacity(1),
                                            Color.white.opacity(0.1),
                                        ])
                                        ,
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .offset(x: maskPosition)
                                .onAppear {
                                    maskPosition = -geometry.size.width
                                    withAnimation(Animation.easeInOut(duration: 1.8).repeatForever(autoreverses: true)) {
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
    public func addDragIndicator(color: Color = .white) -> some View {
        modifier(AddDragIndicator(color: color))
    }
}

public struct AddDragIndicator: ViewModifier {
    
    let color: Color
    
    public func body(content: Content) -> some View {
        VStack {
            DragIndicator(color: color)
                .padding(.top)
                .background(.clear)
            content
                
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
                        .frame(alignment: .center)
                        .mask(Rectangle().edgesIgnoringSafeArea(.top))
                        .overlayGradientFocus(position: .top)
                    
                }
                    .padding(0)
            )
    }
}

public extension View {
    func backgroundImageFillBlur(imageResource: String) -> some View {
        self.modifier(BackgroundImageFillBlur(imageResource: imageResource))
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
    
//    @State var scrollOffset = CGFloat.zero

    public init(imageResource: String, height: Double, @ViewBuilder header: @escaping () -> Header) {
        self.imageResource = imageResource
        self.height = height
        self.header = header
    }
    
    public func body(content: Content) -> some View {
        VStack {

            VStack {
                header()
            }
            .frame(height: height)
            .backgroundImageFillBlur(imageResource: imageResource)
            .listRowInsets(EdgeInsets())
            
//            ObservableScrollView(scrollOffset: $scrollOffset) {
                content
                    .textCase(nil)
                    .listRowInsets(EdgeInsets())
                    .navigationBarTitleDisplayMode(.automatic)
                    .listStyle(PlainListStyle())
//                    .frame(height: max(50, 100 - max(scrollOffset, 0)))
//            }
        }
    }
}

public extension View {
    func tagImage(imageResource: String, text: String = "", foregroundColor: Color, shadowColor: Color = .black) -> some View {
        self.modifier(TagImage(imageResource: imageResource, text: text, foregroundColor: foregroundColor, shadowColor: shadowColor))
    }
}

public struct TagImage: ViewModifier {
    
    public var imageResource: String
    public var text: String
    public var foregroundColor: Color
    public var shadowColor: Color
    
    let frame = 16.0
    
    public func body(content: Content) -> some View {
        
        ZStack {
            
            content
            
            VStack {
                
                Spacer()
                
                HStack {
                    
                    HStack {
                        
                        AutoImage(imageResource)
                            .resizable()
                            .renderingMode(.template)
                            .foregroundColor(foregroundColor.opacity(0.5))
                            .frame(width: frame, height: frame)
                            .shadow(color: shadowColor, radius: 5)
                            .padding(2)

                        Text(text)
                            .padding(2)
                            .foregroundColor(foregroundColor.opacity(0.5))
                            .shadow(color: shadowColor, radius: 5)
                            .font(.caption)
                    }
                    .padding(frame/2)
                    .background(.ultraThinMaterial.opacity(0.5))
                    .cornerRadius(frame)
                    
                    Spacer()
                }
            }
            .padding(4)
        }
    }
}

struct TagImage_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, world!")
            .modifier(TagImage(imageResource: "car", text: "car", foregroundColor: .white, shadowColor: .green))
    }
}
