//
//  PageControl.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 12/12/20.
//

import SwiftUI

public struct PageControl: View {
    
    @Binding var currentpage: Int
    var pageCount: Int
    @Binding var isSelecting: Bool
    
    var pageControlColor: Color
    var selectionColor: Color
    var blurRadius: CGFloat
    
    var buttonShape: AnyShape
    var buttonColor: (Int) -> Color
    
    var pageControlSize: CGSize = .init(width: 8, height: 8)
    
    public var body: some View {
        
        HStack(spacing: 12) {
            ForEach(0..<pageCount, id: \.self) { row in
                
                Button(action: {
                    print("pressed: \(row)")
                    withAnimation {
                        currentpage = row
                        update(selectingState: true)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            update(selectingState: false)
                        }
                    }
                }) {
                    if (currentpage == row) {
                        buttonShape
                            .fill(selectionColor)
                            .frame(width: pageControlSize.width,
                                   height: pageControlSize.height,
                                   alignment: .center)
                    } else {
                        buttonShape
                            .fill(buttonColor(row).opacity(0.5))
                            .frame(width: pageControlSize.width,
                                   height: pageControlSize.height,
                                   alignment: .center)
                    }
                }
                .transition(.scale(scale: 2.0))
                .disabled(currentpage == row)
            }
        }
        .padding(.all, 4)
        .background(
            Color.white.opacity(0.3)
                .blur(radius: blurRadius)
        )
        .cornerRadius(5)
        .isHidden(pageCount <= 1)
    }
    
    private func update(selectingState: Bool) {
        isSelecting = selectingState
    }
}
