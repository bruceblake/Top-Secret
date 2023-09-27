//
//  GroupModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import Foundation
import SwiftUI
import Firebase



struct GroupModel: Identifiable {
    
   
    
    
    var groupName: String = ""
    var motd: String = ""
    var id: String = UUID().uuidString
    var dateCreated: Date = Date()
    var memberAmount: Int = 0
    var memberLimit: Int = 0
    var usersID: [String] = []
    var users: [User] = []
    var groupProfileImage: String = ""
    var quoteOfTheDay: String = ""
    var bio : String = ""
    var groupNotifications: [GroupNotificationModel] = []
    var unreadGroupNotification: [GroupNotificationModel] = []
    var notificationsCount : Int = 0
    var followersID: [String]?
    var followers: [User]?
    var chatID: String?
    var interests: [String]?
    var eventsID : [String]?

    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? UUID().uuidString
        self.groupName = dictionary["groupName"] as? String ?? "GROUP_NAME"
        self.dateCreated = dictionary["dateCreated"] as? Date ?? Date()
        self.memberAmount = dictionary["memberAmount"] as? Int ?? 0
        self.usersID = dictionary["usersID"] as? [String] ?? []
        self.users = dictionary["users"] as? [User] ?? []
        self.groupProfileImage = dictionary["groupProfileImage"] as? String ?? " "
        self.motd = dictionary["motd"] as? String ?? "Welcome to the group!"
        self.quoteOfTheDay = dictionary["quoteOfTheDay"] as? String ?? ""
        self.bio = dictionary["bio"] as? String ?? ""
        self.groupNotifications = dictionary["groupNotifications"] as? [GroupNotificationModel] ?? []
        self.notificationsCount = dictionary["notificationsCount"] as? Int ?? 0
        self.followersID = dictionary["followersID"] as? [String] ?? []
        self.followers = dictionary["followers"] as? [User] ?? []
        self.interests = dictionary["interests"] as? [String] ?? []
        self.chatID = dictionary["chatID"] as? String ?? " "
        self.eventsID = dictionary["eventsID"] as? [String] ?? []
        
    }
    
    
    init(){
        self.id = UUID().uuidString
    }
    
    
    
    
}





