//
//  ReportProblemModifier.swift
//
//
//  Created by Moi Gutierrez on 10/11/23.
//

import SwiftUI

public struct ReportProblemModifier: ViewModifier {
    @State private var isShowingReportSheet = false
    @State private var problemDescription = ""
    
    let reportProblemAction: (String) -> Void
    
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
                    button()
                }
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
                    .frame(width: 22, height: 22)
                    .foregroundColor(.blue)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
        }
        .padding(8)
    }
}

public struct ReportProblemView: View {
    @Binding var isShowingReportSheet: Bool
    @Binding var problemDescription: String
    let submitAction: () -> Void
    
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
