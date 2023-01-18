//
//  FilteredList.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 1/21/21.
//  Copyright © 2021 PragCore. All rights reserved.
//

import Foundation
import SwiftUI

public protocol StringFilterable: CustomStringConvertible, Hashable {
    var filter: String { get }
}

extension String: StringFilterable {
    public var filter: String {
        self
    }
}

public struct FilteredList<Element: StringFilterable,
                           Content: View>: View {
    
    let title: String?
    let list: [Element]
    @Binding private var bindingFilterText:String
    
    @State private var filterText: String = ""
    
    private var filteredList: [Element] {
        
        if filterText.isEmpty {
            return list
        } else {
            return list.filter{
                $0.filter
                    .lowercased()
                    .contains(filterText.lowercased())
            }
            .sorted {
                $0.description < $1.description
            }
        }
    }
    var content: (Element) -> Content
    var onDelete: (((IndexSet) -> Void)?)
    @State private var selection = Set<Element>()
    
    public var body: some View {
        
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                Text("(\(filterText.isEmpty ? "\(list.count)":"\(filteredList.count)"))")
                    .font(.system(.caption))
                TextField("filter", text: $filterText.animation(.spring()))
                    .padding([.top, .bottom], 8)
                    .modifier(Modifier.ClearButton(text: $filterText))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
            .onChange(of: filterText, perform: { text in
                self.filterText = text
            })
            .onChange(of: bindingFilterText, perform: { text in
                self.filterText = bindingFilterText
            })
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 2)
            .background(
                Color.gray.opacity(0.2)
                    .cornerRadius(10)
                    .padding([.leading, .trailing], 8)
            )
            
            Divider()
                .frame(height: 2)
            
            #if !os(watchOS)
            List(selection: $selection) {
                if filteredList.isEmpty {
                    HStack {
                        Spacer()
                        Text("Nothing to show")
                        Spacer()
                    }
                } else {
                    ForEach(filteredList,
                            id:\.self.filter) { element in
                        content(element)
                    }
                    .onDelete(perform: onDelete)
                }
            }
            .navigationBarTitle(title ?? "")
            #elseif os(watchOS)
            List {
                if filteredList.isEmpty {
                    Text("Nothing to show")
                } else {
                    ForEach(filteredList,
                            id:\.self.filter) { element in
                        content(element)
                    }
                    .onDelete(perform: onDelete)
                }
            }
            .navigationBarTitle(title ?? "")
            #endif
        }
    }
    
    public init(_ title: String = "",
                list: [Element],
                selection: Set<Element> = Set<Element>(),
                filterText: Binding<String> = .constant(""),
                @ViewBuilder content: @escaping (Element) -> Content) {
        self.title = title
        self.list = list
        self.content = content
        self.selection = selection
        self._bindingFilterText = filterText
    }
}

extension FilteredList {
    
    public func onDelete(offsets: @escaping (IndexSet) -> Void ) -> Self {
        var copy = self
        copy.onDelete = offsets
        return copy
    }
}
