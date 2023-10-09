//
//  CustomOperator.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 1/13/21.
//

import SwiftUI

public prefix func ! (value: Binding<Bool>) -> Binding<Bool> {
    Binding<Bool>(
        get: { !value.wrappedValue },
        set: { value.wrappedValue = !$0 }
    )
}
