//
//  StoryModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/26/22.
//

import Foundation
import SwiftUI
import Photos
import Firebase



struct StoryModel : Identifiable {
    var id : String = UUID().uuidString
    var URL: String?
    var image: UIImage?
    var groupID: String?
    var creatorID: String?
    var dateCreated: Timestamp?
    var usersSeenStory : [String]?
    
    
    init(dictionary: [String:Any]){
        self.URL = dictionary["URL"] as? String ?? ""
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.creatorID = dictionary["creatorID"] as? String ?? ""
        self.usersSeenStory = dictionary["usersSeenStory"] as? [String] ?? []
        self.dateCreated = dictionary["dateCreated"] as? Timestamp ?? Timestamp()
        self.id = dictionary["id"] as? String ?? ""
        self.image = dictionary["image"] as? UIImage ?? UIImage()
    }
    
    init(){
        self.id = UUID().uuidString
    }
}
