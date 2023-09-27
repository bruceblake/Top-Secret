//
//  EventViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import Foundation
import Firebase
import SwiftUI
import Combine
import FirebaseStorage
import CoreLocation


class EventViewModel: ObservableObject {
    @Published var description: String = ""
    @Published var finishedFetchingEvent : Bool = false
    @Published var event: EventModel = EventModel()
    @Published var friendsAttending: [User] = []
    @Published var creatingEvent : Bool = false
    @Published var eventListener: ListenerRegistration?
    
    let shared = UserViewModel.shared
    @ObservedObject var chatRepository = ChatRepository()
    
    let notificationSender = PushNotificationSender()
    
    func acceptEventInvitation(){
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "name": "acceptedEventInvitation",
            "timeStamp":Timestamp(),
            "type":"acceptedEventInvitation",
            "eventID": event.id,
            "userID": event.creatorID ?? " ",
            "hasSeen":false] as [String:Any]
        
        for userID in event.usersAttendingID ?? [] {
            COLLECTION_USER.document(userID).collection("Notifications").document(notificationID).setData(userNotificationData)
        }
        
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersAttendingID":FieldValue.arrayUnion([USER_ID])])
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersDeclinedID":FieldValue.arrayRemove([USER_ID])])
        COLLECTION_USER.document(USER_ID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([self.event.id])])
        COLLECTION_USER.document(USER_ID).updateData(["eventsID":FieldValue.arrayUnion([self.event.id])])
    }
    
    func declineEventInvitation(){
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "timeStamp":Timestamp(),
            "type":"decliningEvent",
            "eventID": self.event.id,
            "userID": event.creatorID ?? " ",
            "hasSeen":false] as [String:Any]
        
        for userID in self.event.usersAttendingID ?? [] {
            COLLECTION_USER.document(userID).collection("Notifications").document(notificationID).setData(userNotificationData)
        }
        
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersAttendingID":FieldValue.arrayRemove([USER_ID])])
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersDeclinedID":FieldValue.arrayUnion([USER_ID])])
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersUndecidedID":FieldValue.arrayRemove([USER_ID])])
        COLLECTION_USER.document(USER_ID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([self.event.id])])
        COLLECTION_USER.document(USER_ID).updateData(["eventsID":FieldValue.arrayRemove([self.event.id])])
    }
    
    
    func chooseUndecidedOnEvent(userID: String){
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersDeclinedID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersUndecidedID":FieldValue.arrayUnion([userID])])
        COLLECTION_USER.document(userID).updateData(["pendingEventInvitationID":FieldValue.arrayUnion([self.event.id])])
        COLLECTION_USER.document(userID).updateData(["eventsID":FieldValue.arrayRemove([self.event.id])])

    }
    
   
    
    func attendEvent() {
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "timeStamp":Timestamp(),
            "type":"attendingEvent",
            "eventID": self.event.id,
            "userID": event.creatorID ?? " ",
            "hasSeen":false] as [String:Any]
        
        for userID in self.event.usersAttendingID ?? [] {
            COLLECTION_USER.document(userID).collection("Notifications").document(notificationID).setData(userNotificationData)
        }
        
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersAttendingID":FieldValue.arrayUnion([USER_ID])])
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersDeclinedID":FieldValue.arrayRemove([USER_ID])])
        COLLECTION_USER.document(USER_ID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([self.event.id])])
        COLLECTION_EVENTS.document(self.event.id).updateData(["usersUndecidedID":FieldValue.arrayRemove([USER_ID])])
        COLLECTION_USER.document(USER_ID).updateData(["eventsID":FieldValue.arrayUnion([self.event.id])])
    }
    
    
    func editEvent(event: EventModel, name: String, startTime: Date, endTime: Date, user: User, image: UIImage?, invitationType: String, location: EventModel.Location, membersCanInviteGuests: Bool, invitedMembers: [User], excludedMembers: [User], description: String, createEventChat: Bool, createGroupFromEvent: Bool, completion: @escaping (Bool) -> ()){
        let dp = DispatchGroup()
        dp.enter()
        //this is for editing the event but im too fucking lazy to change variable names :/
        self.creatingEvent = true
        COLLECTION_EVENTS.document(event.id).updateData(["eventName":name])
        COLLECTION_EVENTS.document(event.id).updateData(["eventStartTime":startTime])
        COLLECTION_EVENTS.document(event.id).updateData(["eventEndTime":endTime])
        COLLECTION_EVENTS.document(event.id).updateData(["invitationType":invitationType])
        COLLECTION_EVENTS.document(event.id).updateData(["usersExcludedID":excludedMembers.map({$0.id ?? " "})])
        COLLECTION_EVENTS.document(event.id).updateData(["description":description])
        
        let locationData = ["id": location.id ?? nil,
                            "name":location.name,
                            "address":location.address,
                            "latitude":location.latitude,
                            "longitude":location.longitude] as [String:Any]
        COLLECTION_EVENTS.document(event.id).updateData(["location":locationData])

        if let image = image {
            self.persistImageToEventStorage(eventID: event.id, image: image) { fetchedImageURL in
                COLLECTION_EVENTS.document(event.id).updateData(["eventImage":fetchedImageURL])
            }
        }
        
        
        dp.leave()

        
        dp.notify(queue: .main, execute:{
      
            
            
            if createEventChat{
                let chatID = UUID().uuidString
                self.createEventChat(eventChatID: chatID, users: invitedMembers, eventID: event.id, name: name)
            }
            
            if createGroupFromEvent{
                if let image = image {
                self.createGroupFromEvent(groupName: name, image: image , users: invitedMembers)
                }
            }
            
            
            var notificationID = UUID().uuidString
            
            
            
            let userNotificationData = ["id":notificationID,
                                        "name": "Invite To Event",
                                        "timeStamp":Timestamp(),
                                        "userID": user.id ?? " ",
                                        "eventID": event.id,
                                        "hasSeen":false,
                                        "type":"invitedToEvent"] as [String:Any]
            
            for invitedMember in invitedMembers {
                if invitedMember.id ?? " " != user.id ?? " "{
                    COLLECTION_USER.document(invitedMember.id ?? " ").updateData(["pendingEventInvitationID":FieldValue.arrayUnion([event.id])])
                    COLLECTION_USER.document(invitedMember.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
                    COLLECTION_EVENTS.document(event.id).updateData(["usersUndecidedID":FieldValue.arrayUnion([invitedMember.id ?? " "])])
                    //                self.notificationSender.sendPushNotification(to: invitedMember.fcmToken ?? " ", title: "\(group.groupName)", body: "\(invitedMember.nickName ?? " ") created an event!")
                }
                
            }
            
            
            self.creatingEvent = false
            return completion(true)
        })
        
       
        
        
    }
    
    func createEvent(group: GroupModel?, eventName: String, eventStartTime: Date, eventEndTime: Date, user: User, image: UIImage?, invitationType: String, location: EventModel.Location, membersCanInviteGuests: Bool, invitedMembers: [User], excludedMembers: [User], description: String, createEventChat: Bool, createGroupFromEvent: Bool, completion: @escaping (Bool) -> ()) {
        let id = UUID().uuidString
        let dp = DispatchGroup()
        dp.enter()
        self.creatingEvent = true
        
        let locationData: [String: Any] = [
            "id": location.id ?? " ",
            "name": location.name,
            "address": location.address,
            "latitude": location.latitude,
            "longitude": location.longitude
        ]
        var data: [String: Any] = [
            "eventName" : eventName,
            "eventStartTime": eventStartTime,
            "eventEndTime": eventEndTime,
            "usersInvitedID": invitedMembers.map({ user in
                return user.id ?? ""
            }),
            "usersUndecidedID": invitedMembers.map({ user in
                return user.id ?? ""
            }),
            "usersExcludedID": excludedMembers.map({ user in
                return user.id ?? ""
            }),
            "id": id,
            "usersAttendingID": [user.id ?? ""],
            "creatorID": user.id ?? "",
            "timeStamp": Timestamp(),
            "invitationType": invitationType,
            "location": locationData,
            "membersCanInviteGuests": membersCanInviteGuests,
            "description": description,
            "groupID":"",
            "ended":false
        ]
        
        if let group = group {
            dp.enter()
            data["groupID"] = group.id
            
            COLLECTION_GROUP.document(group.id).updateData(["eventsID":FieldValue.arrayUnion([id])])
            let notificationID = UUID().uuidString
            let groupNotificationData: [String: Any] = [
                "id": notificationID,
                "timeStamp": Timestamp(),
                "senderID":USER_ID,
                "eventID": id,
                "type": "eventCreated"]
            COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(groupNotificationData)
            dp.leave()
        }
        

      
        
        if let image = image {
            dp.enter()
            self.persistImageToEventStorage(eventID: id, image: image) { fetchedImageURL in
                data["eventImage"] = fetchedImageURL
                dp.leave()
            }
        }
    
        dp.leave()

        dp.notify(queue: .main) {
            
    
           

            dp.enter()
            
            COLLECTION_EVENTS.document(id).setData(data) { (err) in
                if let err = err {
                    print("ERROR \(err.localizedDescription)")
                    self.creatingEvent = false
                    return completion(false)
                }
                if createEventChat {
                    let chatID = UUID().uuidString
                    self.createEventChat(eventChatID: chatID, users: invitedMembers, eventID: id, name: eventName)
                }

                if createGroupFromEvent {
                    if let image = image {
                        self.createGroupFromEvent(groupName: eventName, image: image , users: invitedMembers)
                    }
                }
                
                dp.leave()
            }
            
            dp.notify(queue: .main, execute:{
                
                let notificationID = UUID().uuidString
                let userNotificationData: [String: Any] = [
                    "id": notificationID,
                    "timeStamp": Timestamp(),
                    "eventID": id,
                    "hasSeen": false,
                    "type": "eventCreated"
                ]
                
                COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
                
                
                for invitedMember in invitedMembers {
                    if invitedMember.id ?? "" != user.id ?? "" {
                        let notificationID = UUID().uuidString
                        let userNotificationData: [String: Any] = [
                            "id": notificationID,
                            "name": "Invite To Event",
                            "timeStamp": Timestamp(),
                            "senderID": USER_ID,
                            "receiverID": invitedMember.id ?? " ",
                            "eventID": id,
                            "hasSeen": false,
                            "type": "invitedToEvent"
                        ]
                        COLLECTION_USER.document(invitedMember.id ?? "").updateData(["pendingEventInvitationID": FieldValue.arrayUnion([id])])
                        COLLECTION_USER.document(invitedMember.id ?? "").collection("Notifications").document(notificationID).setData(userNotificationData)
                        COLLECTION_EVENTS.document(id).updateData(["usersUndecidedID": FieldValue.arrayUnion([invitedMember.id ?? ""])])
                        self.notificationSender.sendPushNotification(to: invitedMember.fcmToken ?? "", title: "\(group?.groupName ?? "")", body: "\(invitedMember.nickName ?? "") created an event!")
                    }
                }
                
                COLLECTION_USER.document(USER_ID).updateData(["eventsID":FieldValue.arrayUnion([id])])
                self.creatingEvent = false
                return completion(true)
            })
        }

    

    }
    
    
    
    
    
    
    func createGroupFromEvent(groupName: String, image: UIImage, users: [User]){
        
        let id = UUID().uuidString
        let chatID = UUID().uuidString
        
        for user in users{
            COLLECTION_USER.document(user.id ?? " ").updateData(["groupsID":FieldValue.arrayUnion([id])])
            
        }
        
        let data = ["groupName" : groupName,
                    "users" : users ,
                    "memberAmount": users.count, "id":id, "chatID": chatID, "dateCreated":Timestamp(), "groupProfileImage": " "
        ] as [String:Any]
        
        COLLECTION_GROUP.document(id).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            self.persistImageToStorage(groupID: id,image: image, completion: { fetchedImageString in
                self.chatRepository.createGroupChat(name: groupName, users: users.map({$0.id ?? " "}), groupID: id, chatID: chatID, profileImage: fetchedImageString)
            })
        }
    }
    
    func persistImageToStorage(groupID: String, image: UIImage, completion: @escaping (String) -> ()) -> (){
        let fileName = "groupImages/\(groupID)"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { (metadata, err) in
            if err != nil{
                print("ERROR")
                return
            }
            ref.downloadURL { (url, err) in
                if err != nil{
                    print("ERROR: Failed to retreive download URL")
                    return
                }
                print("Successfully stored image in database")
                let imageURL = url?.absoluteString ?? ""
                COLLECTION_GROUP.document(groupID).updateData(["groupProfileImage":imageURL])
                return completion(imageURL)
            }
        }
        
    }
    
    func persistImageToEventStorage(eventID: String, image: UIImage, completion: @escaping (String) -> ()) -> (){
        let fileName = "eventImages/\(eventID)"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { return }
        ref.putData(imageData, metadata: nil) { (metadata, err) in
            if err != nil{
                print("ERROR")
                return
            }
            ref.downloadURL { (url, err) in
                if err != nil{
                    print("ERROR: Failed to retreive download URL")
                    return
                }
                print("Successfully stored image in database")
                let imageURL = url?.absoluteString ?? ""
                return completion(imageURL)
            }
        }
        
    }
    
    
    func createEventChat(eventChatID: String, users: [User], eventID: String, name: String){
        let data = ["name":name,
                    "usersID":users.map({return $0.id ?? " "}),
                    "id":eventChatID,
                    "eventID":eventID, "chatType":"groupChat"] as [String:Any]
        for user in users{
            COLLECTION_USER.document(user.id ?? " ").updateData(["personalChatsID":FieldValue.arrayUnion([eventChatID])])
        }
        
        COLLECTION_EVENTS.document(eventID).updateData(["eventChatID":eventChatID])
        
        COLLECTION_PERSONAL_CHAT.document(eventChatID).setData(data){ err in
            if err != nil {
                print("ERROR")
                return
            }
        }
        
    }

    
    
    func deleteEvent(eventID: String){
        COLLECTION_EVENTS.document(eventID).delete()
    }
    
    
    func endEvent(eventID: String, usersAttendingID: [String]){
        COLLECTION_EVENTS.document(eventID).updateData(["ended":true])
        COLLECTION_EVENTS.document(eventID).updateData(["eventEndTime":Date()])
        for userID in usersAttendingID{
            let notificationID = UUID().uuidString
            
            let userNotificationData = ["id":notificationID,
                                        "timeStamp":Timestamp(),
                                        "senderID":USER_ID,
                                        "eventID":eventID,
                                        "receiverID":userID,
                                        "hasSeen":false,
                                        "type":"eventEnded",
                                        "requiresAction":false] as [String:Any]
            COLLECTION_USER.document(userID).collection("Notifications").document(notificationID).setData(userNotificationData)
            COLLECTION_USER.document(userID).updateData(["eventsID":FieldValue.arrayRemove([eventID])])
        }
    }
    
    func leaveEvent(eventID: String){
        COLLECTION_USER.document(USER_ID).updateData(["eventsID":FieldValue.arrayRemove([eventID])])
        let dp = DispatchGroup()
        dp.enter()
        let users = (self.event.usersAttendingID ?? []) + (self.event.usersUndecidedID ?? [])
        for user in users {
            dp.enter()
            var notificationID = UUID().uuidString
           

            var userNotificationData = ["id":notificationID,
                "timeStamp":Timestamp(),
                "senderID":USER_ID,
                "receiverID": user,
                "eventID": eventID,
                "hasSeen":false,
                "type":"leftEvent"] as [String:Any]
            COLLECTION_USER.document(user).collection("Notifications").document(notificationID).setData(userNotificationData)
            dp.leave()
        }
       
        dp.leave()
        dp.notify(queue: .main, execute: {
            COLLECTION_EVENTS.document(eventID).updateData(["usersAttendingID":FieldValue.arrayRemove([USER_ID])])
        })

    }
    
    func fetchEvent(eventID: String, completion: @escaping (EventModel) -> () ) -> (){
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(EventModel(dictionary: data ?? [:]))
            
        }
    }
    
    func fetchEvent(eventID: String) {
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            self.event = EventModel(dictionary: data ?? [:])
            
        }
    }
    
    func fetchEventUsersAttending(usersAttendingID: [String], eventID: String, completion: @escaping ([User]) -> ()) -> (){
       COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            
            if err != nil {
                print("ERROR")
                return
            }
            var usersToReturn : [User] = []
            
            
            let groupD = DispatchGroup()
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            let users = data["usersAttendingID"] as? [String] ?? []
            
            for user in users {
                groupD.enter()
                COLLECTION_USER.document(user).getDocument { userSnapshot, err in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    
                    let userData = userSnapshot?.data() as? [String:Any] ?? [:]
                    
                    usersToReturn.append(User(dictionary: userData))
                    groupD.leave()
                }
            }
            
            groupD.notify(queue: .main, execute: {
                return completion(usersToReturn)
            })
            
        }
        
        
    }
    
    func listenToEvent(eventID: String){
        let dp = DispatchGroup()
        eventListener =  COLLECTION_EVENTS.document(eventID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var creatorID = data["creatorID"] as? String ?? ""
            var usersAttendingID = data["usersAttendingID"] as? [String] ?? []
            
            dp.enter()
            self.finishedFetchingEvent = false
            self.fetchCreator(userID: creatorID) { fetchedUser in
                if let fetchedUser = fetchedUser {
                    data["creator"] = fetchedUser
                }
                dp.leave()
            }
            
            dp.enter()
            self.fetchEventUsersAttending(usersAttendingID: usersAttendingID, eventID: eventID) { fetchedUsers in
                data["usersAttending"] = fetchedUsers
                dp.leave()
            }
            
            dp.notify(queue: .main, execute: {
                self.finishedFetchingEvent = true
                self.event = EventModel(dictionary: data)
            })
        }
    }
    
    func removeListener(){
        self.eventListener?.remove()
    }
    
    
    func fetchCreator(userID: String, completion: @escaping (User?) -> () ) {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return completion(nil)
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(User(dictionary: data))
        }
    }
    
}
