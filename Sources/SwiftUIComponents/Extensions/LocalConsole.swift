//
//  LocalConsole.swift
//  
//
//  Created by Moi Gutierrez on 10/4/22.
//

import SwiftUI

import CloudyLogs

public extension View {
    
    func localAlert(presented: Binding<Bool>, text: String, placement: LocalAlert.Placement = .top) -> some View {
        self.modifier(LocalAlert(presented: presented, text: text, placement: placement))
    }
}


public struct LocalAlert: ViewModifier {
    
    public enum Placement {
        case top
        case bottom
    }
    
    @Binding var presented: Bool
    
    var text: String

    var placement: LocalAlert.Placement

    public func body(content: Content) -> some View {
        
        ZStack {
            
            content
            
            if presented {
                
                VStack {
                    
                    if placement == .bottom {
                        Spacer()
                    }
                    
                    GeometryReader { geometry in
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 10)
                                .padding()
                                .zIndex(0)
                            
                            ScrollView {
                                VStack {
                                    HStack {
                                        Text(text)
                                            .padding()
                                            .foregroundColor(.black)
                                    }
                                }
                            }
                                
                        }
                        .frame(height: geometry.size.height / 8)
                        .opacity(0.9)
                        .onTapGesture {
                            
                            withAnimation(.easeInOut) {
                                presented = false
                            }
                        }
                    }
                    .transition(.move(edge: .top))
                    
                    if placement == .top {
                        Spacer()
                    }
                }
            }
        }
    }
}

public extension View {
    
    func localConsole(presented: Bool) -> some View {
        self.modifier(LocalConsole(presented: presented))
    }
}


struct LocalConsole: ViewModifier {
    
    var presented: Bool
        
    @State private var location: CGPoint = CGPoint(x: 50, y: 50)
    
    @GestureState private var startLocation: CGPoint? = nil // 1
    
    var longPress: some Gesture {
        LongPressGesture(minimumDuration: 5.0)
        
            .updating($isDetectingLongPress) { currentState, gestureState, transaction in
                gestureState = currentState
            }
            .onChanged({ value in
                withAnimation {
//                    allowDragging = true
                }
            })
            .onEnded { value in
                withAnimation {
//                    allowDragging = false
                }
            }
    }
    
    @GestureState var isDetectingDrag = false

    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? location // 3
                newLocation.x += value.translation.width
                newLocation.y += value.translation.height
                self.location = newLocation
                
                withAnimation {
                    isMoving = true
                }
                
            }.updating($startLocation) { (value, startLocation, transaction) in
                startLocation = startLocation ?? location // 2
            }
            .onEnded { value in
                withAnimation {
                    isMoving = false
                }
            }
    }
    
    var magnification: some Gesture {
        MagnificationGesture()
            .onChanged { amount in
                
                magnificationCurrentAmount = amount - 1
                
            }
            .onEnded { amount in
                
                if amount > minMagnificationAmount {
                    
                    magnificationFinalAmount += magnificationCurrentAmount
                    magnificationCurrentAmount = 0
                }
                
                withAnimation {
                    isMoving = false
                }
            }
    }
    
//    var resize: some Gesture {
//        DragGesture()
//
//            .onChanged { value in
//
//                if width + value.location.x >= minWidth {
//                    //                                            width += value.translation.width
//                    width = width + value.location.x
//                }
//
//                if height + value.location.y >= minHeight {
//                    //                                            height += value.translation.height
//                    height = height + value.location.y
//                }
//
//                withAnimation {
//                    //
//                    //                                        if width >= minWidth {
//                    //                                            //                                            width += value.translation.width
//                    //                                            width = width + value.location.x
//                    //                                        }
//                    //
//                    //                                        if height >= minHeight {
//                    //                                            //                                            height += value.translation.height
//                    //                                            height = height + value.location.y
//                    //                                        }
//                    //
//                    isMoving = true
//                }
//            }
//            .onEnded { _ in
//                withAnimation {
//                    isMoving = false
//                }
//            }
//    }
    
    // frame
    let scaling = 0.5
    var minWidth:CGFloat { 176.0 / scaling }
    var minHeight:CGFloat { 88.0 / scaling }
    @State private var width = 10.0
    @State private var height = 10.0
    let shrinkMultiplier = 0.8
    
    // isMoving
    @State private var isMoving = false {
        didSet {
//            opacity = isMoving ? movingMinOpacity:1.0
        }
    }
    let movingMinOpacity = 0.3
    
    @State private var allowDragging = false
    
    @State private var isHidden = false
    @State var opacity: Double = 1.0
    
    @GestureState var isDetectingLongPress = false
    
    //
    @State private var magnificationCurrentAmount = 0.0
    @State private var magnificationFinalAmount = 1.0
    let minMagnificationAmount = 0.4
    
    enum Filters: String, CaseIterable {
        case error
        case info
        case warning
    }
    
    @State var filterText: String = ""
    
    @State var showAlert: Bool = false
    
    public init(presented: Bool) {
        self.presented = presented
    }
    
    public func body(content: Content) -> some View {
        
        ZStack {
            
            content
                .localAlert(presented: $showAlert.animation(), text: " test  test  test  test  test  test  test  test  test  test ")
            
            if presented {
                
                GeometryReader { geometry in
                    
                    ZStack {
                        
                        Group {
                            
                            Rectangle()
//                                .fill(allowDragging ? isMoving ? .purple:.blue :.green)
                                .fill(.green)
//                                .opacity(isMoving ? 0.1:0.25)
//                                .fill(allowDragging ? isMoving ? .purple:.green :.blue)
                                .shadow(color: allowDragging ? .white:.blue, radius: allowDragging ? 40:5)
                            
                            Rectangle()
                                .blur(radius: 20)

                        }
                        .opacity(isHidden ? 0.0:1.0)
                        .opacity(isMoving ? 0.1:0.25)
                        .cornerRadius(25)

                        NavigationView {

                            FilteredList(
                                list: Logger.orderedLogs,
                                filterText: $filterText) { (string) in

                                    Text("\(string)")
                                        .font(.system(size: 8))
                                }

                                .listStyle(GroupedListStyle())
                                .navigationViewStyle(StackNavigationViewStyle())
                                .navigationBarHidden(true)
                                .cornerRadius(25)
                        }
                        .padding()
                        .minimumScaleFactor(0.2)
                        .opacity(isHidden ? 0.0:1.0)
                        .cornerRadius(25)
                        
                        buttons()
                            .shadow(radius: 15)
                        
                    }
                    .position(location)
                    .frame(width: width, height: height)
                    .onAppear {
                        width = max(geometry.size.width * 0.9, minWidth)
                        height = max(geometry.size.height * 0.9 / 3, minHeight)
                        location = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                    }
                    .scaleEffect(magnificationFinalAmount + magnificationCurrentAmount)
                    .opacity(opacity)
                }
//                .gesture(magnification)
                .simultaneousGesture(drag)

            }
        }
        
    }
    
    @ViewBuilder
    func buttons() -> some View {
        
        HStack {
            
            Spacer()
            
            VStack {
                
                Spacer()
                
                Menu {
                    
                    Button {
                        withAnimation {
                            isHidden.toggle()
                        }
                    } label: {
                        Text("\(isHidden ? "un-hide":"hide")")
                        URLImage(systemName: isHidden ? "eye.slash": "eye")
                    }
                    
                    Menu("filters") {
                        
//                        Filters.allCases.forEach { filter in
//                            Button {
//                                withAnimation {
//                                    isHidden.toggle()
//                                }
//                            } label: {
//                                Text("\(isHidden ? "un-hide":"hide")")
//                                URLImage(systemName: isHidden ? "eye.slash": "eye")
//                            }
//                        }
                        
                        Button {
                            filterText = Logger.LogType.error.rawValue
                        } label: {
                            Text("\(Logger.LogType.error.rawValue)")
                        }
                        
                        Button {
                            filterText = Logger.LogType.warning.rawValue
                        } label: {
                            Text("\(Logger.LogType.warning.rawValue)")
                        }
                        
                        Button {
                            filterText = Logger.LogType.success.rawValue
                        } label: {
                            Text("\(Logger.LogType.success.rawValue)")
                        }
                    }
                    
                    Menu("Transparency") {
                        
                        Button {
                            opacity = 1.0
                        } label: {
                            Text("100%")
                            URLImage(systemName: "cube.transparent.fill")
                        }
                        
                        Button {
                            opacity = 0.5
                        } label: {
                            Text("50%")
                            URLImage(systemName: "cube.transparent")
                        }
                    }

                    Button {
                        withAnimation(.easeInOut) {
                            showAlert.toggle()
                        }
                    } label: {
                        Text("show alert")
                        Text("\(showAlert.description)")
                    }

                    Button {
                        withAnimation(.easeInOut) {
                            width = minWidth
                            height = minHeight
                            location = CGPoint(x: 0, y: 0)
                        }
                    } label: {
                        Text("reset")
                        Text("\(showAlert.description)")
                    }
                    
                    
                } label: {
                    URLImage(systemName: "ellipsis.circle.fill")
                }
                
            }
        }
        .foregroundColor(.blue)
        .simultaneousGesture(drag)
    }
}
