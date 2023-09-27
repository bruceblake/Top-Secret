//
//  GroupProfileViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/20/22.
//

import Firebase
import SwiftUI
import Foundation
import FirebaseStorage

class GroupProfileViewModel : ObservableObject{
    @Published var posts: [GroupPostModel] = []
    @Published var isLoading : Bool = false
    
    
    
    func fetchPosts(userID: String, groupID: String){
        self.isLoading = true
        var groupD = DispatchGroup()
        
        COLLECTION_GROUP.document(groupID).collection("Posts").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            var documents = snapshot!.documents
            
            for doc in documents{
                var docData = doc.data() as? [String:Any] ?? [:]
                var path = doc["urlPath"] as? String ?? " "
    
                let storageRef = Storage.storage().reference()
                
                let fileRef = storageRef.child(path)
                
                fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
                    
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    if let image = UIImage(data: data!){
                        docData["image"] = image
                        DispatchQueue.main.async {
                            self.posts.append(GroupPostModel(dictionary: docData))
                        }
                    }
                    
                }
            }
        }
    }
}
