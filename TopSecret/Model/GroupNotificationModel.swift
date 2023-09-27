//
//  GroupNotificationModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import Foundation
import SwiftUI
import Firebase


struct GroupNotificationModel : Identifiable {
    var id: String = UUID().uuidString
    var timeStamp : Timestamp?
    var type: String?
    var senderID: String?
    var sender: User?
    var receiverID: String?
    var receiver: User?
    var usersThatHaveSeen : [String]?
    var requiresAction: Bool?
    
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.type = dictionary["type"] as? String ?? "NOTIFICATION_TYPE"
        self.usersThatHaveSeen = dictionary["usersThatHaveSeen"] as? [String] ?? []
        self.receiverID = dictionary["receiverID"] as? String ?? "RECEIVER_ID"
        self.receiver = dictionary["receiver"] as? User ?? User()
        self.senderID = dictionary["senderID"] as? String ?? "SENDER_ID"
        self.sender = dictionary["sender"] as? User ?? User()
        self.requiresAction = dictionary["requiresAction"] as? Bool ?? false
    }
    
    
    
   
    init(){
        self.id = UUID().uuidString
    }
    
}
