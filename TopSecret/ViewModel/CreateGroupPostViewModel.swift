//
//  CreateGroupPostViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 9/6/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

class CreateGroupPostViewModel : ObservableObject {
    
    enum UploadStatus {
        case notStartedUpload
        case startedUpload
        case finishedUpload
    }
    
    @Published var uploadStatus = UploadStatus.notStartedUpload
    
    func createPost(image: UIImage, userID: String, group: GroupModel, description: String){
        let storageRef = Storage.storage().reference()
        let postID = UUID().uuidString
        
        
        let imageData = image.jpegData(compressionQuality: 1)
        
        guard imageData != nil else {return}
        
        let path = "GroupPostImages/\(group.groupName)/\(postID).jpg"
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, err in
            if err == nil && metadata != nil {
                let data = ["id":postID,"urlPath":path,"creatorID":userID,"timeStamp":Timestamp(),"groupID":group.id, "description": description] as? [String : Any] ?? [:]
                
                //place in POSTS collection
                //place inside Group's POSTS collection
                COLLECTION_POSTS.document(postID).setData(data) { err in
                    if err == nil {
                        DispatchQueue.main.async{
                            print("Uploaded Post!")
                            self.uploadStatus = .finishedUpload
                        }
                    }
                    
                }
                
                COLLECTION_GROUP.document(group.id).collection("Posts").document(postID).setData(data) { err in
                    if err == nil {
                        DispatchQueue.main.async{
                            print("Uploaded Post!")
                            self.uploadStatus = .finishedUpload
                        }
                    }
                }
            }
        }
    }
}
