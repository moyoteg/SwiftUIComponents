//
// AutoImage.swift
//  
//
//  Created by Moi Gutierrez on 4/18/23.
//

import SwiftUI
import Combine

import CloudyLogs

public struct AutoImage: View {
    
    class ViewModel: ObservableObject {
        
        @Published var image: UIImage? = nil
        @Published var isLoading = false
        
        private var useSystemImage: Bool
        private var cancellables = Set<AnyCancellable>()
        private var timer: Timer?
        let any: Any?
        
        init(any: Any? = nil, useSystemImage: Bool) {
            self.any = any
            self.useSystemImage = useSystemImage
            loadImage()
        }
        
        func startTimer() {
            guard timer == nil else { return }
            timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
                self?.loadImage()
            }
        }
        
        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
        
        func loadImage() {

            if useSystemImage {
                
                Logger.log("AutoImage: ViewModel: loadImage(): useSystemImage: \(any.debugDescription)")

                if let stringName = any as? String, // if string
                   let systemImage = UIImage(systemName: stringName) {
                    self.image = systemImage
                    return
                }
            }
            
            if let url = any as? URL { // if URL
                
                Logger.log("AutoImage: ViewModel: loadImage(): URL provided for image: \(url)")
                
                isLoading = true
                
                URLSession.shared.dataTaskPublisher(for: url)
                    .map { UIImage(data: $0.data) }
                    .replaceError(with: nil)
                    .receive(on: DispatchQueue.main)
                    .sink { [weak self] image in
                        self?.isLoading = false
                        if let image = image {
                            self?.image = image
                        } else {
                            Logger.log("AutoImage: ViewModel: loadImage(): failed to load URL provided, loadImageFromLocal(): \(url)")

                            self?.image = self?.loadImageFromLocal()
                        }
                    }
                    .store(in: &cancellables)
                
            } else {
                
                Logger.log("AutoImage: ViewModel: loadImage(): NO URL provided: \(any.debugDescription)")
                
                self.image = self.loadImageFromLocal()
            }
        }
        
        func loadImageFromLocal() -> UIImage? {
            
            if let stringName = any as? String { // if string
            
                Logger.log("AutoImage: ViewModel: loadImageFromLocal(): NO URL provided: \(any.debugDescription)")
                
                if let localImage = UIImage(named: stringName) { // if local image

                    Logger.log("AutoImage: ViewModel: loadImageFromLocal(): localImage: \(localImage)")

                    return localImage
                    
                } else if let systemImage = UIImage(systemName: stringName) { // if system image
                    
                    Logger.log("AutoImage: ViewModel: loadImageFromLocal(): systemImage: \(systemImage)")
                    
                    return systemImage
                    
                }
            }
            return nil
        }
        
    }
    
    // ********************************
    @ObservedObject private var viewModel: ViewModel
    
    private var renderingMode: Image.TemplateRenderingMode = .original
    
    private let placeholderImage: Image
    
    private var isResizable = false
    
    public var body: some View {
        
        ZStack {
            
            if let image = viewModel.image {
                Image(uiImage: image)
                    .renderingMode(renderingMode)
                    .resizableIf(isResizable)
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                
            } else {
                
                if viewModel.isLoading {
                    
                    ProgressView()
                        .scaledToFill()
                }
                
                placeholderImageView()
                    .animatingMask(isMasked: true)
                    .padding()
                    .overlay(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                Logger.log("tapped to load image: \(self.viewModel.any.debugDescription)")
                                self.viewModel.loadImage()
                            }
                    )
            }
            
        }
        .onAppear {
            self.viewModel.startTimer()
        }
        .onDisappear {
            self.viewModel.stopTimer()
        }
    }
    
    @ViewBuilder
    func placeholderImageView() -> some View {
        
        placeholderImage
            .renderingMode(.template)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .opacity(0.5)

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
                            AutoImage(URL(string: "https://via.placeholder.com/150"))
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
                            AutoImage("star.fill")
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
