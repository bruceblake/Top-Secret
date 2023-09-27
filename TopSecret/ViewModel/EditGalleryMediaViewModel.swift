//
//  EditGalleryMediaViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/16/23.
//

import Foundation
import Firebase

class EditGalleryMediaViewModel : ObservableObject {
    @Published var media : GroupGalleryModel = GroupGalleryModel()
    @Published var isLoading: Bool = false
    func favoriteMedia(mediaID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Gallery").document(mediaID).updateData(["favoritedListID":FieldValue.arrayUnion([USER_ID])])
    }
    
    func unfavoriteMedia(mediaID: String, groupID: String){
        COLLECTION_GROUP.document(groupID).collection("Gallery").document(mediaID).updateData(["favoritedListID":FieldValue.arrayRemove([USER_ID])])
    }
    func userHasFavorited(userID: String) -> Bool {
        return media.favoritedListID?.contains(userID) ?? false
    }
    
    func fetchGalleryMedia(groupID: String, mediaID: String){
        let groupD = DispatchGroup()
        groupD.enter()
        self.isLoading = true
        COLLECTION_GROUP.document(groupID).collection("Gallery").document(mediaID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var doc = snapshot?.data() as? [String:Any] ?? [:]
            var creatorID = doc["creatorID"] as? String ?? ""
            
            groupD.enter()
            self.fetchUser(userID: creatorID) { fetchedUser in
                doc["creator"] = fetchedUser
                groupD.leave()
            }
            
            groupD.leave()
            groupD.notify(queue: .main, execute:{
                self.media = GroupGalleryModel(dictionary: doc)
                self.isLoading = false
            })
            
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
}

