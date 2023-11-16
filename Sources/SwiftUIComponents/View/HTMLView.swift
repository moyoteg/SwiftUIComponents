//
//  HTMLView.swift
//  SwiftUIComponents
//
//  Created by Moi Gutierrez on 3/14/22.
//

import SwiftUI
#if os(iOS) || !os(watchOS)
import WebKit

public struct HTMLView: View {
    @Binding var htmlText: String
    
    public var body: some View {
        HTMLWebView(text: $htmlText)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
    }
    
    public init(htmlText: Binding<String>) {
        self._htmlText = htmlText
    }
}

struct HTMLWebView: UIViewRepresentable {
    @Binding var text: String
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(text, baseURL: nil)
    }
}

struct HTMLView_Previews: PreviewProvider {
        
    static var previews: some View {
        HTMLView(htmlText: .constant(
"""
<html>
<body>
<h1>
Hello World
</h1>
</body>
</html>
"""
        ))
    }
}
#endif
