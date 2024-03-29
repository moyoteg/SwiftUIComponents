//
//  ViewExtensions.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 2/8/21.
//

import SwiftUI

public extension View {
    func reportProblemAction(showSheet: Binding<Bool>, reportProblemAction: @escaping (String, UIImage?) -> Void) -> some View {
        self.modifier(ReportProblemModifier(reportProblemAction: reportProblemAction, showSheet: showSheet))
    }
}

public struct ConnectionOverlayModifier: ViewModifier {
    @Binding var isConnected: Bool
    @State private var isOverlayVisible: Bool = true
    
    public func body(content: Content) -> some View {
        ZStack {
            
            content
                .disabled(!isConnected)
                .opacity(isConnected ? 1:0.5)
            
            if !isConnected {
                // Semi-transparent background
                Color.white.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .background(.ultraThinMaterial)
            }
            
            if !isConnected && !isOverlayVisible {
            
                Image(systemName: "wifi.slash")
                    .foregroundColor(.primary)
                    .font(.headline)
                    .padding()
            }
            
            if !isConnected && isOverlayVisible {
                
                // Connection status text
                HStack {
                    
                    Image(systemName: "wifi.slash")
                        .foregroundColor(.white)

                    Text("No internet connection!")
                        .foregroundColor(.white)
                    
                    Image(systemName: "x.circle.fill")
                        .foregroundColor(.white)
                }
                .padding()
                .font(.headline)
                .background(Color.red)
                .cornerRadius(8)
                .shadow(radius: 5)
                .transition(.opacity)
                .animation(.easeInOut, value: UUID())
                .onTapGesture {
                    withAnimation {
                        isOverlayVisible = false
                    }
                }
            }
        }
        .onChange(of: isConnected) { newValue in
            withAnimation {
                isOverlayVisible = !newValue
            }
        }
    }
}

public extension View {
    func connectionOverlay(isConnected: Binding<Bool>) -> some View {
        self.modifier(ConnectionOverlayModifier(isConnected: isConnected))
    }
}

public extension Image {
    func resizableIf(_ condition: Bool) -> Self {
        if condition {
            return resizable()
        } else {
            return self
        }
    }
}

public extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

public extension View {
    func configure(_ configuration: @escaping (Self) -> Void) -> Self {
        configuration(self)
        return self
    }
}

public extension View {
    func rainbowAnimation() -> some View {
        self.modifier(RainbowAnimation())
    }
}

public struct RainbowAnimation: ViewModifier {
    // 1
    @State private var isOn: Bool = false
    let hueColors = stride(from: 0, to: 1, by: 0.01).map {
        Color(hue: $0, saturation: 1, brightness: 1)
    }
    // 2
    var duration: Double = 4
    var animation: Animation {
        Animation
            .linear(duration: duration)
            .repeatForever(autoreverses: false)
    }
    
    public func body(content: Content) -> some View {
        // 3
        let gradient = LinearGradient(gradient: Gradient(colors: hueColors+hueColors), startPoint: .leading, endPoint: .trailing)
        return content.overlay(GeometryReader { proxy in
            ZStack {
                gradient
                    // 4
                    .frame(width: 2*proxy.size.width)
                    // 5
                    .offset(x: self.isOn ? -proxy.size.width/2 : proxy.size.width/2)
            }
        })
        // 6
        .onAppear {
            withAnimation(self.animation) {
                self.isOn = true
            }
        }
        .mask(content)
    }
}

public struct FadeModifier: AnimatableModifier {
    // To trigger the animation as well as to hold its final state
    private let control: Bool
    
    // SwiftUI gradually varies it from old value to the new value
    public var animatableData: Double = 0.0
    
    // Re-created every time the control argument changes
    public init(control: Bool) {
        // Set control to the new value
        self.control = control
        
        // Set animatableData to the new value. But SwiftUI again directly
        // and gradually varies it from 0 to 1 or 1 to 0, while the body
        // is being called to animate. Following line serves the purpose of
        // associating the extenal control argument with the animatableData.
        self.animatableData = control ? 1.0 : 0.0
    }
    
    // Called after each gradual change in animatableData to allow the
    // modifier to animate
    public func body(content: Content) -> some View {
        // content is the view on which .modifier is applied
        content
            // Map each "0 to 1" and "1 to 0" change to a "0 to 1" change
            .opacity(control ? animatableData : 1.0 - animatableData)
            
            // This modifier is animating the opacity by gradually setting
            // incremental values. We don't want the system also to
            // implicitly animate it each time we set it. It will also cancel
            // out other implicit animations now present on the content.
            .animation(.easeIn, value: 0.3)
    }
}

public extension View {
    
    func animatableFont(name: String, size: CGFloat) -> some View {
        self.modifier(AnimatableCustomFontModifier(name: name, size: size))
    }
}

public struct AnimatableCustomFontModifier: AnimatableModifier {
    
    var name: String
    var size: CGFloat
    
    public var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }
    
    public func body(content: Content) -> some View {
        content
            .font(.custom(name, size: size))
    }
}

// MARK: - AnimatableSystemFontModifier

public extension View {
    func animatableSystemFont(size: CGFloat, weight: Font.Weight = .regular, design: Font.Design = .default) -> some View {
        self.modifier(AnimatableSystemFontModifier(size: size, weight: weight, design: design))
    }
}

public struct AnimatableSystemFontModifier: AnimatableModifier {
    public var size: CGFloat
    public var weight: Font.Weight
    public var design: Font.Design
    
    public var animatableData: CGFloat {
        get { size }
        set { size = newValue }
    }
    
    public func body(content: Content) -> some View {
        content
            .font(.system(size: size, weight: weight, design: design))
    }
}

public extension View {
    
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}

public extension View {
    func animate(using animation: Animation = Animation.easeInOut(duration: 1), _ action: @escaping () -> Void) -> some View {
        return onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}

public extension View {
    func animateForever(using animation: Animation = Animation.easeInOut(duration: 1), autoreverses: Bool = false, _ action: @escaping () -> Void) -> some View {
        let repeated = animation.repeatForever(autoreverses: autoreverses)
        
        return onAppear {
            withAnimation(repeated) {
                action()
            }
        }
    }
}


public struct PopUp<PopUpContent: View>: ViewModifier {
    
    @Binding private var isPresented: Bool
    let popUpContent: () -> PopUpContent
    let onDismiss: (() -> Void)?
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented {
                popUpContent()
                    .onDisappear {
                        onDismiss?()
                    }
                    .padding()
                    .background(
                        Rectangle()
                            .fill(Color.white)
                            .cornerRadius(15)
                        
                        , alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                    .transition(.scale)
                    .shadow(radius: 10)
            }
        }
        
    }
    
    public init(isPresented: Binding<Bool>,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder popUpContent: @escaping () -> PopUpContent) {
        self._isPresented = isPresented
        self.onDismiss = onDismiss
        self.popUpContent = popUpContent
    }
}

public extension View {
    
    func popUp<Content>(isPresented: Binding<Bool>,
                        onDismiss: (() -> Void)? = nil,
                        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content : View {
        self.modifier(PopUp(isPresented: isPresented, onDismiss: onDismiss, popUpContent: content))
    }
}

public struct Reflection: ViewModifier {
    
    var direction: ReflectDirection
    var rotation: Angle {
        .degrees(180)
    }
    var gradientColors:[Color] {
        [.clear, Color.white.opacity(0.1)]
    }
    
    var startPoint: UnitPoint {
        switch direction {
        case .top: return .bottom
        case .bottom: return .top
        case .leading: return .trailing
        case .trailing: return .leading
        }
    }
    var endPoint: UnitPoint {
        switch direction {
        case .top: return .top
        case .bottom: return .bottom
        case .leading: return .leading
        case .trailing: return .trailing
        }
    }
    
    var rotationAlongY: CGFloat {
        switch direction {
        case .top: return 0
        case .bottom: return 0
        case .leading: return 1
        case .trailing: return 1
        }
    }
    
    var rotationAlongX: CGFloat {
        switch direction {
        case .top: return 1
        case .bottom: return 1
        case .leading: return 0
        case .trailing: return 0
        }
    }
    
    public func body(content: Content) -> some View {
            ZStack {
                // reflection
                GeometryReader { geometry in
                content
                    .mask(
                        LinearGradient(
                            gradient:  Gradient(colors: gradientColors),
                            startPoint: startPoint,
                            endPoint: endPoint)
                    )
                    .rotation3DEffect(rotation, axis: (x: rotationAlongX, y: rotationAlongY, z: 0))
                    .offset(getOffset(geometry: geometry))
            }
                // original content
                content
        }
    }
    
    func getOffset(geometry: GeometryProxy) -> CGSize {
        switch direction {
        case .bottom: return CGSize(width: 0, height: geometry.size.height)
        case .top: return CGSize(width: 0, height: -geometry.size.height)
        case .leading: return CGSize(width: -geometry.size.width, height: 0)
        case .trailing: return CGSize(width: geometry.size.width, height: 0)
        }
    }
}

public enum ReflectDirection: CaseIterable {
    case bottom
    case top
    case leading
    case trailing
    
    public mutating func next() {
        let a = type(of: self).allCases
        self = a[(a.firstIndex(of: self)! + 1) % a.count]
    }

    public func next() -> ReflectDirection {
        let a = type(of: self).allCases
        return a[(a.firstIndex(of: self)! + 1) % a.count]
    }
}

public extension View {
    
    func reflect(direction: ReflectDirection = .top) -> some View {
        self.modifier(Reflection(direction: direction))
    }
}

public extension View {
    
    @inlinable func reverseMask<Mask: View>(
        alignment: Alignment = .center,
        @ViewBuilder _ mask: () -> Mask
    ) -> some View {
        self.mask(
            ZStack {
                Rectangle()
                
                mask()
                    .blendMode(.destinationOut)
            }
        )
    }
}

// MARK: - LiquidHydrogen

public extension View {
    func liquidHydrogenAnimation() -> some View {
        self.modifier(LiquidHydrogenAnimation())
    }
}

public struct LiquidHydrogenAnimation: ViewModifier {
    
    @State private var isOn: Bool = false
    
    var rotationClockwise: Bool {
        return Bool.random()
    }
    
    let colorGradient = AngularGradient(gradient: Color.hydrogenGradient(), center: .center)
    
    var duration: Double = Double.random(min: 4.0, max: 5.0)
    var animation: Animation {
        Animation
            .linear(duration: duration)
            .repeatForever(autoreverses: false)
    }
    
    public func body(content: Content) -> some View {
        
        let gradient = colorGradient
        
        return content.overlay(
            
            GeometryReader { proxy in
                
                Circle()
                    .fill(gradient)
                    .opacity(0.9)
                    .frame(width: max(proxy.size.width, proxy.size.height) * 1.2,
                           height: max(proxy.size.width, proxy.size.height) * 1.2)
                    .rotationEffect(.degrees(isOn ? (rotationClockwise ? 1 : -1) * 360 : 0))
                    .offset(x: 0,
                            y: -proxy.size.height * 8)
                
            }, alignment: .center)
            .onAppear {
                withAnimation(self.animation) {
                    self.isOn = true
                }
            }
            .mask(content)
    }
}

// MARK: - Hydrogen

public extension View {
    func hydrogenAnimation() -> some View {
        self.modifier(HydrogenAnimation())
    }
}

public struct HydrogenAnimation: ViewModifier {
    
    @State private var isOn: Bool = false
    
    @State private var rotationClockwise: Bool = Bool.random()
    
    @State private var duration: Double = Double.random(min: 6.0, max: 10.0)
    var animation: Animation {
        Animation
            .linear(duration: duration)
            .repeatForever(autoreverses: false)
    }
    
    @State private var center = [UnitPoint.top, .bottom, .leading, .trailing].randomElement()!
    
    public func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        Color.hydrogenViewBackgroundGradient()
                    )
                    .scaledToFill()
                    .rotationEffect(.degrees(isOn ? (rotationClockwise ? 1 : -1) * 360 : 0))
                    .onAppear {
                        withAnimation(self.animation) {
                            self.isOn = true
                        }
                    }
                    .opacity(0.9)
                    .mask(content)
            )
            .shadow(color: Color.lightBlue, radius: 10)
    }
}

// MARK: - Rainbow

public extension View {
    func rainbow() -> some View {
        self.modifier(Rainbow())
    }
}

public struct Rainbow: ViewModifier {
    let hueColors = stride(from: 0, to: 1, by: 0.01).map {
        Color(hue: $0, saturation: 1, brightness: 1)
    }
    
    public func body(content: Content) -> some View {
        content
            .overlay(GeometryReader { (proxy: GeometryProxy) in
                ZStack {
                    LinearGradient(gradient: Gradient(colors: self.hueColors),
                                   startPoint: .leading,
                                   endPoint: .trailing)
                        .frame(width: proxy.size.width)
                }
            })
            .mask(content)
    }
}

/// Components

#if !os(watchOS)
public struct BlurrView: UIViewRepresentable {

    var style: UIBlurEffect.Style
    
    public init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        return view
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}
#endif

public extension View {
    
    func interactionLocation(presented: Bool) -> some View {
        self.modifier(Modifier.InteractionLocation(presented: presented))
    }
}

public extension Modifier {
    
    struct InteractionLocation: ViewModifier {
        
        var presented: Bool
                
        @GestureState private var fingerLocation: CGPoint? = nil
        
        var fingerDrag: some Gesture {
            DragGesture()
                .updating($fingerLocation) { (value, fingerLocation, transaction) in
                    fingerLocation = value.location
                }
        }
        
        public func body(content: Content) -> some View {
            ZStack {
                
                content
                
                if let fingerLocation = fingerLocation {
                    ZStack {
                     
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: .init(colors: [.green.opacity(0.2), .green.opacity(0.5)]),
                                      startPoint: .init(x: 0.5, y: 0),
                                      endPoint: .init(x: 0.5, y: 0.6)
                                    )
                                , lineWidth: 8)
                            .frame(width: 88, height: 88)
                        
                        Circle()
                            .stroke(
                                LinearGradient(
                                    gradient: .init(colors: [.red.opacity(0.9), .red.opacity(0.5)]),
                                      startPoint: .init(x: 0.5, y: 0),
                                      endPoint: .init(x: 0.5, y: 0.6)
                                    )
                                , lineWidth: 2)
                            .frame(width: 8, height: 8)
                    }
                        .position(fingerLocation)
                        .isHidden(!presented)
                }
            }
            .simultaneousGesture(fingerDrag)
        }
    }
}

public struct NavigationConfigurator: UIViewControllerRepresentable {
    public var configure: (UINavigationController) -> Void = { _ in }
    
    public func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
        UIViewController()
    }
    
    public func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
        if let nc = uiViewController.navigationController {
            self.configure(nc)
        }
    }
    
}

public struct ListSeparatorStyle: ViewModifier {
    
    let style: UITableViewCell.SeparatorStyle
    
    public func body(content: Content) -> some View {
        content
            .introspectTableView { tableView in
                tableView.separatorStyle = .none
            }
    }
}

public extension View {
    
    func listSeparator(style: UITableViewCell.SeparatorStyle) -> some View {
        ModifiedContent(content: self, modifier: ListSeparatorStyle(style: style))
    }
}

/// Custom vertical scroll view with centered content vertically
///
public struct VScrollView<Content>: View where Content: View {
    var showsIndicators: Bool
    @ViewBuilder let content: Content
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical, showsIndicators: showsIndicators) {
                content
                    .frame(width: geometry.size.width)
                    .frame(minHeight: geometry.size.height)
            }
        }
    }
    
    public init(showsIndicators: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.showsIndicators = showsIndicators
        self.content = content()
    }
}

// Mark: - Overlay Gradient Focus

public struct OverlayGradientFocusModifier: ViewModifier {
    public enum FocusPosition {
        case top, center, bottom
    }
    
    public var position: FocusPosition
    public var gradientColor: Color
    
    public init(position: FocusPosition, gradientColor: Color = .black) {
        self.position = position
        self.gradientColor = gradientColor
    }
    
    public func body(content: Content) -> some View {
        content.overlay(
            LinearGradient(
                gradient: Gradient(colors:[
                    gradientColor.opacity(position == .top ? 0:0.75),
                    gradientColor.opacity(position == .center ? 0:0.75),
                    gradientColor.opacity(position == .bottom ? 0:0.75),
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

public extension View {
    func overlayGradientFocus(position: OverlayGradientFocusModifier.FocusPosition, gradientColor: Color = .black) -> some View {
        self.modifier(OverlayGradientFocusModifier(position: position, gradientColor: gradientColor))
    }
}

public extension View {
    func glow(color: Color = .red, radius: CGFloat = 20) -> some View {
        self
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}

public extension View {
    func multicolorGlow() -> some View {
        ZStack {
            ForEach(0..<2) { i in
                Rectangle()
                    .fill(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center))
                    .frame(width: 400, height: 300)
                    .mask(self.blur(radius: 20))
                    .overlay(self.blur(radius: 5 - CGFloat(i * 5)))
            }
        }
    }
}

public extension View {
    func innerShadow<S: Shape>(using shape: S, angle: Angle = .degrees(0), color: Color = .black, width: CGFloat = 6, blur: CGFloat = 6) -> some View {
        return self
    }
}

public struct AnimatedImageViewModifier: ViewModifier {
    let imageName: String
    let duration: Double
    
    @State private var offset: CGFloat = 0
    
    public func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { proxy in
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: proxy.size.width)
                        .offset(y: -offset)
                        .animation(
                            Animation.easeInOut(duration: duration)
                                .repeatForever(autoreverses: true)
                            , value: UUID()
                        )
                        .onAppear {
                            offset = proxy.size.height
                        }
                }
            )
    }
}

public extension View {
    func animatedImage(imageName: String, duration: Double = 1.0) -> some View {
        self.modifier(AnimatedImageViewModifier(imageName: imageName, duration: duration))
    }
}

// 
public struct CircularMaskWithProgress: ViewModifier {
    @State private var progress: CGFloat = 0.0
    
    public func body(content: Content) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: progress)
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 2.0), value: UUID())
                .onAppear() {
                    progress = 1.0
                }
            content.mask(Circle())
        }
    }
}

public extension View {
    func circularMaskWithProgress() -> some View {
        modifier(CircularMaskWithProgress())
    }
}

/// This is the old (iOS 13) version.
/// This has a "bug" where adding a second finger freezes the touch event.
/// However, according to Apple, this "bug" is intended.
/// In the new iOS 14 version, we use GestureState instead, which gets around this "bug"
/// Forums post (with Apple reply): https://developer.apple.com/forums/thread/660070
/// New iOS 14 version: https://gist.github.com/aheze/3d5820c03616d25e21376ad561798e9e
/// if you're on iPad Swift Playgrounds and you put all of this code in a seperate file,
/// you need to make everything public so that the compiler detects it.
/// the possible states of the button
public enum ButtonState {
    case pressed
    case notPressed
}

/// ViewModifier allows us to get a view, then modify it and return it
@available(iOS 13.0, *)
public struct TouchDownUpEventModifier: ViewModifier {
    
    /// Later, .onChanged will be called multiple times (around 10 times a second once your finger touches down)
    /// so we need a variable to keep track of the first time your finger touches down...
    /// ... we then set this to false when your finger lifts up, so the cycle can repeat again
    @State private var pressed = false
    
    /// this is the closure that will get passed around.
    /// we will update the ButtonState every time your finger touches down or up.
    let changeState: (ButtonState) -> Void
    
    /// a required function for ViewModifier.
    /// content is the body content of the caller view
    public func body(content: Content) -> some View {
        
        /// prepare to add the gesture to the the body content
        content
        
        /// we need to detect both .onChanged and .onEnded
        /// so we modify the original content by adding a gesture to it
            .gesture(DragGesture(minimumDistance: 0)
                     
                     /// equivalent to UIKit's Touch Down event, but is called continuously once your finger moves while still on the screen.
                     /// It will be called a lot, so we need a bool to make sure we change the state only when your finger first touches down
                .onChanged { _ in
                    
                    /// this will make sure that we only pass the new state one time
                    if !self.pressed {
                        
                        /// we lock the state to "pressed" so that it won't be set continuously by .onChanged. We will enable it to be changed once the user lifts their finger.
                        self.pressed = true
                        
                        /// pass the new state to the caller
                        self.changeState(ButtonState.pressed)
                    }
                }
                     
                     
                     /// equivalent to both UIKit's Touch Up Inside and Touch Up Outside event
                .onEnded { _ in
                    
                    /// we enable "pressed" to be changed now to allow another cycle of finger down/up events.
                    self.pressed = false
                    
                    /// pass the new state to the caller
                    self.changeState(ButtonState.notPressed)
                }
            )
    }
    
    /// if you're on iPad Swift Playgrounds and you put all of this code in a seperate file,
    /// you need to add a public init so that the compiler detects it.
    public init(changeState: @escaping (ButtonState) -> Void) {
        self.changeState = changeState
    }
}


/// we can make the modifier more Swifter by wrapping it in a method...
/// ... then making the method an extension of View, so we can easily add it to any SwiftUI view
public extension View {
    func onTouchDownUpEvent(changeState: @escaping (ButtonState) -> Void) -> some View {
        modifier(TouchDownUpEventModifier(changeState: changeState))
    }
}

// See `View.onChange(of: value, perform: action)` for more information
struct ChangeObserver<Base: View, Value: Equatable>: View {
    let base: Base
    let value: Value
    let action: (Value)->Void
    
    let model = Model()
    
    var body: some View {
        if model.update(value: value) {
            DispatchQueue.main.async { self.action(self.value) }
        }
        return base
    }
    
    class Model {
        private var savedValue: Value?
        func update(value: Value) -> Bool {
            guard value != savedValue else { return false }
            savedValue = value
            return true
        }
    }
}
