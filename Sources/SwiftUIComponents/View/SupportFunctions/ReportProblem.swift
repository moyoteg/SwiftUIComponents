//
//  ReportProblem.swift
//
//
//  Created by Moi Gutierrez on 10/14/23.
//

import SwiftUI

public struct ReportProblem: View {
    @Binding var isShowingReportSheet: Bool
    @Binding var problemDescription: String
    let submitAction: () -> Void
    
    @FocusState private var focusedField: FocusedField?
    enum FocusedField {
        case problemDescription
    }
    
    public var body: some View {
        NavigationStack {
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
}
