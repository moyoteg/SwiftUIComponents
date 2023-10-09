//
//  MirrorView.swift
//  
//
//  Created by Moi Gutierrez on 10/3/23.
//

import SwiftUI

import CloudyLogs
import SwiftUI

public struct MirrorView: View {
    
    let typeToView: Any
    
    struct Child: Identifiable, Hashable, Equatable {
        
        static func == (lhs: MirrorView.Child,
                        rhs: MirrorView.Child) -> Bool {
            lhs.hashValue == rhs.hashValue
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        var id = UUID().uuidString
        var label: String
        var value: Any
    }
    
    public var body: some View {
        let mirror = Swift.Mirror(reflecting: typeToView)
        let children = mirror.children.compactMap { (label, value) -> Child? in
            return Child(label: label ?? "no label", value: value)
        }
        
        switch mirror.displayStyle {
            // TODO: handle
            // case .class:
            
        default:
            
            List {
                Section(header: Text("Children")) {
                    ForEach(children, id: \.self) { child in
                        NavigationLink(destination: MirrorView(typeToView: child.value)) {
                            HStack {
                                Text(child.label)
                                    .font(.headline)
                                Spacer()
                                Text("\(String(describing: child.value))")
                                    .font(.body)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Button("Copy", action: {
                                            UIPasteboard.general.string = "\(child.value)"
                                        })
                                    }))
                            }
                        }
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("\(String(describing: mirror.subjectType))", displayMode: .inline)
        }
    }
    
    public init(typeToView: Any) {
        self.typeToView = typeToView
    }
}

struct Struct_Previews: PreviewProvider {
    
    struct Test {
        var test: String
        var another: Int
    }
    
    static var previews: some View {
        MirrorView(typeToView: Test(test: "test", another: 0))
    }
}
