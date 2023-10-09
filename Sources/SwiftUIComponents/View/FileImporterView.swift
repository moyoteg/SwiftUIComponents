//
//  SwiftUIView.swift
//  
//
//  Created by Moi Gutierrez on 10/5/23.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

public struct FileImporterView: UIViewControllerRepresentable {
    @Binding var fileURL: URL?
    @Environment(\.presentationMode) var presentationMode
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.commaSeparatedText])
        picker.allowsMultipleSelection = false
        picker.delegate = context.coordinator
        return picker
    }
    
    public func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }
    
    public class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FileImporterView
        
        init(_ parent: FileImporterView) {
            self.parent = parent
        }
        
        public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            parent.fileURL = urls.first
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
