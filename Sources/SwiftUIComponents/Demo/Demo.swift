//
//  File.swift
//  
//
//  Created by Moi Gutierrez on 6/13/23.
//

import Foundation
import SwiftUI

import SwiftyUserDefaults

public class Demo: ObservableObject {
    
    public class Data: ObservableObject {
        
        public enum SourceLocation: String, Codable, DefaultsSerializable, CaseIterable {
            
            public static var _defaults: DefaultsCodableBridge<Self> { return DefaultsCodableBridge() }
            public static var _defaultsArray: DefaultsCodableBridge<[Self]> { return DefaultsCodableBridge() }
            
            case local
            case remote
        }
        
        public struct Image {
         
            public static var urlStringsProvider: Demo.Data.ImageURLStrings.Provider = .loremFlickrAPI
        }

        @Published public var sourceLocation: Demo.Data.SourceLocation
        @Published public var imageURLStringsProvider: Demo.Data.ImageURLStrings.Provider
        
        public init(sourceLocation: Demo.Data.SourceLocation = .remote, imageURLStringsProvider: Demo.Data.ImageURLStrings.Provider = .loremFlickrAPI) {
            self.sourceLocation = sourceLocation
            self.imageURLStringsProvider = imageURLStringsProvider
        }
    }
    
    @Published public var data: Data
    
    public init(data: Demo.Data = Data()) {
        self.data = data
    
    }
}
