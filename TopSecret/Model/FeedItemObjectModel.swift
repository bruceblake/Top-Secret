//
//  FeedItemObjectModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/16/22.
//

import Foundation
import Firebase

struct FeedItemObjectModel: Identifiable, Hashable{
    static func == (lhs: FeedItemObjectModel, rhs: FeedItemObjectModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    var id = UUID().uuidString
    var timeStamp : Timestamp?
    var event : EventModel?
    var poll: PollModel?
    var notification : GroupNotificationModel?
    var itemType : ItemType?
    var groupID: String?
    
    enum ItemType{
        case event
        case poll
        case post
        case notification
        case unknown
    }
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.event = dictionary["event"] as? EventModel ?? EventModel()
        self.poll = dictionary["poll"] as? PollModel ?? PollModel()
        self.itemType = dictionary["itemType"] as? ItemType ?? ItemType.unknown
        self.notification = dictionary["notification"] as? GroupNotificationModel ?? GroupNotificationModel()
        self.groupID = dictionary["groupID"] as? String ?? " "
    }
    
    init(){
        self.id = UUID().uuidString
    }
}
