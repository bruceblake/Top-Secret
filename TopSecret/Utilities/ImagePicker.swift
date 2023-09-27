//
//  ImagePicker.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/28/21.
//

import SwiftUI


struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var avatarImage : UIImage
    var allowsEditing : Bool
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = allowsEditing
        return picker
    }
    
    
    
    //Not important but still needed
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(imagePicker: self)
    }
    

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let imagePicker : ImagePicker
        
        
        init(imagePicker: ImagePicker){
            self.imagePicker = imagePicker
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.editedImage] as? UIImage{
                imagePicker.avatarImage = image
            }else if let image = info[.originalImage] as? UIImage{
                imagePicker.avatarImage = image
            }
            else{
                print("Invalid Image!")
            }
            picker.dismiss(animated: true)
        }
        
    }
    
}


