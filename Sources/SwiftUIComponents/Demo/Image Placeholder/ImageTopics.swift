//
//  File.swift
//  
//
//  Created by Moi Gutierrez on 6/13/23.
//

import Foundation

public enum ImageTopics: String, CaseIterable {
    // Add more image topics as needed
    case interest
    case person
    case travel
    case mountain
    case flower
    case water
    
    static public func random() -> ImageTopics {
        let randomIndex = Int.random(in: 0..<ImageTopics.allCases.count)
        return ImageTopics.allCases[randomIndex]
    }
    
    static public func randomAsString() -> String {
        return ImageTopics.random().rawValue
    }
}

