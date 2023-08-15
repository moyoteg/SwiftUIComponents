//
//  File.swift
//  
//
//  Created by Moi Gutierrez on 6/13/23.
//

import Foundation

public protocol RandomImageGenerator {
    
    static func generateRandomImageURL(topic: String, size: ImagePlaceholderGenerator.ImageSize) -> String
}

public struct ImagePlaceholderGenerator {
    
    public enum ImageSize {
        case small
        case medium
        case large
        
        public var width: Int {
            switch self {
            case .small:
                return 320
            case .medium:
                return 640
            case .large:
                return 1024
            }
        }
        
        public var height: Int {
            switch self {
            case .small:
                return 240
            case .medium:
                return 480
            case .large:
                return 768
            }
        }
        
        public var rawValue: String {
            return "\(width)/\(height)"
        }
    }
    
    public static func generateURL(provider: Demo.Data.ImageURLStrings.Provider, topic: ImageTopics) -> String? {
        switch provider {
        case .remote:
            return nil
        case .loremIpsumAPI:
            return Picsum.generateRandomImageURL(topic: topic.rawValue)
        case .loremFlickrAPI:
            return LoremFlickrAPI.generateImageURL(size: .large)
        }
    }
    
    public static func generateRandomImageURL(provider: Demo.Data.ImageURLStrings.Provider, topic: String, width: Int = 600, height: Int = 600) -> String {
        switch provider {
        case .remote:
            return "https://example.com/\(width)/\(height)" // Replace "https://example.com" with the appropriate remote URL
            
        case .loremIpsumAPI:
            let randomNumber = Int.random(in: 1...1000)
            return "https://picsum.photos/seed/\(topic)/\(width)/\(height)?random=\(randomNumber)"
            
        case .loremFlickrAPI:
            let imageSize = ImageSize.medium
            return LoremFlickrAPI.generateRandomImageURL(topic: topic, size: imageSize)
        }
    }
}

public protocol ImageVersionable {
    var value: String { get }
    var topic: String { get }
}

public extension ImageVersionable {
    var value: String {
        // get 
        switch Demo.Data.Image.urlStringsProvider {
        case .remote: return value
        case .loremIpsumAPI: return Picsum.generateRandomTopicImageURL()
        case .loremFlickrAPI: return LoremFlickrAPI.generateRandomImageURL(topic: topic, size: .large)
        }
    }
    
    var topic: String {
        // TODO: get image by topic
        return "\(type(of: self))".lowercased()
        //        return "\(self)".lowercased()
    }
}

public extension Demo.Data {
    
    enum ImageURLStrings {
        
        public enum Provider {
            
            case remote
            case loremIpsumAPI // https://picsum.photos
            case loremFlickrAPI
            
        }
        
        public enum ImageTopics: String {
            case interest
            case profile
            // Add more image topics as needed
            
            public static func random() -> ImageTopics {
                let allTopics: [ImageTopics] = [.interest, .profile]
                let randomIndex = Int.random(in: 0..<allTopics.count)
                return allTopics[randomIndex]
            }
            
            public static func randomAsString() -> String {
                return ImageTopics.random().rawValue
            }
        }
        
        public static func generateRandomImageURL(topic: String, width: Int = 600, height: Int = 600) -> String {
            let randomNumber = Int.random(in: 1...1000)
            return "https://picsum.photos/seed/\(topic)/\(width)/\(height)?random=\(randomNumber)"
        }
        
        public enum Interest: String, ImageVersionable {
            case _1 = "https://drive.google.com/uc?id=11ggJZH9cpPWmMQ0xc4DnBtfLElWDFFth"
            case _2 = "https://drive.google.com/uc?id=1VJ98RBPG4N4KtKfHlDVI3DlfMamExMDV"
            case _3 = "https://drive.google.com/uc?id=1VpTOTs92bfkpcnHpKjXvtQyvTDCBwhf5"
            case _4 = "https://drive.google.com/uc?id=1eEq52FU5CVsUZaSQ1U55ufIWFws5WRxm"
            case _5 = "https://drive.google.com/uc?id=1mtJjYAqsh6QZWJAmHr91zLToBUCGCIE-"
            case _6 = "https://drive.google.com/uc?id=1tqbULU_L-q6VRxkgOhGqBXSaS1Umj69H"
            case _7 = "https://drive.google.com/uc?id=1yhYCyOPtu6WM-ElTE8h5Ij1knwvL5aIT"
        }
        
        public enum Profile: String, ImageVersionable {
            case _1 = "https://drive.google.com/uc?id=15G6-oAqCFbF_xzSax0icysOo3nPRpTNb"
            case _2 = "https://drive.google.com/uc?id=17NJy0yVokXeNG-nKHjZbO8vH5gOp1WgE"
            case _3 = "https://drive.google.com/uc?id=1AHRSHxb7dQMV2OAr9SttVoUF_x2tgXCW"
            case _4 = "https://drive.google.com/uc?id=1DBtiiCGtP3b0Yda6FYTYMdUpHWBSKduO"
            case _5 = "https://drive.google.com/uc?id=1LnucIH2O4ZSRu-OfQ6z_-cCoVtO5kZ9G"
            case _6 = "https://drive.google.com/uc?id=1smojnaSdzZi2DJT0GoZhHn9ZPoIBNuoV"
        }
        
        public enum Quest: String, ImageVersionable {
            case _1 = "https://drive.google.com/uc?id=1AwzYG6Wp4gfibjwVQ97ecQ9eiHl5mytr"
            case _2 = "https://drive.google.com/uc?id=1G2J2Rpb8s-f0Yzg6j1FJo-t3Eua0UL5u"
            case _3 = "https://drive.google.com/uc?id=1MDUMxl-A9VlTp6J6yuu_b60QBdK0oGgt"
            case _4 = "https://drive.google.com/uc?id=1Ub90EwoxcUotY-tthpi3Ew8GYBUkZDrq"
            case _5 = "https://drive.google.com/uc?id=1Xct-dKJLNAsyIi6GaRDnkNBj2s8sgXin"
            case _6 = "https://drive.google.com/uc?id=1uwxOedcr8CWs_Cg3XaXzwOOtIydhdUIs"
            case _7 = "https://drive.google.com/uc?id=1v4SA9p9MTtyCIOAQ8G8JUpZlFNYdCV5e"
            case _8 = "https://drive.google.com/uc?id=1x3qkq4_6AzwQ4ng1L_B14_GfJ4uB-fkX"
            case _9 = "https://drive.google.com/uc?id=1vjtvhUD9IK2jT96ztb42N84j52npRvSy"
            case _10 = "https://drive.google.com/uc?id=1NBlcyqQzpnk8gQ-axz6Ijpb1Nf5m7Lvb"
            case _11 = "https://drive.google.com/uc?id=1mJx-FFUP2to2r7oPp5sAD4bc_hX2k_v0"
            case _12 = "https://drive.google.com/uc?id=1pxDbkSmNx--9bC1yOD0aAHG4NT2k8Qvr"
            case _13 = "https://drive.google.com/uc?id=1wmElw2gLzgCHeFNGFwbkLhqz8__mDjhz"
            case _14 = "https://drive.google.com/uc?id=12axvT-_T3FyKkWhTXKInw9zOq5qHmCkm"
            case _15 = "https://drive.google.com/uc?id=1HcTL2OKBefcWg5lTdS-DV35nczjg_jG5"
            case _16 = "https://drive.google.com/uc?id=1evV5T_kVWMsCfXyFh7bB80N1E6AcNfDf"
            case _17 = "https://drive.google.com/uc?id=1s1pVJblmb3_EB8Vp2KzTg_ekOAFxZH2R"
            case _18 = "https://drive.google.com/uc?id=1BtrM9L45S96D2y0sF-fopkdf6tDqFVTk"
            case _19 = "https://drive.google.com/uc?id=1bJH27r5lyQv3QF1Bb9MIuDtyyWTvgpZ4"
            case _20 = "https://drive.google.com/uc?id=1Gx3P7dCp1Vw2pC0r0-Zgqj5W53TdL3V2"
        }
        
        public enum Prize: String, ImageVersionable {
            case _1 = "https://drive.google.com/uc?id=1c83vtuI2zfS4uzy7ptLrhiw4PwhO1KSo"
            case _2 = "https://drive.google.com/uc?id=1clYKSec_NjkojjeK2vyCwoIlLG8pdkg6"
            case _3 = "https://drive.google.com/uc?id=1f5pN_NnzzqRqs_BdT0K_jTaUaBfj8my2"
            case _4 = "https://drive.google.com/uc?id=1juW1FhP4IRiL4NXQFWcz0oH1FKPSoi3K"
            case _5 = "https://drive.google.com/uc?id=1E8Q1DtUj1Pje-MN5pSeF0TecXde2s-op"
        }
        
        public enum Ad: String, ImageVersionable {
            case yeti = "https://drive.google.com/uc?id=1eHvuObBz-TOkY7KHKlnKNF_6NV8mqhyS"
        }
        
        public enum Icon: String, ImageVersionable {
            case bookmark = "bookmark"
            case globe = "globe"
            case help_circle = "help_circle"
            case esater_egg = "esater_egg"
            case bell = "bell"
        }
    }
}
