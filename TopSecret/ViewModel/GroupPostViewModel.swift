//
//  GroupPostViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 3/31/23.
//

import Foundation
import Firebase

class GroupPostViewModel : ObservableObject {
    
    
    func viewPost(postID: String, userID: String){
        COLLECTION_POSTS.document(postID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            let data = snapshot?.data() as? [String:Any] ?? [:]
            var viewers = data["viewers"] as? [String] ?? []
            if !viewers.contains(where: {$0 == userID}){
                COLLECTION_POSTS.document(postID).updateData(["viewers":FieldValue.arrayUnion([userID])])
            }
        }
    }
}
