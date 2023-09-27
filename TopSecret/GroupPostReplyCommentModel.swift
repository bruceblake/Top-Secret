//
//  GroupPostReplyCommentModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 3/10/23.
//

import Foundation
import Firebase


struct GroupPostReplyCommentModel : Identifiable{
    var id: String?
    var text: String?
    var timeStamp: Timestamp?
    var likedListID: [String]?
    var likedList : [User]?
    var dislikedListID: [String]?
    var dislikedList: [User]?
    var creatorID: String?
    var creator: User?
    var parentCommentID: String?
    var repliedCommentsCount: Int?
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.text = dictionary["text"] as? String ?? ""
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.creatorID = dictionary["creatorID"] as? String ?? " "
        self.creator = dictionary["creator"] as? User ?? User()
        self.likedList = dictionary["likedList"] as? [User] ?? []
        self.likedListID = dictionary["likedListID"] as? [String] ?? []
        self.dislikedList = dictionary["dislikedList"] as? [User] ?? []
        self.dislikedListID = dictionary["dislikedListID"] as? [String] ?? []
        self.parentCommentID = dictionary["parentCommentID"] as? String ?? " "
        self.repliedCommentsCount = dictionary["repliedCommentsCount"] as? Int ?? 0

    }
    
    init(){
        self.id = UUID().uuidString
    }
}
