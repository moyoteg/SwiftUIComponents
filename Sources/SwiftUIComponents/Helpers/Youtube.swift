//
//  File.swift
//  
//
//  Created by Moi Gutierrez on 12/13/23.
//

import Foundation

import CloudyLogs

public enum Youtube {
    public static func getThumbnailURL(from youtubeURL: String) -> String? {
        guard let url = URL(string: youtubeURL) else {
            Logger.log("Youtube: Invalid URL format: \(youtubeURL)")
            return nil
        }
        
        guard let videoID = extractVideoID(from: url) else {
            Logger.log("Youtube: Failed to extract video ID from URL: \(youtubeURL)")
            return nil
        }
        
        let thumbnailURL = "https://img.youtube.com/vi/\(videoID)/hqdefault.jpg" // hqdefault // maxresdefault
        Logger.log("Youtube: Thumbnail URL generated: \(thumbnailURL)")
        return thumbnailURL
    }
    
    public static func extractVideoID(from url: URL) -> String? {
        if url.pathComponents.contains("embed") {
            return url.lastPathComponent
        }
        if url.host == "youtu.be" {
            return url.lastPathComponent
        }
        
        let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems
        if let videoID = queryItems?.first(where: { $0.name == "v" })?.value {
            return videoID
        }
        
        Logger.log("Youtube: No video ID found in URL: \(url)")
        return nil
    }
}


