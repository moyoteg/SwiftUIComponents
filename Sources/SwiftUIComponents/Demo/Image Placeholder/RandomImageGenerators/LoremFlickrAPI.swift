//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 6/12/23.
//

import SwiftUI

struct LoremFlickrAPIView: View {
    @State var url: String = LoremFlickrAPI.generateRandomImageURL()
    
    var body: some View {
        VStack {
            Text(url)
            
            AutoImage(url)
            
            Button("New Image") {
                url = LoremFlickrAPI.generateRandomImageURL()
            }
        }
    }
}

public struct LoremFlickrAPI: RandomImageGenerator {
    
    public static func generateRandomImageURL(topic: String, size: ImagePlaceholderGenerator.ImageSize) -> String {
        return LoremFlickrAPI.generateImageURL(topic: topic, size: size, tag: nil, lock: false, isRandom: false)
    }
    
    public static let baseURL = "https://loremflickr.com"
    
    public static var stringURLs: [String] {
        var stringURLs = [String]()
        for _ in 1...100 {
            let randomTopic = ImageTopics.randomAsString()
            let randomURL = LoremFlickrAPI.generateRandomImageURL(topic: randomTopic, size: .large)
            stringURLs.insert(randomURL, at: 0)
        }
        return stringURLs
    }
    
    public static func generateImageURL(topic: String? = nil, size: ImagePlaceholderGenerator.ImageSize, tag: String? = nil, lock: Bool = false, isRandom: Bool = false) -> String {
        let randomNumber = Int.random(in: 1...1000)
        let topic = topic ?? "random"
        var url = "\(baseURL)/\(size.rawValue)/\(topic)"
        
        if let tag = tag {
            url += "/\(tag)"
        }
        
        if lock {
            if isRandom {
                url += "?lock=\(randomNumber)"
            } else {
                url += "?lock=1"
            }
        }
        
        return url
    }
    
    public static func generateRandomImageURL() -> String {
        return generateImageURL(size: .medium)
    }
}
