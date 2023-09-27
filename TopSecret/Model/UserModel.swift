//
//  UserModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 4/3/21.
//

import Foundation
import Firebase
import SwiftUI
import MapKit
import CoreLocation

struct User : Identifiable, Hashable{
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id : String?
    var username: String?
    var email: String?
    var password: String?
    var nickName: String?
    var birthday: Date?
    var bio: String?
    var profilePicture: String?
    var friendsList : [User]?
    var friendsListID : [String]?
    var blockedAccountsID : [String]?
    var blockedAccounts : [User]?
    var userNotificationCount : Int?
    var incomingFriendInvitationID: [String]?
    var outgoingFriendInvitationID: [String]?
    var pendingGroupInvitationID : [String]?
    var pendingEventInvitationID: [String]?
    var isActive: Bool?
    var lastActive: Timestamp?
    var latitude : Double?
    var longitude : Double?
    var notifications : [UserNotificationModel]?
    var fcmToken : String?
    var groupsID : [String]?
    var recentSearches : [String]?
    var groupChatsID: [String]?
    var groupChats: [ChatModel]?
    var personalChatsID : [String]
    var personalChats : [ChatModel]
    var personalChatNotificationCount : Int?
    var dateCreated : Timestamp?
    var groupsFollowingID: [String]?
    var groupsFollowing: [GroupModel]?
    var hasUnreadMessages : Bool?
    var appIconBadgeNumber : Int?
    var interests: [String]?
    var usersLoggedInCount: Int?
    var eventsID: [String]
    var events: [EventModel]
    var isLocationSharing: Bool
    var lastLocationTime: Timestamp
    var lastLocationName: String

init(dictionary: [String:Any]) {
    self.appIconBadgeNumber = dictionary["appIconBadgeNumber"] as? Int ?? 0
    self.id = dictionary["uid"] as? String ?? " "
    self.username = dictionary["username"] as? String ?? " "
    self.email = dictionary["email"] as? String ?? " "
    self.password = dictionary["password"] as? String ?? ""
    self.nickName = dictionary["nickName"] as? String ?? " "
    self.birthday = dictionary["birthday"] as? Date ?? Date()
    self.profilePicture = dictionary["profilePicture"] as? String ?? ""
    self.bio = dictionary["bio"] as? String ?? "This is my bio"
    self.friendsList = dictionary["friendsList"] as? [User] ?? []
    self.friendsListID = dictionary["friendsListID"] as? [String] ?? []
    self.incomingFriendInvitationID = dictionary["incomingFriendInvitationID"] as? [String] ?? []
    self.outgoingFriendInvitationID = dictionary["outgoingFriendInvitationID"] as? [String] ?? []
    self.blockedAccountsID = dictionary["blockedAccountsID"] as? [String] ?? []
    self.blockedAccounts = dictionary["blockedAccounts"] as? [User] ?? []
    self.userNotificationCount = dictionary["userNotificationCount"] as? Int ?? 0

    self.isActive = dictionary["isActive"] as? Bool ?? false
    self.lastActive = dictionary["lastActive"] as? Timestamp ?? Timestamp()

    self.latitude = dictionary["latitude"] as? Double ?? 0
    self.longitude = dictionary["longitude"] as? Double ?? 0
    self.notifications = dictionary["notifications"] as? [UserNotificationModel] ?? []
    self.fcmToken = dictionary["fcmToken"] as? String ?? " "
    self.groupsID = dictionary["groupsID"] as? [String] ?? []
    self.recentSearches = dictionary["recentSearches"] as? [String] ?? []
    self.personalChatsID = dictionary["personalChatsID"] as? [String] ?? []
    self.personalChats = dictionary["personalChats"] as? [ChatModel] ?? []
    self.personalChatNotificationCount = dictionary["personalChatNotificationCount"] as? Int ?? 0
    self.pendingGroupInvitationID = dictionary["pendingGroupInvitationID"] as? [String] ?? []
    self.pendingEventInvitationID = dictionary["pendingEventInvitationID"] as? [String] ?? []
    self.dateCreated = dictionary["dateCreated"] as? Timestamp ?? Timestamp()
    self.groupsFollowingID = dictionary["groupsFollowingID"] as? [String] ?? []
    self.groupsFollowing = dictionary["groupsFollowing"] as? [GroupModel] ?? []
    self.hasUnreadMessages = dictionary["hasUnreadMessages"] as? Bool ?? false
    self.interests = dictionary["interests"] as? [String] ?? []
    self.usersLoggedInCount = dictionary["usersLoggedInCount"] as? Int ?? 0
    self.eventsID = dictionary["eventsID"] as? [String] ?? []
    self.events = dictionary["events"] as? [EventModel] ?? []
    self.isLocationSharing = dictionary["isLocationSharing"] as? Bool ?? false
    self.lastLocationTime = dictionary["lastLocationTime"] as? Timestamp ?? Timestamp()
    self.lastLocationName = dictionary["lastLocationName"] as? String ?? " "
}

    init(){
        self.id = UUID().uuidString
        self.username = "username"
        self.nickName = "nickName" 
        self.personalChatsID = []
        self.personalChats = []
        self.eventsID = []
        self.events = []
        self.isLocationSharing = false
        self.lastLocationTime = Timestamp()
        self.lastLocationName = "unable to fetch location"
    }
    
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
}
