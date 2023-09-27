////
////  GalleryRepository.swift
////  TopSecret
////
////  Created by Bruce Blake on 3/1/22.
////
//
//import Foundation
//import Firebase
//import SwiftUI
//
//
//class GalleryRepository : ObservableObject {
//    
//    @Published var galleryPosts : [GalleryPostModel] = []
//
//    
//    
//    func createGalleryPost(groupID: String, posts: [UIImage], description: String, creatorID: String, isPrivate: Bool, taggedUsers: [String]){
//        var id = UUID().uuidString
//        COLLECTION_GROUP.document(groupID).collection("Gallery Posts").document(id).setData(["id":id,"viewers":
//    [],"groupID":groupID,"taggedUsers":taggedUsers,"description":description,"creator":creatorID,"isPrivate":isPrivate,"dateCreated":Timestamp()])
//        COLLECTION_GALLERY_POSTS.document(id).setData(["id":id,"viewers":
//                                                        [],"groupID":groupID,"taggedUsers":taggedUsers,"description":description,"creatorID":creatorID,"isPrivate":isPrivate,"dateCreated":Timestamp()])
//        COLLECTION_GALLERY_POSTS.document("Comment Manager").setData(["ranking":[:],"id":"Comment Manager"])
//        
//            self.persistImageToStorage(groupID: groupID, galleryID: id, images: posts)
//        
//        
//        
//    }
//    
//
//    
//    
//    func deleteGalleryPost(galleryPostID: String, groupID: String){
//        COLLECTION_GROUP.document(groupID).collection("Gallery Posts").document(galleryPostID).delete()
//        COLLECTION_GALLERY_POSTS.document(galleryPostID).delete()
//      
//    }
//    
//    
//    func fetchGroupGalleryPosts(groupID: String){
//        COLLECTION_GROUP.document(groupID).collection("Gallery Posts").getDocuments { snapshot, err in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//            
//            self.galleryPosts = snapshot!.documents.map({ queryDocumentSnapshot -> GalleryPostModel in
//                let data = queryDocumentSnapshot.data()
//                
//                return GalleryPostModel(dictionary: data)
//            })
//        }
//    }
//    
//    
//    func persistImageToStorage(groupID: String, galleryID: String, images: [UIImage]) {
//       let fileName = "galleryPosts/\(galleryID)"
//        let ref = Storage.storagae().reference(withPath: fileName)
//        var imageURLS : [String] = []
//        
//        let dispatchGroup = DispatchGroup()
//        
//        for image in images{
//            guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
//            
//            dispatchGroup.enter()
//            ref.putData(imageData, metadata: nil) { (metadata, err) in
//                if err != nil{
//                    print("ERROR")
//                    return
//                }
//                   ref.downloadURL { (url, err) in
//                    if err != nil{
//                        print("ERROR: Failed to retreive download URL")
//                        return
//                    }
//                    print("Successfully stored image in database")
//                    var imageURL = url?.absoluteString ?? ""
//                       imageURLS.append(imageURL)
//                       
//                       dispatchGroup.leave()
//                     
//                }
//            }
//         
//           
//        
//        
//      
//  
//          
//        }
//        dispatchGroup.notify(queue: .main){
//            COLLECTION_GALLERY_POSTS.document(galleryID).updateData(["posts":imageURLS])
//            COLLECTION_GROUP.document(groupID).collection("Gallery Posts").document(galleryID).updateData(["posts":imageURLS])
//            print("images saved!")
//        }
//       
//      
//    }
//    
//    func addComment(galleryID: String, groupID: String, userID: String, text: String){
//        let id = UUID().uuidString
//        let data = ["id":id,"text":text,"dateCreated":Timestamp(),"creator":userID,"likes":0,"galleryPostID":galleryID,"groupID":groupID] as [String:Any]
//        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").document(id).setData(data)
//        COLLECTION_GALLERY_POSTS.document(galleryID).updateData(["comments":FieldValue.arrayUnion([id])])
//        print("\(userID) added comment")
//    }
//    
//    
//    
//    
////    func likePost(galleryID: String, groupID: String, userID: String){
////        COLLECTION_GALLERY_POSTS.document(galleryID).updateData(["likes":FieldValue.arrayUnion([userID])])
////
////    }
////
////    func unlikePost(galleryID: String, groupID: String, userID: String){
////        COLLECTION_GALLERY_POSTS.document(galleryID).updateData(["likes":FieldValue.arrayRemove([userID])])
////    }
//    
//   
////
////    func userHasAlreadyLikedPost(userID: String, likes: [String]) -> Bool{
////        return likes.contains(userID)
////    }
//   
//    
//    
////    func userHasAlreadySeenPost(userID: String, usersSeen: [String]) -> Bool {
////
////    }
//    
//    
//    func fetchPostComments(galleryID: String, groupID: String, completion: @escaping ([GalleryPostCommentModel]) -> ()) -> (){
//        COLLECTION_GALLERY_POSTS.document(galleryID).collection("Comments").order(by: "likes", descending: true).getDocuments { snapshot, err in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//            
//            let documents = snapshot!.documents
//            
//            var ans : [GalleryPostCommentModel] = []
//            let dispatchGroup = DispatchGroup()
//
//            dispatchGroup.enter()
//            for document in documents {
//                
//                 let data = document.data()
//                 let id = data["id"] as? String ?? " "
//                 let text = data["text"] as? String ?? ""
//                 let dateCreated = data["dateCreated"] as? Timestamp ?? Timestamp()
//                 let likes = data["likes"] as? Int ?? 0
//                let usersLiked = data["usersLiked"] as? [String] ?? []
//                 let creator = data["creator"] as? String ?? " "
//                 var groupID = data["groupID"] as? String ?? " "
//                 var galleryPostID = data["galleryPostID"] as? String ?? " "
//                 var user : User = User()
//                dispatchGroup.enter()
//                 self.fetchUser(userID: creator) { fetchedUser in
//                   user = fetchedUser
//                     dispatchGroup.leave()
//                 }
//                
//                
//                
//                dispatchGroup.notify(queue: .main){
//                    
//                    ans.append(GalleryPostCommentModel(dictionary: ["id":id,"text":text,"dateCreated":dateCreated,"likes":likes,"creator":creator,"user":user,"galleryPostID":galleryPostID,"groupID":groupID,"usersLiked":usersLiked]))
//
//                }
//                
//            }
//            
//            dispatchGroup.leave()
//            dispatchGroup.notify(queue: .main){
//                return completion(ans)
//            }
//            
//            
//            
//         
//            
//           
//            
//        }
//    }
//    
// 
//    
//    func fetchGalleryPost(galleryPostID: String, completion: @escaping (GalleryPostModel) -> ()) -> (){
//        COLLECTION_GALLERY_POSTS.document(galleryPostID).getDocument { snapshot, err in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//            
//            let data = snapshot!.data()
//            
//            return completion(GalleryPostModel(dictionary: data ?? [:]))
//            
//        }
//    }
//    
//    
//    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
//        COLLECTION_USER.document(userID).getDocument { snapshot, err in
//            if err != nil {
//                print("ERROR")
//                return
//            }
//            
//            let data = snapshot!.data()
//            
//            return completion(User(dictionary: data ?? [:]))
//        }
//    }
//
// 
//    
//}
