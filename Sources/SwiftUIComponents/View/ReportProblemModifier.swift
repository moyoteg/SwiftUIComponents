//
//  ReportProblemModifier.swift
//
//
//  Created by Moi Gutierrez on 10/11/23.
//

import SwiftUI

import CloudyLogs
import ExyteChat

public struct ReportProblemModifier: ViewModifier {
    
    public enum SupportFunction: Int, Identifiable, Equatable {
        public var id:Int { self.rawValue }
        
        case reportProblem
        case customerChat
        
        var systemImageName: String {
            switch self {
            case .reportProblem: return "exclamationmark.bubble.fill"
            case .customerChat: return "person.bubble"
            }
        }
        var color: Color {
            switch self {
            case .reportProblem: return .blue
            case .customerChat: return .purple
            }
        }
    }
    
    class ViewModel: ObservableObject {

        @Published var selectedFunction: SupportFunction?
        
        public init() {
        }
    }

    @ObservedObject var viewModel = ViewModel()
    
    @Binding var showSheet: Bool // Use a Binding to control the sheet's visibility
    @State private var problemDescription = ""
    @State private var isTucked = true
    @State private var initialPosition = 0.0
    @State private var offsetY = 0.0
    @State private var isDragging = false
    
    let reportProblemAction: (String) -> Void
    let buttonFrame = 32.0
    
    let functionButtons: [SupportFunction] // Parameter for functionButtons
    
    public init(reportProblemAction: @escaping (String) -> Void, showSheet: Binding<Bool>, functionButtons: [SupportFunction] = [.reportProblem, .customerChat]) {
        self.reportProblemAction = reportProblemAction
        self._showSheet = showSheet // Initialize the Binding
        self.functionButtons = functionButtons // Initialize functionButtons with the provided value or default
    }
    
    public func body(content: Content) -> some View {
        ZStack {
            content
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Group {
                        Image(systemName: "chevron.left.circle")
                            .frame(width: buttonFrame, height: buttonFrame)
                            .rotationEffect(Angle(degrees: isTucked ? 0:180))
                            .opacity(0.3)
                            .shadow(radius: 5)
                            .onTapGesture {
                                withAnimation {
                                    isTucked.toggle()
                                }
                            }
                        HStack {
                            ForEach(functionButtons , id:\.self) { function in
                                functionViewButton(supportFunction: function)
                            }
                        }
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(buttonFrame)
                    .offset(x: isTucked ? buttonFrame * Double(functionButtons.count) + buttonFrame:0, y: offsetY)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                offsetY = initialPosition + gesture.translation.height
                                isDragging = true
                            }
                            .onEnded { _ in
                                initialPosition = offsetY // Store the new position when dragging ends
                                isDragging = false
                            }
                    )
                }
                .padding()
            }
            .sheet(isPresented: $showSheet, content: {
                functionView(supportFunction: viewModel.selectedFunction!)
            })
        }
    }
    
    @ViewBuilder
    func functionViewButton(supportFunction: SupportFunction) -> some View {
        Button(action: {
            viewModel.selectedFunction = supportFunction
            showSheet = true
        }) {
            VStack {
                Image(systemName: supportFunction.systemImageName)
                    .frame(width: buttonFrame, height: buttonFrame)
                    .foregroundColor(supportFunction.color)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
    }
    
    @ViewBuilder
    func functionView(supportFunction: SupportFunction) -> some View {
        switch supportFunction {
        case .reportProblem:
            ReportProblem(isShowingReportSheet: $showSheet, problemDescription: $problemDescription, submitAction: {
                if problemDescription.count == 0 {
                    return
                }
                reportProblemAction(problemDescription)
                showSheet = false // Close the sheet
            })
            .addDragIndicator()
        case .customerChat:
            let user = ExyteChat.User(id: "userID12345", name: "John Doe", avatarURL: nil, isCurrentUser: false)
            
            ChatView(chatRoomId: UUID().uuidString)
                .addDragIndicator()
        }
    }
}
