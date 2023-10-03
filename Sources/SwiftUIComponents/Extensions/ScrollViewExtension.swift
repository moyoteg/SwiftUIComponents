//
//  ScrollViewExtension.swift
//
//
//  Created by Moi Gutierrez on 10/2/23.
//

import SwiftUI

//public extension ScrollView {
//    
//    // NB: CaptureScrollingOffset.EnvironmentKey is a class, so the value can be "shared" between Views,
//    //     allowing both GeometryReader and Environment to participate in the same view.
//    func trackScrolling() -> some View {
//        let coordinateSpace = UUID()
//        let environmentKey = CaptureScrollingOffset.EnvironmentKey(coordinateSpace: coordinateSpace)
//        
//        return self
//            .coordinateSpace(name: coordinateSpace)
//            .background(
//                GeometryReader { geometry -> Color in
//                    environmentKey.bounds = geometry.frame(in: .local)
//                    return Color.clear
//                }
//            )
//            .environment(\.captureScrollingOffset, environmentKey)
//    }
//    
//}
//
//
//public extension ScrollViewReader {
//    
//    func onScrolled(_ perform: @escaping (UnitPoint) -> Void) -> some View {
//        return ModifiedContent(content: self, modifier: CaptureOffsetViewModifier())
//            .onPreferenceChange(CaptureScrollingOffset.PreferenceKey.self) {
//                var x: CGFloat = $0.content.origin.x
//                var y: CGFloat = $0.content.origin.y
//                
//                if $0.content.width != $0.bounds.width {
//                    x = x / ($0.content.width - $0.bounds.width)
//                }
//                
//                if $0.content.height != $0.bounds.height {
//                    y = y / ($0.content.height - $0.bounds.height)
//                }
//                
//                x = (x * 10000).rounded() / 10000
//                y = (y * 10000).rounded() / 10000
//                
//                x = min(max(x, 0), 1)
//                y = min(max(y, 0), 1)
//                
//                perform(UnitPoint(x: x, y: -y))
//            }
//    }
//}
//
//
//fileprivate struct CaptureOffsetViewModifier: ViewModifier {
//    
//    @Environment(\.captureScrollingOffset) private var captureScrollingOffset
//    
//    func body(content: Content) -> some View {
//        assert(captureScrollingOffset != nil, "Unexpected state, coordinate space not set for tracking offset changes")
//        return captureScrollingOffset == nil ? ViewBuilder.buildEither(first: content) :
//        ViewBuilder.buildEither(second: content.background(
//            GeometryReader { geometry in
//                return Color.clear.preference(key: CaptureScrollingOffset.PreferenceKey.self,
//                                              value: CaptureScrollingOffset.KeyData(bounds: captureScrollingOffset!.bounds, content: geometry.frame(in: .named(captureScrollingOffset!.coordinateSpace))))
//            }
//        ))
//    }
//    
//}
//
//
//fileprivate struct CaptureScrollingOffset {
//    
//    class EnvironmentKey: SwiftUI.EnvironmentKey {
//        let coordinateSpace: AnyHashable
//        var bounds: CGRect
//        
//        static var defaultValue: CaptureScrollingOffset.EnvironmentKey? = nil
//        
//        init(coordinateSpace: AnyHashable, bounds: CGRect = .zero) {
//            self.coordinateSpace = coordinateSpace
//            self.bounds = bounds
//        }
//        
//    }
//    
//    struct KeyData: Equatable {
//        
//        static var `default` = KeyData(bounds: .zero, content: .zero)
//        
//        let bounds: CGRect
//        let content: CGRect
//        
//        static func == (lhs: CaptureScrollingOffset.KeyData, rhs: CaptureScrollingOffset.KeyData) -> Bool {
//            return lhs.bounds == rhs.bounds && lhs.content == rhs.content
//        }
//    }
//    
//    struct PreferenceKey: SwiftUI.PreferenceKey {
//        static var defaultValue: CaptureScrollingOffset.KeyData = .default
//        
//        static func reduce(value: inout CaptureScrollingOffset.KeyData, nextValue: () -> CaptureScrollingOffset.KeyData) {
//        }
//    }
//    
//}
//
//
//fileprivate extension EnvironmentValues {
//    
//    var captureScrollingOffset: CaptureScrollingOffset.EnvironmentKey? {
//        get { self[CaptureScrollingOffset.EnvironmentKey.self] }
//        set { self[CaptureScrollingOffset.EnvironmentKey.self] = newValue }
//    }
//    
//}

