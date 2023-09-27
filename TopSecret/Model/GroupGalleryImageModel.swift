//
//  GroupGalleryImageModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/30/22.
//

import Foundation
import SwiftUI
import Firebase

struct GroupGalleryModel : Identifiable{
    var id : String?
    var url : String?
    var image : UIImage?
    var creatorID: String?
    var creator : User?
    var timeStamp: Timestamp?
    var isPrivate : Bool?
    var isImage : Bool?
    var favoritedListID : [String]?
    var favoritedList: [User]?
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.url = dictionary["url"] as? String ?? " "
        self.image = dictionary["image"] as? UIImage ?? UIImage()
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.creatorID = dictionary["creatorID"] as? String ?? " "
        self.creator = dictionary["creator"] as? User ?? User()
        self.isPrivate = dictionary["isPrivate"] as? Bool ?? false
        self.isImage = dictionary["isImage"] as? Bool ?? false
        self.favoritedListID = dictionary["favoritedListID"] as? [String] ?? []
        self.favoritedList = dictionary["favoritedList"] as? [User] ?? []
        
    }
    
    init(){
        self.id = UUID().uuidString
    }
}
