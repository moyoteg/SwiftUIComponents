//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 5/27/23.
//

import SwiftUI

public struct GridLastCellTakesFullWidth<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable & Hashable {
    let data: Data
    let columns: [GridItem]
    let spacing: CGFloat
    let content: (Data.Element) -> Content
    
    public var body: some View {
        ScrollView {
            if data.count % 2 != 0 {
                LazyVGrid(columns: columns, alignment: .center, spacing: spacing) {
                    ForEach(data.dropLast().array ?? [], id: \.self) { item in
                        content(item)
                    }
                }
                LazyVGrid(columns: [GridItem(.flexible())], alignment: .center, spacing: spacing) {
                    ForEach(data.suffix(1).array ?? [], id: \.self) { item in
                        content(item)
                            .frame(maxWidth: .infinity)
                    }
                }
            } else {
                LazyVGrid(columns: columns, alignment: .center, spacing: spacing) {
                    ForEach(data.array ?? [], id: \.self) { item in
                        content(item)
                    }
                }
            }
        }
    }
    
    public init(data: Data, columns: [GridItem], spacing: CGFloat, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.columns = columns
        self.spacing = spacing
        self.content = content
    }
}

// Usage
public struct Example_GridLastCellTakesFullWidth: View {
    
    public struct MyData: Identifiable, Hashable {
        public let id: Int
        public let number: Int
        
        public init(id: Int, number: Int) {
            self.id = id
            self.number = number
        }
    }
    
    let data = Array(1...11).map { MyData(id: $0, number: $0) }
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    public var body: some View {
        GridLastCellTakesFullWidth(data: data, columns: columns, spacing: 8) { item in
            Text("\(item.number)")
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

// Add this to get preview
struct Example_GridLastCellTakesFullWidth_Previews: PreviewProvider {
    static var previews: some View {
        Example_GridLastCellTakesFullWidth()
    }
}
