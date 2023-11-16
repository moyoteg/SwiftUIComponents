//
//  ReportProblem.swift
//
//
//  Created by Moi Gutierrez on 10/14/23.
//

import SwiftUI

public struct ReportProblem: View {
    @Binding var isShowingReportSheet: Bool
    @Binding var problemDescription: String
    @Binding var selectedImage: UIImage? // Updated to use a Binding for selectedImage
    @State private var isImagePickerPresented = false
    
    let submitAction: () -> Void
    
    @FocusState private var focusedField: FocusedField?
    enum FocusedField {
        case problemDescription
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Report a Problem")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text("Describe the problem:")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                TextEditor(text: $problemDescription)
                    .fontWeight(.bold)
                    .frame(height: 200)
                    .cornerRadius(8)
                    .padding()
                    .background(.secondary)
                    .focused($focusedField, equals: .problemDescription)
                    .onAppear {
                        focusedField = .problemDescription
                    }
                
                Button(action: {
                    isImagePickerPresented = true
                }) {
                    HStack {
                        Image(systemName: "camera")
                            .font(.system(size: 20))
                            .foregroundColor(.blue)
                        Text("Attach Screenshot")
                            .font(.headline)
                            .foregroundColor(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                }
                .sheet(isPresented: $isImagePickerPresented, onDismiss: loadImage) {
                    ImagePicker(image: $selectedImage)
                }
                
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: 200)
                }
                
                Button(action: {
                    submitAction()
                }) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .cornerRadius(8)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    isShowingReportSheet = false
                }
            )
        }
    }
    
    // Function to handle image selection
    private func loadImage() {
        // Handle the selected image here
        // You can resize or compress the image as needed
    }
}



struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
