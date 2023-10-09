//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 10/5/23.
//

import SwiftUI

import SwiftUI
import UIKit

// UIViewControllerRepresentable for document picking
public struct DocumentPickerViewController: UIViewControllerRepresentable {
    public var onDocumentPicked: ((URL) -> Void)
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let controller = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        controller.delegate = context.coordinator
        return controller
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public init(onDocumentPicked: @escaping ((URL) -> Void)) {
        self.onDocumentPicked = onDocumentPicked
    }
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        public var parent: DocumentPickerViewController
        
        public init(_ parent: DocumentPickerViewController) {
            self.parent = parent
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            if let url = urls.first {
                parent.onDocumentPicked(url)
            }
        }
    }
}

// DocumentPickerType enum to differentiate between import and export
public enum DocumentPickerType {
    case `import`
    case export
}
