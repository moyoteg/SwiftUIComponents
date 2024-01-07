//
// AutoImage.swift
//  
//
//  Created by Moi Gutierrez on 4/18/23.
//

import SwiftUI
import Combine

import CloudyLogs
import CachedAsyncImage
import Firebase
import FirebaseStorage
import SDWebImageSwiftUI
import AVKit

// ETag Cache Manager
class ETagCacheManager {
    static let shared = ETagCacheManager()
    private init() {}
    
    private var cache: [URL: String] = [:]
    
    func add(_ eTag: String, for url: URL) {
        cache[url] = eTag
    }
    
    func eTag(for url: URL) -> String? {
        return cache[url]
    }
}

// Image Cache Manager
class ImageCacheManager {
    static let shared = ImageCacheManager()
    private init() {}
    
    private var cache: NSCache<NSURL, UIImage> = NSCache()
    
    func add(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
}

public struct AutoImage: View {
    
    class ViewModel: ObservableObject {
        
        // Add AVPlayer properties
        @Published var isVideoLoaded = false
        var player: AVPlayer?
        
        @Published var image: Image? = nil {
            didSet {
                self.stopTimer()
            }
        }
        @Published var url: URL? = nil {
            didSet {
                guard let url = url else { return }
                
                if let cachedImage = ImageCacheManager.shared.image(for: url) {
                    self.image = Image(uiImage: cachedImage)
                    return
                }
                
                var request = URLRequest(url: url)
                if let eTag = ETagCacheManager.shared.eTag(for: url) {
                    request.addValue(eTag, forHTTPHeaderField: "If-None-Match")
                }
                
                SDWebImageManager.shared.loadImage(
                    with: url,
                    options: [.retryFailed, .handleCookies],
                    progress: { (receivedSize, expectedSize, url) in
                        guard expectedSize > 0 else {
                            return
                        }
                        // This is your progress block
                        DispatchQueue.main.async {
                            self.downloadProgress = abs(Float(receivedSize) / Float(expectedSize))
                            Logger.log("AutoImage: Download Progress: \(self.downloadProgress)")
                        }
                    },
                    completed: { (image, data, error, cacheType, finished, imageURL) in
                        // This is your completion block
                        if let error = error {
                            // Handle error
                            Logger.log("AutoImage: Error downloading image: \(error.localizedDescription)", logType: .error)
                        } else if let image = image {
                            // Image is downloaded and available
                            Logger.log("AutoImage: Image downloaded successfully")
                            // Do something with the image
                            self.image = Image(uiImage: image)
                        }
                    }
                )                
            }
        }
        @Published var isLoading = false
        @Published var downloadProgress: Float = 0.0

        private var useSystemImage: Bool
        private var cancellables = Set<AnyCancellable>()
        private var timer: Timer?
        let anyImageResource: Any?
        
        @ObservedObject var imageManager = ImageManager()

        init(anyImageResource: Any? = nil, useSystemImage: Bool) {
            self.anyImageResource = anyImageResource
            self.useSystemImage = useSystemImage
        }
        
        func startTimer() {
            guard timer == nil else { return }
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                self.figureOutMedia()
            }
        }
        
        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        func figureOutMedia() {
            
            if let _ = image {
                Logger.log("AutoImage: ViewModel: figureOutImage: image already loaded")
                return
            }
            
            // 1.- System Image
            if useSystemImage {
                Logger.log("AutoImage: ViewModel: loadImage(): useSystemImage: \(anyImageResource.debugDescription)")
                
                if let stringName = anyImageResource as? String,
                   let systemImage = UIImage(systemName: stringName) {
                    self.image = Image(uiImage: systemImage)
                    Logger.log("AutoImage: ViewModel: loadImage(): useSystemImage: ✅ success: \(anyImageResource.debugDescription)")
                    return
                }
            }
            
            // 2.- URL
            if let url = anyImageResource as? URL {
                Logger.log("AutoImage: ViewModel: loadImage(): URL provided for image: \(url)")
                self.url = url
                return
            }
            
            // 3.- String
            if let string = anyImageResource as? String, string.contains("gs://") {
                
                Logger.log("AutoImage: ViewModel: loadImage(): Firebase path provided for image: \(string)")
                loadImageFromFirebase(path: string)
                
            } else if let string = anyImageResource as? String,
                      string.contains("http"),
                      let url = URL(string: string) {
                
                Logger.log("AutoImage: ViewModel: loadImage(): URL(from string) provided for image: \(url)")
                
                self.url = url
                
                // Check if the URL is a video URL and set isVideoLoaded
                isVideoURL(url) { isVideo in
                    if isVideo {
                        DispatchQueue.main.async {
                            self.isVideoLoaded = true
                        }
                    } else {
                        self.imageManager.load(url: url)
                    }
                }
            } else {
                
                // 3.- load from local assets
                Logger.log("AutoImage: ViewModel: loadImage(): NO URL provided: \(anyImageResource.debugDescription)")
                self.image = loadImageFromLocal()
            }
        }
        
        private func isVideoURL(_ url: URL, completion: @escaping (Bool) -> Void) {
            // Get the file path extension from the URL
            let fileExtension = url.pathExtension.lowercased()
            
            // Check for common video file extensions
            let videoExtensions: Set<String> = ["mp4", "mov", "avi", "mkv", "flv", "wmv", "m4v", "webm"]
            
            if videoExtensions.contains(fileExtension) {
                completion(true)
                return
            }
            
            // Check the content type of the URL (requires making a network request)
            getMimeType(for: url) { mimeType in
                if let mimeType = mimeType, mimeType.hasPrefix("video/") {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        
        // Helper function to get the MIME type of a URL
        private func getMimeType(for url: URL, completion: @escaping (String?) -> Void) {
            var request = URLRequest(url: url)
            request.httpMethod = "HEAD"
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let response = response as? HTTPURLResponse, let contentType = response.allHeaderFields["Content-Type"] as? String else {
                    completion(nil)
                    return
                }
                
                completion(contentType)
            }
            
            task.resume()
        }

        
        // Load video from URL
        func loadVideo(from url: URL) {
            // Initialize AVPlayer with the video URL
            self.player = AVPlayer(url: url)
            self.player?.play()
            self.isVideoLoaded = true
        }
        
        func loadImageFromFirebase(path: String) {
            
            isLoading = true
                                    
            let storageRef = Storage.storage().reference(forURL: path)
            storageRef.getData(maxSize: 15 * 1024 * 1024) { [weak self] data, error in
                self?.isLoading = false
                if let error = error {
                    Logger.log("AutoImage: ViewModel: loadImageFromFirebase(): Error fetching image from Firebase: \(error.localizedDescription)", logType: .error)
                    self?.image = self?.loadImageFromLocal()
                    return
                }
                
                guard let imageData = data else {
                    Logger.log("AutoImage: ViewModel: loadImageFromFirebase(): Data is nil. Failed to retrieve image data from Firebase.", logType: .error)
                    self?.image = self?.loadImageFromLocal()
                    return
                }
                
                guard let image = UIImage(data: imageData) else {
                    Logger.log("AutoImage: ViewModel: loadImageFromFirebase(): Failed to convert data into UIImage.", logType: .error)
                    self?.image = self?.loadImageFromLocal()
                    return
                }
                
                self?.image = Image(uiImage: image)
                Logger.log("AutoImage: ViewModel: loadImageFromFirebase(): Successfully loaded image from Firebase.", logType: .success)
            }
        }
        
        func loadImageFromFirebase(path: String, completion: @escaping (UIImage?) -> Void) {
            let storageRef = Storage.storage().reference(forURL: path)
            
            // Fetch the download URL
            storageRef.downloadURL { url, error in
                if let error = error {
                    print("Failed to get download URL: \(error)")
                    completion(nil)
                    return
                }
                
                guard let url = url else {
                    print("URL is nil")
                    completion(nil)
                    return
                }
                
                // Use SDWebImage to load the image
                SDWebImageManager.shared.loadImage(
                    with: url,
                    options: .highPriority,
                    progress: nil) { (image, _, error, _, _, _) in
                        if let error = error {
                            print("Error loading image: \(error)")
                            completion(nil)
                        } else {
                            completion(image)
                        }
                    }
            }
        }
        
        func loadImageFromLocal() -> Image? {
            if let anyImageResource = anyImageResource,
               let stringName: String = anyImageResource as? String {
                
                Logger.log("AutoImage: ViewModel: loadImageFromLocal(): NO URL provided: \(anyImageResource)")
                
                if let localImage = UIImage(named: stringName) {
                    
                    Logger.log("AutoImage: ViewModel: loadImageFromLocal(): localImage: \(localImage)")
                    return Image(uiImage: localImage)
                    
                } else if let _ = UIImage(systemName: stringName) {
                    
                    Logger.log("AutoImage: ViewModel: loadImageFromLocal(): systemImage: \(stringName)")
                    return Image(systemName: stringName)
                    
                }
            }
            return nil
        }
    }
    
    // ********************************
    @ObservedObject private var viewModel: ViewModel
    
    private var renderingMode: Image.TemplateRenderingMode = .original
    
    private var contentMode: ContentMode = .fit
    
    private let placeholderImage: Image
    
    private var isResizable = false
    
    public var body: some View {
        
        if let image = viewModel.image {
            
            image
                .resizableIf(isResizable)
                .renderingMode(renderingMode)
                .aspectRatio(contentMode: contentMode)
            
            // Check if the URL is a video
        } else if let url = viewModel.url, viewModel.isVideoLoaded {
            
            VideoPlayer(player: viewModel.player)
                .onAppear {
                    self.viewModel.loadVideo(from: url)
                }
            
        } else {
            placeholderImageView()
        }
    }
    
    @ViewBuilder
    func placeholderImageView() -> some View {
        
        ZStack {
            
            ProgressView(value: viewModel.downloadProgress)
                .progressViewStyle(.circular)
                .isHidden(!viewModel.isLoading)
            
                placeholderImage
                    .renderingMode(.template)
                    .resizable()
                    .opacity(0.5)
                    .padding()
                    .aspectRatio(contentMode: contentMode)
                    .animatingMask(isMasked: true)
                    .overlay(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                if self.viewModel.image == nil {
                                    Logger.log("tapped to load image: \(self.viewModel.anyImageResource.debugDescription)")
                                    self.viewModel.figureOutMedia()
                                }
                            }
                    )
        }
        .onAppear {
            self.viewModel.startTimer()
            self.viewModel.figureOutMedia()
        }
        .onDisappear {
            self.viewModel.stopTimer()
        }
    }
    
    public init(
        placeholderImage: Image = Image(systemName: "photo"),
        _ anyImageResource: Any? = nil,
        useSystemImage: Bool = false
    ) {
        self.placeholderImage = placeholderImage
        viewModel = ViewModel(anyImageResource: anyImageResource, useSystemImage: useSystemImage)
    }
    
    public func resizable() -> AutoImage {
        var view = self
        view.isResizable = true
        return view
    }
    
    public func renderingMode(_ renderingMode: Image.TemplateRenderingMode) -> Self {
        var view = self
        view.renderingMode = renderingMode
        return view
    }
}

/////////////////////////////////////////////////////////////////
public extension AutoImage {
    
    struct Demo: View {
        
        public var body: some View {
            List {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scenario 1: Image loaded from URL")
                        .font(.headline)
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            AutoImage("https://via.placeholder.com/150")
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                            Spacer()
                        }
                        Text("URL Image")
                            .font(.system(size: 18, weight: .medium))
                            .lineSpacing(5)
                    }
                    .padding(.vertical)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scenario 2: Image loaded from local assets")
                        .font(.headline)
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            AutoImage("AppIcon")
                            Spacer()
                        }
                        Text("Local Image")
                            .font(.system(size: 18, weight: .medium))
                            .lineSpacing(5)
                    }
                    .padding(.vertical)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scenario 3: URL is nil and local image is not found (shows placeholder image)")
                        .font(.headline)
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            AutoImage("nonexistent")
                                .font(.largeTitle)
                            Spacer()
                        }
                        Text("Placeholder Image")
                            .font(.system(size: 18, weight: .medium))
                            .lineSpacing(5)
                    }
                    .padding(.vertical)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scenario 4: URL is not reachable (shows placeholder image)")
                        .font(.headline)
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            AutoImage(URL(string: "https://invalid-url.example.com/image.jpg"))
                                .font(.largeTitle)
                            Spacer()
                        }
                        Text("Invalid URL")
                            .font(.system(size: 18, weight: .medium))
                            .lineSpacing(5)
                    }
                    .padding(.vertical)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scenario 5: Image loaded from URL in a Button")
                        .font(.headline)
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                AutoImage(URL(string: "https://via.placeholder.com/150"))
                                    .resizable()
                                    .frame(width: 150, height: 150)
                                    .clipShape(Circle())
                            }
                            Spacer()
                        }
                        Text("Image in Button")
                            .font(.system(size: 18, weight: .medium))
                            .lineSpacing(5)
                    }
                    .padding(.vertical)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scenario 6: Image loaded from system name")
                        .font(.headline)
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            AutoImage("star.fill", useSystemImage: true)
                                .font(.largeTitle)
                            Spacer()
                        }
                        Text("System Image Name")
                            .font(.system(size: 18, weight: .medium))
                            .lineSpacing(5)
                    }
                    .padding(.vertical)
                }
            }
            .listStyle(.plain)
        }
        
        public init(){}
    }
}

struct AutoImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Scenario 1: Image loaded from URL
            VStack {
                AutoImage(URL(string: "https://via.placeholder.com/150"))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("URL Image")
            }
            
            // Scenario 2: Image loaded from local assets
            VStack {
                AutoImage("interest1")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("Local Image")
            }
            
            // Scenario 3: URL is nil and local image is not found (shows placeholder image)
            VStack {
                AutoImage("nonexistent")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("Placeholder Image")
            }
            
            // Scenario 4: URL is not reachable (shows placeholder image)
            VStack {
                AutoImage(URL(string: "https://invalid-url.example.com/image.jpg"))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("Invalid URL")
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
