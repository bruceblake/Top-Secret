//
//   MessageModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/5/21.
//

import Foundation
import SwiftUI
import Firebase


struct Message : Identifiable, Hashable, Decodable, Encodable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    func encode(to encoder: Encoder) throws {
           var container = encoder.container(keyedBy: CodingKeys.self)
           try container.encode(id, forKey: .id)
           try container.encodeIfPresent(nameColor, forKey: .nameColor)
           try container.encode(userID, forKey: .userID)
           try container.encodeIfPresent(timeStamp, forKey: .timeStamp)
           try container.encodeIfPresent(name, forKey: .name)
           try container.encodeIfPresent(value, forKey: .value)
           try container.encodeIfPresent(profilePicture, forKey: .profilePicture)
           try container.encodeIfPresent(type, forKey: .type)
           try container.encodeIfPresent(edited, forKey: .edited)
           try container.encodeIfPresent(usersThatHaveSeen, forKey: .usersThatHaveSeen)
           try container.encodeIfPresent(repliedMessageID, forKey: .repliedMessageID)
           try container.encodeIfPresent(urls, forKey: .urls)
           try container.encodeIfPresent(thumbnailUrl, forKey: .thumbnailUrl)
           try container.encodeIfPresent(thumbnailUrls, forKey: .thumbnailUrls)
       }
    
    var id: String
    var nameColor: String?
    var userID : String
    var user: User?
    var timeStamp : Timestamp?
    var name : String?
    var value : String?
    var profilePicture: String?
    var type: String?
    var edited: Bool?
    var usersThatHaveSeen : [String]?
    var repliedMessageID: String?
    var repliedMessage: ReplyMessageModel?
    var event: EventModel?
    var post: GroupPostModel?
    var poll: PollModel?
    var urls: [String]?
    
    //keep these 2 separate between sending multiple images & videos compared to sending a single image or video
    var thumbnailUrl: String?
    var thumbnailUrls: [String]?
    
    
    init(dictionary: [String:Any]){
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.name = dictionary["name"] as? String ?? " "
        self.profilePicture = dictionary["profilePicture"] as? String ?? " "
        self.id = dictionary["id"] as? String ?? " "
        self.nameColor = dictionary["nameColor"] as? String ?? " "
        self.value = dictionary["value"] as? String ?? ""
        self.type = dictionary["type"] as? String ?? ""
        self.userID = dictionary["userID"] as? String ?? " "
        self.user = dictionary["user"] as? User ?? User()
        self.edited = dictionary["edited"] as? Bool ?? false
        self.usersThatHaveSeen = dictionary["usersThatHaveSeen"] as? [String] ?? []
        self.repliedMessageID = dictionary["repliedMessageID"] as? String ?? ""
        self.repliedMessage = dictionary["repliedMessage"] as? ReplyMessageModel ?? ReplyMessageModel()
        self.event = dictionary["event"] as? EventModel ?? EventModel()
        self.post = dictionary["post"] as? GroupPostModel ?? GroupPostModel()
        self.poll = dictionary["poll"] as? PollModel ?? PollModel()
        self.urls = dictionary["urls"] as? [String] ?? []
        self.thumbnailUrl = dictionary["thumbnailUrl"] as? String ?? ""
        self.thumbnailUrls = dictionary["thumbnailUrls"] as? [String] ?? []
    }
    
    
    init(){
        self.id = UUID().uuidString
        self.userID = UUID().uuidString
    }
  
    
    enum CodingKeys: String, CodingKey {
           case id
           case nameColor
           case userID
           case user
           case timeStamp
           case name
           case value
           case profilePicture
           case type
           case edited
           case usersThatHaveSeen
           case repliedMessageID
           case repliedMessage
           case event
           case post
           case poll
           case urls
           case thumbnailUrl
           case thumbnailUrls
       }

       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           self.id = try container.decode(String.self, forKey: .id)
           self.nameColor = try container.decodeIfPresent(String.self, forKey: .nameColor)
           self.userID = try container.decode(String.self, forKey: .userID)
           self.timeStamp = try container.decode(Timestamp.self, forKey: .timeStamp)
           self.name = try container.decode(String.self, forKey: .name)
           self.value = try container.decode(String.self, forKey: .value)
           self.profilePicture = try container.decode(String.self, forKey: .profilePicture)
           self.type = try container.decode(String.self, forKey: .type)
           self.edited = try container.decode(Bool.self, forKey: .edited)
           self.usersThatHaveSeen = try container.decode([String].self, forKey: .usersThatHaveSeen)
           self.repliedMessageID = try container.decode(String.self, forKey: .repliedMessageID)
           self.urls = try container.decode([String].self, forKey: .urls)
           self.thumbnailUrl = try container.decode(String.self, forKey: .thumbnailUrl)
           self.thumbnailUrls = try container.decode([String].self, forKey: .thumbnailUrls)
       }
    
}


