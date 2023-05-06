//
//  URLImage.swift
//  
//
//  Created by Moi Gutierrez on 4/18/23.
//

import SwiftUI
import Combine

public struct URLImage: View {
    class ViewModel: ObservableObject {
        @Published var image: UIImage? = nil
        @Published var isLoading = false
        
        private let url: URL?
        private let localImageName: String?
        private var cancellables = Set<AnyCancellable>()
        private var timer: Timer?
        
        init(url: URL?, localImageName: String? = nil) {
            self.url = url
            self.localImageName = localImageName
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
            guard let url = url else {
                image = loadImageFromLocal()
                return
            }
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
                        self?.image = self?.loadImageFromLocal()
                    }
                }
                .store(in: &cancellables)
        }
        
        private func loadImageFromLocal() -> UIImage? {
            guard let imageName = localImageName else { return nil }
            return UIImage(named: imageName)
        }
    }
    
    @StateObject private var viewModel: ViewModel
    
    private let systemImage: Image?
    private let placeholderImage: Image
    private let url: URL?
    
    private var isResizable = false
    
    public init(systemName: String? = nil,
                url: URL? = nil,
                localImageName: String? = nil,
                placeholderImage: Image = Image(systemName: "photo")) {
        self.url = url
        if let systemName = systemName {
            self.systemImage = Image(systemName: systemName)
        } else {
            self.systemImage = nil
        }
        self.placeholderImage = placeholderImage
        _viewModel = StateObject(wrappedValue: ViewModel(url: url, localImageName: localImageName))
    }
    
    public func resizable() -> URLImage {
        var view = self
        view.isResizable = true
        return view
    }
    
    public var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizableIf(isResizable)
                    .renderingMode(.original)
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    .clipped()
                    .overlay(
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.loadImage()
                            }
                    )
            }else if systemImage != nil {
              systemImage
            } else {
                placeholderImageView()
            }
            
            if viewModel.isLoading {
                ZStack {
                    
                    ProgressView()
                        .scaledToFill()
                    
                    placeholderImageView()
                }
            }
        }
        .onAppear {
            viewModel.startTimer()
        }
        .onDisappear {
            viewModel.stopTimer()
        }
    }
    
    @ViewBuilder
    func placeholderImageView() -> some View {
        
        placeholderImage
            .resizable()
            .scaledToFit()
            .animatingMask(isMasked: true)
            .opacity(0.5)
            .padding()
    }
    
    public struct Demo: View {
        
        public var body: some View {
            List {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Scenario 1: Image loaded from URL")
                        .font(.headline)
                    VStack(spacing: 5) {
                        HStack {
                            Spacer()
                            URLImage(url: URL(string: "https://via.placeholder.com/150"))
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
                            URLImage(url: nil, localImageName: "AppIcon")
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
                            URLImage(url: nil, localImageName: "nonexistent")
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
                            URLImage(url: URL(string: "https://invalid-url.example.com/image.jpg"))
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
                                URLImage(url: URL(string: "https://via.placeholder.com/150"))
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
                            URLImage(systemName: "star.fill")
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

struct URLImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Scenario 1: Image loaded from URL
            VStack {
                URLImage(url: URL(string: "https://via.placeholder.com/150"))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("URL Image")
            }
            
            // Scenario 2: Image loaded from local assets
            VStack {
                URLImage(url: nil, localImageName: "interest1")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("Local Image")
            }
            
            // Scenario 3: URL is nil and local image is not found (shows placeholder image)
            VStack {
                URLImage(url: nil, localImageName: "nonexistent")
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("Placeholder Image")
            }
            
            // Scenario 4: URL is not reachable (shows placeholder image)
            VStack {
                URLImage(url: URL(string: "https://invalid-url.example.com/image.jpg"))
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                Text("Invalid URL")
            }
        }
        .previewLayout(.sizeThatFits)
    }
}
