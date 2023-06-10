//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 6/9/23.
//

import SwiftUI

struct PicsumView: View {
    @State var url: String = Picsum.generateRandomImageURL()
    
    var body: some View {
        VStack {
            
            Text(url)
            
            AutoImage(url)
            
            Button("new image") {
                url = Picsum.generateRandomImageURL()
            }
        }
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PicsumView()
    }
}

// Based on https://picsum.photos API
public enum Picsum {
    
    public enum ImageTopics: String, CaseIterable {
        
        // Add more image topics as needed
        case interest
        case profile
        case mountain
        case flower
        case water
                
        public static func random() -> ImageTopics {
            let randomIndex = Int.random(in: 0..<ImageTopics.allCases.count)
            return ImageTopics.allCases[randomIndex]
        }
        
        public static func randomAsString() -> String {
            return ImageTopics.random().rawValue
        }
    }
    
    public static var stringURLs: [String] {
        var stringURLs = [String]()
        for _ in 1...100 {
            let randomTopic = ImageTopics.randomAsString()
            let randomURL = generateRandomImageURL(topic: randomTopic)
            stringURLs.insert(randomURL, at: 0)
        }
        return stringURLs
    }
    
    public static func generateRandomImageURL(topic: String, width: Int = 600, height: Int = 600) -> String {
        let randomNumber = Int.random(in: 1...1000)
        return "https://picsum.photos/seed/\(topic)/\(width)/\(height)?random=\(randomNumber)"
    }
    
    public static func generateRandomImageURL() -> String {
        Picsum.generateRandomImageURL(topic: Picsum.ImageTopics.randomAsString())
    }
}
