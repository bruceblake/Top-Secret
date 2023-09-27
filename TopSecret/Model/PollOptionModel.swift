//
//  PollOptionModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/1/22.
//

import Foundation
import Firebase

struct PollOptionModel : Identifiable {
    var id: String = UUID().uuidString
    var choice : String = ""
    var pickedUsers : [User]?
    var pickedUsersID: [String]?
    
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.choice = dictionary["choice"] as? String ?? ""
        self.pickedUsers = dictionary["pickedUsers"] as? [User] ?? []
        self.pickedUsersID = dictionary["pickedUsersID"] as? [String] ?? []
    }
    
    init(){
        self.id = UUID().uuidString
    }
}
