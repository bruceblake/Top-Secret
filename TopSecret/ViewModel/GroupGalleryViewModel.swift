//
//  GroupGalleryViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/30/22.
//

import Foundation
import Firebase
import FirebaseStorage
import SwiftUI
import UIKit

class GroupGalleryViewModel : ObservableObject {
    
    @Published var fetchedAllMedia : [GroupGalleryModel] = []
    @Published var fetchedFavoriteMedia : [GroupGalleryModel] = []
    @Published var isLoading : Bool = true
    
    
    func uploadPhoto(image: UIImage, userID: String, group: GroupModel, isPrivate: Bool, completion: @escaping (Bool) -> ()){
        
      
        
        let storageRef = Storage.storage().reference()
        
        let imageData = image.jpegData(compressionQuality: 0.1)
        
        guard imageData != nil else {
            return completion(false)
        }
        let path = "\(group.groupName)/GroupGalleryImages/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata , err in
            if err == nil && metadata != nil {
                
                fileRef.downloadURL { downloadedURL, err in
                    if err != nil {
                        print("ERROR")
                        return completion(false)
                    }
                    let id = UUID().uuidString
                    let galleryImageData = ["id":id,"url":downloadedURL?.absoluteString ?? " ", "creatorID":userID, "timeStamp":Timestamp(),"isPrivate":false,"isImage":true] as [String:Any]
                    COLLECTION_GROUP.document(group.id).collection("Gallery").document(id).setData(galleryImageData) { err in
                        if err == nil {
                            return completion(true)
                        }
                    }
                    
                }
                
            }
            
        }
    }
    
    func uploadVideo(url: URL, group: GroupModel, completion: @escaping (Bool) -> ()) {
        let data = try! Data(contentsOf: url)
        let storageRef = Storage.storage().reference()
        let path = "\(group.id)/GroupGalleryVideos/\(UUID().uuidString).mp4"
        let fileRef = storageRef.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        let uploadTask = fileRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
                completion(false)
            } else {
                fileRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "unknown error")")
                        completion(false)
                        return
                    }
                    let id = UUID().uuidString
                    let galleryData = ["id":id,"url":url?.absoluteString ?? " ", "creatorID":USER_ID, "timeStamp":Timestamp(),"isPrivate":false,"isImage":false] as [String:Any]
                    COLLECTION_GROUP.document(group.id).collection("Gallery").document(id).setData(galleryData) { err in
                        if let err = err {
                            print("Error writing gallery data: \(err.localizedDescription)")
                            completion(false)
                        } else {
                                completion(true)
                        }
                    }
                }
            }
        }
    }
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
        }
    }
    
    func deleteImage(groupID: String){
        
    }
    
    func fetchPhotos(userID: String, groupID: String, completion: @escaping (Bool) -> ()){
        
        var groupD = DispatchGroup()
        var imagesToReturn : [GroupGalleryModel] = []
        groupD.enter()
        self.isLoading = true
        COLLECTION_GROUP.document(groupID).collection("Gallery").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return completion(false)
            }
           var documents = snapshot!.documents
       

            
            for doc in documents{
                var docData = doc.data() as? [String:Any] ?? [:]
                var creatorID = doc["creatorID"] as? String ?? ""
                
                groupD.enter()
                self.fetchUser(userID: creatorID) { fetchedUser in
                    docData["creator"] = fetchedUser
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute:{
                    imagesToReturn.append(GroupGalleryModel(dictionary: docData))
                })
                   
            }
            
            groupD.leave()
            groupD.notify(queue: .main, execute:{
                self.isLoading = false
                self.fetchedAllMedia = imagesToReturn.sorted{$0.timeStamp?.dateValue() ?? Date() < $1.timeStamp?.dateValue() ?? Date()}
                self.fetchedFavoriteMedia = imagesToReturn.sorted(by: {$0.favoritedListID?.count ?? 0 > $1.favoritedListID?.count ?? 0})
                return completion(true)
            })
        }
        
        
    }
    
    

  
    
    
}


class ImageSaver : NSObject {
    
    func writeToPhotoAlbum(image: UIImage){
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer){
        print("Save Finished!")
    }
}
