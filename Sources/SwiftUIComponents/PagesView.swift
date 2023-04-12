//
//  PagesView.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 12/12/20.
//

import SwiftUI
import AVFoundation

#if !os(tvOS)

public struct PagesView<Content: View>: View {

    public enum SelectionDirection {
        case horizontal
        // TODO: implement
        case vertical
    }
    
    @Binding var pageCount: Int
    @Binding var currentIndex: Int
    @Binding var isSelecting: Bool
    @GestureState private var translation: CGFloat = 0
    
    var pageControlColor: Color
    var selectionColor: Color
    var blurRadius: CGFloat
    
    var selectionDirection: SelectionDirection
    let selectionTolerance: CGFloat = 0.1
    let content: Content
    let animationsDuration = 0.3
    
    public var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                HStack(spacing: 8) {
                    self.content
                        .frame(width: geometry.size.width)
                }
                .frame(width: geometry.size.width, alignment: .leading)
                .offset(x: -CGFloat(self.currentIndex) * geometry.size.width)
                .offset(x: self.translation)
                .animation(.easeOut(duration: animationsDuration), value: UUID())
                .gesture(
                    DragGesture()
                        .onChanged({ (value) in
                            
                            // if there is only one page don't enable interaction
                            if pageCount <= 1 { return }
                            
                            // check if translating in "selection direction"
                            switch selectionDirection {
                            case .horizontal:
                                if (percentageOf(width: geometry.size.width,
                                                 startLocation: value.startLocation.x,
                                                 newLocation: value.location.x) >= selectionTolerance) {
                                    withAnimation {
                                        update(selectingState: true)
                                    }
                                    
                                } else {
                                    withAnimation {
                                        update(selectingState: false)
                                    }
                                }
                            case .vertical: break
                            }
                        })
                        .updating(self.$translation) { value, state, _ in
                            
                            // if there is only one page don't enable interaction
                            if pageCount <= 1 { return }
                            
                            state = value.translation.width

                        }.onEnded { value in
                            let offset = value.translation.width / geometry.size.width
                            let newIndex = Int((CGFloat(self.currentIndex) - offset).rounded())
                            withAnimation {
                                self.currentIndex = min(max(newIndex, 0), self.pageCount - 1)
                                DispatchQueue.main
                                    .asyncAfter(deadline: .now() + animationsDuration) {
                                    update(selectingState: false)
                                }
                            }

                        }
                    )
                
                VStack {
                    Spacer()
                    PageControl(currentpage: $currentIndex,
                                pageCount: $pageCount,
                                isSelecting: $isSelecting,
                                pageControlColor: pageControlColor,
                                selectionColor: selectionColor,
                                blurRadius: blurRadius)
                        .scaleEffect(
                            CGSize(width: isSelecting ? 2.0:1.0,
                                   height: isSelecting ? 2.0:1.0)
                        )
                }
                .padding()
            }
        }
    }
    
    public init(pageCount: Binding<Int>,
         currentIndex: Binding<Int>,
         isSelecting: Binding<Bool>,
         selectionDirection: SelectionDirection = .horizontal,
         pageControlColor: Color = .white,
         selectionColor: Color = .blue,
         blurRadius: CGFloat = 20.0,
         @ViewBuilder content: () -> Content) {
        self._pageCount = pageCount
        self._currentIndex = currentIndex
        self._isSelecting = isSelecting
        self.selectionDirection = selectionDirection
        self.content = content()
        self.pageControlColor = pageControlColor
        self.selectionColor = selectionColor
        self.blurRadius = blurRadius
    }
    
    private func update(selectingState: Bool) {
        if selectingState != isSelecting {
            isSelecting = selectingState
            #if !os(watchOS)
            UIImpactFeedbackGenerator().impactOccurred(intensity: .infinity)
            AudioServicesPlaySystemSound(UInt32(1104))
            #endif
        }
    }
    
    private func percentageOf(width: CGFloat,
                                      startLocation: CGFloat,
                                      newLocation: CGFloat) -> CGFloat {
        let percentage = abs(startLocation - newLocation) / width
        return percentage
    }
}
#endif
