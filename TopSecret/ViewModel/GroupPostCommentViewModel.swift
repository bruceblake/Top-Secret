//
//  GroupPostCommentViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/15/22.
//

import Foundation
import Firebase



class GroupPostCommentViewModel : ObservableObject {
    
    @Published var comments: [GroupPostCommentModel] = []
    @Published var hasFetchedComments: Bool = false
    
    func fetchComment(postID: String, commentID: String, completion: @escaping (GroupPostCommentModel) -> ()) -> (){
        COLLECTION_POSTS.document(postID).collection("Comments").document(commentID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let dp = DispatchGroup()
            var data = snapshot?.data() as! [String:Any]
            var usersLikedID = data["usersLikedID"] as? [String] ?? []
            var creatorID = data["creatorID"] as? String ?? " "
            
            dp.enter()
            self.fetchUsersLiked(usersLikedID: usersLikedID) { fetchedUsers in
                data["usersLiked"] = fetchedUsers
                dp.leave()
            }
            
            dp.enter()
            self.fetchCreator(creatorID: creatorID) { fetchedCreator in
                data["creator"] = fetchedCreator
                dp.leave()
            }
            
            
            dp.notify(queue: .main, execute:{
                return completion(GroupPostCommentModel(dictionary: data))
            })
        }
    }
    
    func fetchComments(postID: String, parentCommentID: String = ""){
        if parentCommentID != ""{
            fetchReplies(postID: postID, parentCommentID: parentCommentID)
        }else{
            COLLECTION_POSTS.document(postID).collection("Comments").getDocuments { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                var commentsToReturn : [GroupPostCommentModel] = []
                let dp = DispatchGroup()
                
                let documents = snapshot!.documents
                dp.enter()
                for document in documents {
                    var data = document.data()
                    var usersLikedID = data["usersLikedID"] as? [String] ?? []
                    var creatorID = data["creatorID"] as? String ?? " "
                    var id = data["id"] as? String ?? " "
                    dp.enter()
                    self.fetchUsersLiked(usersLikedID: usersLikedID) { fetchedUsers in
                        data["usersLiked"] = fetchedUsers
                        dp.leave()
                    }
                    
                    dp.enter()
                    self.fetchCreator(creatorID: creatorID) { fetchedCreator in
                        data["creator"] = fetchedCreator
                        dp.leave()
                    }
                    dp.enter()
                    self.fetchRepliesCount(postID: postID, parentCommentID: id) { fetchedRepliesCount in
                        data["repliedCommentsCount"] = fetchedRepliesCount
                        dp.leave()
                    }
                    
                    
                    dp.notify(queue: .main, execute:{
                        commentsToReturn.append(GroupPostCommentModel(dictionary: data))
                    })
                    
                }
                dp.leave()
                dp.notify(queue: .main, execute: {
                    self.comments = commentsToReturn
                    self.hasFetchedComments = true
                })
            }
        }
       
    }
    
    func fetchRepliesCount(postID: String, parentCommentID: String, completion: @escaping (Int) -> ()) -> (){
        COLLECTION_POSTS.document(postID).collection("Comments").whereField("parentCommentID", isEqualTo: parentCommentID).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var commentsToReturn : [GroupPostCommentModel] = []
            let dp = DispatchGroup()
            
            let documents = snapshot!.documents
            return completion(documents.count)
        }
    }
    
    func fetchReplies(postID: String, parentCommentID: String) {
        COLLECTION_POSTS.document(postID).collection("Comments").whereField("parentCommentID", isEqualTo: parentCommentID).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var commentsToReturn : [GroupPostCommentModel] = []
            let dp = DispatchGroup()
            
            let documents = snapshot!.documents
            dp.enter()
            for document in documents {
                var data = document.data()
                var usersLikedID = data["usersLikedID"] as? [String] ?? []
                var creatorID = data["creatorID"] as? String ?? " "
                
                dp.enter()
                self.fetchUsersLiked(usersLikedID: usersLikedID) { fetchedUsers in
                    data["usersLiked"] = fetchedUsers
                    dp.leave()
                }
                
                dp.enter()
                self.fetchCreator(creatorID: creatorID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dp.leave()
                }
                
                
                dp.notify(queue: .main, execute:{
                    commentsToReturn.append(GroupPostCommentModel(dictionary: data))
                })
                
            }
            dp.leave()
            dp.notify(queue: .main, execute: {
                self.comments = commentsToReturn
                self.hasFetchedComments = true
            })
        }
    }
    
    func fetchCreator(creatorID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(creatorID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(User(dictionary: data))
        }
    }
    
    func fetchUsersLiked(usersLikedID: [String], completion: @escaping ([User]) -> () ) -> () {
        let dp = DispatchGroup()
        var usersToReturn: [User] = []
        dp.enter()
        for user in usersLikedID{
            COLLECTION_USER.document(user).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                usersToReturn.append(User(dictionary: data))
            }
        }
        dp.leave()
        dp.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    
    
    
    
    
    func addComment(postID: String, userID: String, text: String, parentCommentID: String = ""){
        let id = UUID().uuidString
        var data = ["id":id,
                    "text":text,
                    "timeStamp":Timestamp(),
                    "creatorID":userID,
                    "postID":postID] as [String:Any]
        if parentCommentID != ""{
            data["parentCommentID"] = parentCommentID
            COLLECTION_POSTS.document(postID).collection("Comments").document(parentCommentID).updateData(["repliedCommentsCount":FieldValue.increment(Int64(1))])
        }else {
            data["parentCommentID"] = "nil"
        }
        
        
        COLLECTION_POSTS.document(postID).collection("Comments").document(id).setData(data)
        COLLECTION_POSTS.document(postID).updateData(["commentsCount":FieldValue.increment(Int64(1))])
    }
    
    func updateGroupPostUserCommentLike(postID: String, userID: String, commentID: String, actionToLike: Bool, completion: @escaping ([[String]]) -> ()) -> (){
        
        //user has liked post and not disliked
        //user has disliked and not liked
        
       let dp = DispatchGroup()
        COLLECTION_POSTS.document(postID).collection("Comments").document(commentID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
                
                
                
            }
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            var likedListID = data["likedListID"] as? [String] ?? []
            var dislikedListID = data["dislikedListID"] as? [String] ?? []
            
            if likedListID.contains(userID){
                // if user already liked, and goal is to dislike, then remove like and dislike
                //if user already liked, and goal is to like, remove like
                dp.enter()

                if !actionToLike{
                  
                    COLLECTION_POSTS.document(postID).collection("Comments").document(commentID).updateData(["dislikedListID":FieldValue.arrayUnion([userID])])
                    dislikedListID.append(userID)
                }
                
                COLLECTION_POSTS.document(postID).collection("Comments").document(commentID).updateData(["likedListID":FieldValue.arrayRemove([userID])])
                likedListID.removeAll(where: {$0 == userID})

                dp.leave()
                dp.notify(queue: .main, execute:{
                 
                    return completion([likedListID, dislikedListID])
                })
               
            }else if dislikedListID.contains(userID){
                //if user has already disliked, and goal is to like, then remove dislike and like
                //if user has already disliked, and goal is to dislike, then remove dislike
                dp.enter()
                if actionToLike{
                  
                    //like
                    COLLECTION_POSTS.document(postID).collection("Comments").document(commentID).updateData(["likedListID":FieldValue.arrayUnion([userID])])
                    likedListID.append(userID)

                }
                
                COLLECTION_POSTS.document(postID).collection("Comments").document(commentID).updateData(["dislikedListID":FieldValue.arrayRemove([userID])])
                dislikedListID.removeAll(where: {$0 == userID})

                
                dp.leave()
                dp.notify(queue: .main, execute:{
                 
                    return completion([likedListID, dislikedListID])

                })
            }
            else{
                dp.enter()
                if actionToLike{
                    COLLECTION_POSTS.document(postID).collection("Comments").document(commentID).updateData(["likedListID":FieldValue.arrayUnion([userID])])
                    likedListID.append(userID)
                }else{
                    COLLECTION_POSTS.document(postID).collection("Comments").document(commentID).updateData(["dislikedListID":FieldValue.arrayUnion([userID])])
                    dislikedListID.append(userID)
                }
                
                dp.leave()
                dp.notify(queue: .main, execute:{
                 
                    return completion([likedListID, dislikedListID])

                })
             
            }
            
        }
       

    }
    
    func updateGroupPostCommentsSectionLike(postID: String, userID: String, actionToLike: Bool, completion: @escaping ([[String]]) -> ()) -> (){
        
        //user has liked post and not disliked
        //user has disliked and not liked
        
       let dp = DispatchGroup()
        COLLECTION_POSTS.document(postID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
                
                
                
            }
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            var likedListID = data["commentsLikedListID"] as? [String] ?? []
            var dislikedListID = data["commentsDislikedListID"] as? [String] ?? []
            
            if likedListID.contains(userID){
                // if user already liked, and goal is to dislike, then remove like and dislike
                //if user already liked, and goal is to like, remove like
                dp.enter()

                if !actionToLike{
                  
                    COLLECTION_POSTS.document(postID).updateData(["commentsDislikedListID":FieldValue.arrayUnion([userID])])
                    dislikedListID.append(userID)
                }
                
                COLLECTION_POSTS.document(postID).updateData(["commentsLikedListID":FieldValue.arrayRemove([userID])])
                likedListID.removeAll(where: {$0 == userID})

                dp.leave()
                dp.notify(queue: .main, execute:{
                 
                    return completion([likedListID, dislikedListID])
                })
               
            }else if dislikedListID.contains(userID){
                //if user has already disliked, and goal is to like, then remove dislike and like
                //if user has already disliked, and goal is to dislike, then remove dislike
                dp.enter()
                if actionToLike{
                  
                    //like
                    COLLECTION_POSTS.document(postID).updateData(["commentsLikedListID":FieldValue.arrayUnion([userID])])
                    likedListID.append(userID)

                }
                
                COLLECTION_POSTS.document(postID).updateData(["commentsDislikedListID":FieldValue.arrayRemove([userID])])
                dislikedListID.removeAll(where: {$0 == userID})

                
                dp.leave()
                dp.notify(queue: .main, execute:{
                 
                    return completion([likedListID, dislikedListID])

                })
            }
            else{
                dp.enter()
                if actionToLike{
                    COLLECTION_POSTS.document(postID).updateData(["commentsLikedListID":FieldValue.arrayUnion([userID])])
                    likedListID.append(userID)
                }else{
                    COLLECTION_POSTS.document(postID).updateData(["commentsDislikedListID":FieldValue.arrayUnion([userID])])
                    dislikedListID.append(userID)
                }
                
                dp.leave()
                dp.notify(queue: .main, execute:{
                 
                    return completion([likedListID, dislikedListID])

                })
             
            }
            
        }
       

    }
}
