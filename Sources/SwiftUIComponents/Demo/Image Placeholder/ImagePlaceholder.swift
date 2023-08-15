//
//  File.swift
//  
//
//  Created by Moi Gutierrez on 6/14/23.
//

import Foundation

public class ImagePlaceholder: ObservableObject {
    
    public struct History {
        public struct Entry: Identifiable {
            public var id: String { topic }
            let topic: String
            let urlString: String
        }
        
        public var entries = [Entry]()
    }
    
    @Published public var provider: Demo.Data.ImageURLStrings.Provider
    @Published public var history: History
    
    public var stringURLs: [String] {
        var stringURLs = [String]()
        
        for _ in 1...100 {
            let randomTopic = ImageTopics.randomAsString()
            let randomURL = ImagePlaceholderGenerator.generateRandomImageURL(provider: provider, topic: randomTopic)
            stringURLs.insert(randomURL, at: 0)
        }
        
        return stringURLs
    }
    
    public init(provider: Demo.Data.ImageURLStrings.Provider) {
        self.provider = provider
        self.history = History()
    }
}

