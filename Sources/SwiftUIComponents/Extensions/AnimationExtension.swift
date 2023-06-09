//
//  AnimationExtension.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 10/26/20.
//

import SwiftUI

public extension Animation {
    func `repeat`(while expression: Bool, autoreverses: Bool = true) -> Animation {
        if expression {
            return self.repeatForever(autoreverses: autoreverses)
        } else {
            return self
        }
    }
}

public struct Shake: AnimatableModifier {
    public var shakes: CGFloat = 0
    
    public var animatableData: CGFloat {
        get {
            shakes
        } set {
            shakes = newValue
        }
    }
    
    public func body(content: Content) -> some View {
        content
            .offset(x: sin(shakes * .pi * 2) * 5)
    }
}

public extension View {
    func shake(with shakes: CGFloat) -> some View {
        modifier(Shake(shakes: shakes))
    }
}
