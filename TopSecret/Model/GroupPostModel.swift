//
//  GroupPostModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 9/6/22.
//

import Foundation
import SwiftUI
import Firebase


struct GroupPostModel : Identifiable {
    var id: String?
    var description: String?
    var image: UIImage?
    var urlPath: String?
    var creatorID: String?
    var creator: User?
    var groupID: String?
    var group: GroupModel?
    var timeStamp : Timestamp?
    var likedListID: [String]?
    var likedList: [User]?
    var dislikedListID: [String]?
    var dislikedList: [User]?
    var commentsLikedListID: [String]?
    var commentsLikedList: [User]?
    var commentsDislikedListID: [String]?
    var commentsDislikedList: [User]?
    var commentsCount: Int?
    var viewers: [String]?
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.description = dictionary["description"] as? String ?? ""
        self.image = dictionary["image"] as? UIImage ?? UIImage()
        self.urlPath = dictionary["urlPath"] as? String ?? ""
        self.creatorID = dictionary["creatorID"] as? String ?? ""
        self.creator = dictionary["creator"] as? User ?? User()
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.group = dictionary["group"] as? GroupModel ?? GroupModel()
        self.likedListID = dictionary["likedListID"] as? [String] ?? []
        self.likedList = dictionary["likedList"] as? [User] ?? []
        self.dislikedListID = dictionary["dislikedListID"] as? [String] ?? []
        self.dislikedList = dictionary["dislikedList"] as? [User] ?? []
        self.commentsLikedListID = dictionary["commentsLikedListID"] as? [String] ?? []
        self.commentsLikedList = dictionary["commentsLikedList"] as? [User] ?? []
        self.commentsDislikedListID = dictionary["commentsDislikedListID"] as? [String] ?? []
        self.commentsDislikedList = dictionary["commentsDislikedList"] as? [User] ?? []
        self.commentsCount = dictionary["commentsCount"] as? Int ?? 0
        self.viewers = dictionary["viewers"] as? [String] ?? []
    }
    
    
    
    init(){
        self.id = UUID().uuidString
        
    }
}
