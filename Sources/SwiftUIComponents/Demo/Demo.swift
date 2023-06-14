//
//  File.swift
//  
//
//  Created by Moi Gutierrez on 6/13/23.
//

import Foundation
import SwiftUI

public struct Demo {
    
    public struct Mode {
        
        public struct UI: View {
            
            public var body: some View {
                // TODO: create demo view
                Text("demo mode")
            }
        }
    }
    
    public struct Data {
        
        enum Version {
            
            case local
            case remote
        }
        
        static let version: Demo.Data.Version = .remote
        static var imageURLStringsVersion: Demo.Data.ImageURLStrings.Version = .loremFlickrAPI
    }
}
