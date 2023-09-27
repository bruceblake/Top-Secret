//
//  ReplyMessageModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/24/22.
//

import Foundation
import Firebase

struct ReplyMessageModel : Identifiable{
    var id : String
    var nameColor: String?
    var userID: String?
    var timeStamp: Timestamp?
    var value : String?
    var name : String?
    var edited: Bool?
    var type: String?
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.nameColor = dictionary["nameColor"] as? String ?? ""
        self.userID = dictionary["userID"] as? String ?? ""
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.value = dictionary["value"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.edited = dictionary["edited"] as? Bool ?? false
        self.type = dictionary["type"] as? String ?? ""
    }
    
    init(){
        self.id = UUID().uuidString
    }
}
