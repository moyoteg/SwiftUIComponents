//
//  WebView.swift
//
//
//  Created by Moi Gutierrez on 11/15/23.
//

import SwiftUI
import WebKit

public struct WebView: UIViewRepresentable {
    let urlString: String
    
    public init(urlString: String) {
        self.urlString = urlString
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        guard let url = URL(string: urlString) else {
            return WKWebView() // Return an empty WKWebView if URL is invalid
        }
        let webView = WKWebView()
        webView.load(URLRequest(url: url))
        return webView
    }
    
    public func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the view if needed
    }
}

public struct WebsiteView: View {
    
    var urlString: String
    
    public var body: some View {
        WebView(urlString: urlString)
            .edgesIgnoringSafeArea(.all) // To make the WebView full screen
    }
}

//// WebView that manages a WKWebView
//public struct ComprehensiveWebView: UIViewRepresentable {
//    let urlString: String
//    @Binding var isLoading: Bool
//    
//    public func makeCoordinator() -> Coordinator {
//        Coordinator(self, isLoading: $isLoading)
//    }
//    
//    public func makeUIView(context: Context) -> WKWebView {
//        guard let url = URL(string: urlString) else {
//            return WKWebView()
//        }
//        let webView = WKWebView()
//        webView.navigationDelegate = context.coordinator
//        webView.load(URLRequest(url: url))
//        return webView
//    }
//    
//    public func updateUIView(_ uiView: WKWebView, context: Context) {
//    }
//    
//    // Coordinator to act as WKWebView delegate
//    public class Coordinator: NSObject, WKNavigationDelegate {
//        var parent: WebView
//        var isLoading: Binding<Bool>
//        
//        init(_ parent: WebView, isLoading: Binding<Bool>) {
//            self.parent = parent
//            self.isLoading = isLoading
//        }
//        
//        public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//            isLoading.wrappedValue = true
//        }
//        
//        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//            isLoading.wrappedValue = false
//        }
//        
//        public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
//            isLoading.wrappedValue = false
//            // Handle error
//        }
//    }
//}
//
//// View that presents the WebView
//public struct WebsiteView: View {
//    var urlString: String
//    @State private var isLoading = false
//    
//    public var body: some View {
//        VStack {
//            WebView(urlString: urlString, isLoading: $isLoading)
//                .edgesIgnoringSafeArea(.all)
//            
//            if isLoading {
//                ProgressView()
//                    .progressViewStyle(CircularProgressViewStyle())
//            }
//        }
//    }
//}
