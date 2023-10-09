//
//  AnimatedEllipsis.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 9/29/22.
//

import SwiftUI

public struct AnimatedEllipsis: View {
    
    @State private var fadeInOut = false
    
    private var maxCount = 3
    
    @State var currentText = ""
    
    static let period = 0.5
    
    let timer = Timer.publish(every: period, on: .main, in: .default).autoconnect()

    public var body: some View {
        
        Text("\(currentText)")
        
            .onReceive(timer) { input in
                
                if currentText.count < maxCount {
                    withAnimation(Animation.easeOut) {
                        currentText.append(".")
                    }
                } else {
                    withAnimation(Animation.easeOut) {
                        currentText = ""
                    }
                }
                
//                withAnimation(Animation.easeOut(duration: AnimatedEllipsis.period/2)) {
//                    fadeInOut.toggle()
//
//                    let deadline: DispatchTime = .now() + AnimatedEllipsis.period/2
//                    DispatchQueue.main.asyncAfter(deadline: deadline) {
//                        withAnimation(.easeOut(duration: AnimatedEllipsis.period/2)) {
//                            fadeInOut.toggle()
//                        }
//                    }
//                }
                
            }
            .onAppear {
                
            }
            .opacity(fadeInOut ? 0:1)
    }
    
    public init() {}
    
    public struct Tester: View {
        
        public var body: some View {
            AnimatedEllipsis()
        }
        
        public init() {}

    }
}

struct AnimatedEllipsis_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedEllipsis()
    }
}
