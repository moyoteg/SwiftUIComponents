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
                
                URLSession.shared.dataTaskPublisher(for: request)
                    .tryMap { output in
                        if let response = output.response as? HTTPURLResponse, let eTag = response.allHeaderFields["Etag"] as? String {
                            ETagCacheManager.shared.add(eTag, for: url)
                        }
                        return UIImage(data: output.data)!
                    }
                    .receive(on: DispatchQueue.main)
                    .replaceError(with: nil)
                    .sink { [weak self] (downloadedImage: UIImage?) in
                        if let uiImage = downloadedImage {
                            ImageCacheManager.shared.add(uiImage, for: url)
                        }
                        self?.image = downloadedImage.map(Image.init(uiImage:))
                    }
                    .store(in: &cancellables)
            }
        }
        @Published var isLoading = false
        
        private var useSystemImage: Bool
        private var cancellables = Set<AnyCancellable>()
        private var timer: Timer?
        let any: Any?
        
        @ObservedObject var imageManager = ImageManager()

        init(any: Any? = nil, useSystemImage: Bool) {
            self.any = any
            self.useSystemImage = useSystemImage
        }
        
        func startTimer() {
            guard timer == nil else { return }
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                self?.figureOutImage()
            }
        }
        
        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        func figureOutImage() {
            
            if let _ = image {
                // image already loaded
                return
            }
            
            // 1.- System Image
            if useSystemImage {
                Logger.log("AutoImage: ViewModel: loadImage(): useSystemImage: \(any.debugDescription)")
                
                if let stringName = any as? String,
                   let systemImage = UIImage(systemName: stringName) {
                    self.image = Image(uiImage: systemImage)
                    Logger.log("AutoImage: ViewModel: loadImage(): useSystemImage: ✅ success: \(any.debugDescription)")
                    return
                }
            }
            
            // 2.- URL
            if let string = any as? String, string.contains("gs://") {
                
                Logger.log("AutoImage: ViewModel: loadImage(): Firebase path provided for image: \(string)")
                loadImageFromFirebase(path: string)
                
            } else if let string = any as? String,
                      string.contains("http"),
                      let url = URL(string: string) {
                
                Logger.log("AutoImage: ViewModel: loadImage(): URL provided for image: \(url)")
                
                self.url = url
                self.imageManager.load(url: url)
            }
            else {
                
                // 3.- load from local assets
                Logger.log("AutoImage: ViewModel: loadImage(): NO URL provided: \(any.debugDescription)")
                self.image = loadImageFromLocal()
            }
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
            if let stringName = any as? String {
                Logger.log("AutoImage: ViewModel: loadImageFromLocal(): NO URL provided: \(any.debugDescription)")
                
                if let localImage = UIImage(named: stringName) {
                    Logger.log("AutoImage: ViewModel: loadImageFromLocal(): localImage: \(localImage)")
                    return Image(uiImage: localImage)
                } else if let systemImage = UIImage(systemName: stringName) {
                    Logger.log("AutoImage: ViewModel: loadImageFromLocal(): systemImage: \(systemImage)")
                    return Image(uiImage: systemImage)
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
        
//        WebImage(url: URL(string: viewModel.any as! String))
//
//        // Supports options and context, like `.delayPlaceholder` to show placeholder only when error
//            .onSuccess { image, data, cacheType in
//                // Success
//                // Note: Data exist only when queried from disk cache or network. Use `.queryMemoryData` if you really need data
//            }
//            .resizable() // Resizable like SwiftUI.Image, you must use this modifier or the view will use the image bitmap size
//            .placeholder(Image(systemName: "photo")) // Placeholder Image
//        // Supports ViewBuilder as well
////            .placeholder {
////                Rectangle().foregroundColor(.gray)
////            }
//            .indicator(.activity) // Activity Indicator
//            .transition(.fade(duration: 0.5)) // Fade Transition with duration
//            .scaledToFit()
//            .frame(width: 300, height: 300, alignment: .center)
        
        if let image = viewModel.image {

            image
                .renderingMode(renderingMode)
                .resizableIf(isResizable)
                .aspectRatio(contentMode: contentMode)

        } else {

            placeholderImageView()

        }
    }
    
    @ViewBuilder
    func placeholderImageView() -> some View {
        
        ZStack {
            
            ProgressView()
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
                                Logger.log("tapped to load image: \(self.viewModel.any.debugDescription)")
                                self.viewModel.figureOutImage()
                            }
                        }
                )
        }
        .onAppear {
            self.viewModel.startTimer()
            self.viewModel.figureOutImage()
        }
        .onDisappear {
            self.viewModel.stopTimer()
        }
    }
    
    public init(
        placeholderImage: Image = Image(systemName: "photo"),
        _ any: Any? = nil,
        useSystemImage: Bool = false
    ) {
        self.placeholderImage = placeholderImage
        viewModel = ViewModel(any: any, useSystemImage: useSystemImage)
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
