//
//  ShareViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/30/22.
//

import Foundation
import Firebase

class ShareViewModel : ObservableObject{
    
    @Published var sendStatus = SendStatus.notSending
    @Published var showShareMenu: Bool = false
    @Published var shareType: String = ""
    @Published var selectedPoll : PollModel = PollModel()
    @Published var selectedEvent : EventModel = EventModel()
    @Published var selectedPost : GroupPostModel = GroupPostModel()
    
    enum SendStatus {
        case notSending
        case sending
        case sent
    }
    
    enum SendType {
        case poll
        case event
        case post
    }
    
    func sendEventMessage(eventID: String, user: User, chatID: String){
        self.sendStatus = .sending
        let messageID = UUID().uuidString
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":Timestamp(),
                               "id":messageID,
                               "profilePicture":user.profilePicture ?? "",
                               "type":"eventMessage",
                               "value":eventID,
                               "userID":user.id ?? ""] as! [String:Any]
        
        let dp = DispatchGroup()
        
        dp.enter()
        
                COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).setData(textMessageData)
        dp.leave()
        
        dp.notify(queue: .main, execute:{
         
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":messageID])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
            self.sendStatus = .sent
          
        })
    }
    
    func sendPollMessage(pollID: String, user: User, chatID: String){
        self.sendStatus = .sending

        let messageID = UUID().uuidString
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":Timestamp(),
                               "id":messageID,
                               "profilePicture":user.profilePicture ?? "",
                               "type":"pollMessage",
                               "value":pollID,
                               "userID":user.id ?? ""] as! [String:Any]
        
        let dp = DispatchGroup()
        
        dp.enter()
        
                COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).setData(textMessageData)
        dp.leave()
        
        dp.notify(queue: .main, execute:{
         
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":messageID])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
            self.sendStatus = .sent
          
        })
        
    }
    
    func sendPostMessage(postID: String, user: User, chatID: String){
        self.sendStatus = .sending

        let messageID = UUID().uuidString
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":Timestamp(),
                               "id":messageID,
                               "profilePicture":user.profilePicture ?? "",
                               "type":"postMessage",
                               "value":postID,
                               "userID":user.id ?? ""] as! [String:Any]
        let dp = DispatchGroup()
        
        dp.enter()
        
                COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).setData(textMessageData)
        dp.leave()
        
        dp.notify(queue: .main, execute:{
         
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":messageID])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
           
            self.sendStatus = .sent

          
        })
        
        
    }
    
}
