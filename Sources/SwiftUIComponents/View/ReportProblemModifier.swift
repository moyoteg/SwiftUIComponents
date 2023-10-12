//
//  ReportProblemModifier.swift
//
//
//  Created by Moi Gutierrez on 10/11/23.
//

import SwiftUI

import CloudyLogs

public struct ReportProblemModifier: ViewModifier {
    @State private var isShowingReportSheet = false
    @State private var problemDescription = ""
    @State private var isTucked = true
    
    @State private var initialPosition = 0.0
    @State private var offsetY = 0.0
    @State private var isDragging = false

    let reportProblemAction: (String) -> Void
    
    let buttonFrame = 32.0
    
    public init(reportProblemAction: @escaping (String) -> Void) {
        self.reportProblemAction = reportProblemAction
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
                            .resizable()
                            .frame(width: buttonFrame, height: buttonFrame)
                            .rotationEffect(Angle(degrees: isTucked ? 0:180))
                            .opacity(0.3)
                            .shadow(radius: 5)
                            .onTapGesture {
                                withAnimation {
                                    isTucked.toggle()
                                }
                            }
                        button()
                    }
                    .background(.ultraThinMaterial)
                    .cornerRadius(buttonFrame)
                    .offset(x: isTucked ? buttonFrame * 2:0, y: offsetY)
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
            .sheet(isPresented: $isShowingReportSheet) {
                NavigationView {
                    ReportProblemView(isShowingReportSheet: $isShowingReportSheet, problemDescription: $problemDescription, submitAction: {
                        if problemDescription.count == 0 {
                            return
                        }
                        reportProblemAction(problemDescription)
                        isShowingReportSheet = false
                    })
                }
            }
        }
    }
    
    @ViewBuilder
    func button() -> some View {
        Button(action: {
            isShowingReportSheet.toggle()
        }) {
            VStack {
                Image(systemName: "exclamationmark.bubble.circle")
                    .resizable()
                    .frame(width: buttonFrame, height: buttonFrame)
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
    }
}

public struct ReportProblemView: View {
    @Binding var isShowingReportSheet: Bool
    @Binding var problemDescription: String
    let submitAction: () -> Void
    
    @FocusState private var focusedField: FocusedField?
    enum FocusedField {
        case problemDescription
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Text("Report a Problem")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
            
            Text("Describe the problem:")
                .font(.headline)
                .foregroundColor(.gray)

            TextEditor(text: $problemDescription)
                .fontWeight(.bold)
                .frame(height: 200)
                .cornerRadius(8)
                .padding()
                .background(.secondary)
                .focused($focusedField, equals: .problemDescription)
                .onAppear {
                    focusedField = .problemDescription
                }

            Button(action: {
                submitAction()
            }) {
                Text("Submit")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .cornerRadius(8)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarItems(
            leading: Button("Cancel") {
                isShowingReportSheet = false
            }
        )
    }
}
