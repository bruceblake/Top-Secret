//
//  ChatModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/8/21.
//

import Foundation
import Firebase
import SwiftUI

struct ChatModel : Identifiable {
    var id: String = UUID().uuidString
    var name: String = ""
    var memberAmount: Int = 1
    var usersID : [String]?
    var usersTypingID : [String] = []
    var usersIdlingID : [String] = []
    var users: [User]?
    var usersTyping : [User] = []
    var usersIdling : [User] = []
    var dateCreated: Date = Date()
    var messages : [Message] = [ ]
    var groupID : String?
    var chatType : String = ""
    var nameColors : [[String:String]] = [[:]] //first string is the userID, second is the color picked
    var colorPicker : Int?
    var lastMessageID: String?
    var lastMessage: Message?
    var usersThatHaveSeenLastMessage : [String]?
    var lastActionDate: Timestamp?
    var firstChat: Bool?
    var draftText: String?
    var group: GroupModel?
    var profileImage: String?
    
    init(dictionary:[String:Any]){
        self.id = dictionary["id"] as? String ?? " "
        self.name = dictionary["name"] as? String ?? " "
        self.memberAmount = dictionary["memberAmount"] as? Int ?? 1
        self.users = dictionary["users"] as? [User] ?? []
        self.usersTyping = dictionary["usersTyping"] as? [User] ?? []
        self.usersIdling = dictionary["usersIdling"] as? [User] ?? []
        self.usersID = dictionary["usersID"] as? [String] ?? []
        self.usersTypingID = dictionary["usersTypingID"] as? [String] ?? []
        self.usersIdlingID = dictionary["usersIdlingID"] as? [String] ?? []
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.messages = dictionary["messages"] as? [Message] ?? [ ]
        self.groupID = dictionary["groupID"] as? String ?? " "
        self.chatType = dictionary["chatType"] as? String ?? " "
        self.nameColors = dictionary["nameColors"] as? [[String:String]] ?? [["":""]]
        self.colorPicker = dictionary["colorPicker"] as? Int ?? 0
        self.lastMessage = dictionary["lastMessage"] as? Message ?? Message()
        self.lastMessageID = dictionary["lastMessageID"] as? String ?? ""
        self.usersThatHaveSeenLastMessage = dictionary["usersThatHaveSeenLastMessage"] as? [String] ?? []
        self.lastActionDate = dictionary["lastActionDate"] as? Timestamp ?? Timestamp()
        self.firstChat = dictionary["firstChat"] as? Bool ?? false
        self.draftText = dictionary["draftText"] as? String ?? ""
        self.group = dictionary["group"] as? GroupModel ?? GroupModel()
        self.profileImage = dictionary["profileImage"] as? String ?? " "
    }
    init(){
        self.id = UUID().uuidString
    }
   
   
}
