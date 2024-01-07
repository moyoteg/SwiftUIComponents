//
//  ImageChecker.swift
//
//
//  Created by Moi Gutierrez on 12/5/23.
//

import Foundation

import SDWebImageSwiftUI
import CloudyLogs

public struct ImageChecker {
    
    public static func checkImage(url: URL, completion: @escaping (Bool) -> Void) {

        SDWebImageManager.shared.loadImage(
            with: url,
            options: [.retryFailed],
            progress: { (receivedSize, expectedSize, url) in
            },
            completed: { (image, data, error, cacheType, finished, imageURL) in
                // This is your completion block
                if let error = error {
                    Logger.log("ImageChecker: error: checkImage: \(error)", logType: .error)
                    completion(false)
                } else if image != nil {
                    completion(true)
                }
            }
        )
        
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            
//            if let error = error {
//                Logger.log("ImageChecker: checkImage: error: \(error)", logType: .error)
//                completion(false)
//                return
//            }
//            
//            guard let data = data else {
//                Logger.log("ImageChecker: checkImage: data is nil", logType: .error)
//                completion(false)
//                return
//            }
//            
//            guard let _ = UIImage(data: data) else {
//                Logger.log("ImageChecker: checkImage: cannot create UIImage from data", logType: .error)
//                completion(false)
//                return
//            }
//            
//            Logger.log("ImageChecker: checkImage: created UIImage from data")
//
//            completion(true)
//
//        }.resume()
    }
}
