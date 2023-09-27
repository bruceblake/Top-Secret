//
//  GroupGalleryPhotoPicker.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/30/22.
//

import Foundation
import SwiftUI
import PhotosUI
struct GroupGalleryPhotoPicker : UIViewControllerRepresentable {
    
    @Binding var selectedImages : [UIImage]
    @Binding var picker : Bool
    @Binding var readyToPost : Bool
    func makeUIViewController(context: Context) -> some PHPickerViewController {
        
        var config = PHPickerConfiguration()
        
        config.filter = .images
        config.selectionLimit = 0
        let picker = PHPickerViewController(configuration: config)
        
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        return GroupGalleryPhotoPicker.Coordinator(parent1: self)
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
    
   
    final class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent : GroupGalleryPhotoPicker
        
         init(parent1: GroupGalleryPhotoPicker){
            parent = parent1
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            
            if !parent.selectedImages.isEmpty {
                self.parent.readyToPost = true
            }
            parent.picker.toggle()
            for img in results {
                
                if img.itemProvider.canLoadObject(ofClass: UIImage.self){
                    img.itemProvider.loadObject(ofClass: UIImage.self) { image, err in
                        guard let image1 = image else {
                            print(err)
                            return
                        }
                        
                        self.parent.selectedImages.append(image1 as! UIImage)
                    }
                }else{
                    
                    print("Cannot be loaded")
                }
            }
        }
    }
    
    
}
