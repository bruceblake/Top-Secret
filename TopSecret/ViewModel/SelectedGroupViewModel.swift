//
//  SelectedGroupViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage

class SelectedGroupViewModel : ObservableObject {
    
    @Published var group: GroupModel = GroupModel()
    @Published var finishedFetchingGroupEvents : Bool = false
    @Published var finishedFetchingGroup : Bool = false
    @Published var listeners : [ListenerRegistration] = []
    @Published var events: [EventModel] = []
    @Published var polls: [PollModel] = []
    @Published var notifications : [GroupNotificationModel] = []
    @Published var groupChat : ChatModel = ChatModel()
    @Published var groupListener : ListenerRegistration?
   
    
    
   
    
    
    func sendGroupInvitation(group: GroupModel, friend: User, userID: String){
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["pendingGroupInvitationID":FieldValue.arrayUnion([group.id])])
        
      
        var notificationID = UUID().uuidString
        
        var userNotificationData = ["id":notificationID,
                                    "name": "Group Invitation",
                                    "timeStamp":Timestamp(),
                                    "type":"sentGroupInvitation",
                                    "senderID":USER_ID,
                                    "receiverID":friend.id ?? " ",
                                    "hasSeen":false,
                                    "groupID":group.id,
                                    "requiresAction":true] as [String:Any]
        
        COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
        
        
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        notificationID = UUID().uuidString
        let groupNotificationData: [String: Any] = [
            "id": notificationID,
            "timeStamp": Timestamp(),
            "senderID":USER_ID,
            "receiverID":friend.id ?? "",
            "type": "invitedToGroup"]
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(groupNotificationData)
    }
    
    func readGroupNotifications(groupID: String, userID: String, notification: GroupNotificationModel){
        
        COLLECTION_GROUP.document(groupID).collection("Notifications").document(notification.id).updateData(["usersThatHaveSeen":FieldValue.arrayUnion([userID])])
        
    
    }
    
    
    func changeMOTD(groupID: String, motd: String){
        COLLECTION_GROUP.document(groupID).updateData(["motd":motd])
    }
    
    
    func fetchGroup(groupID: String, completion: @escaping (GroupModel) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(GroupModel(dictionary: data))
        }
    }
    
    func fetchMedia(urlPath: String, completion: @escaping (UIImage) -> ()) -> (){
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(urlPath)
        
        DispatchQueue.global(qos: .userInteractive).async{
            fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
                if err != nil {
                    print("ERROR")
                }
                
                if let image = UIImage(data: data ?? Data())  {
                        return completion(image)
                }
            }
        }
      
        
    }

    
    
    func listenToGroupEvents(_groupID: String){
        var eventsToReturn : [EventModel] = []
       
        self.listeners.append(
            COLLECTION_EVENTS.addSnapshotListener({ snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let documents = snapshot!.documents
                
                let groupD = DispatchGroup()
                
                groupD.enter()
           
                for document in documents {
                    var data = document.data()
                    var groupID = data["groupID"] as? String ?? ""
                    var creatorID = data["creatorID"] as? String ?? " "
                    var urlPath = data["urlPath"] as? String ?? ""
                    data["group"] = self.group

                    groupD.enter()
                    self.fetchUser(userID: creatorID) { fetchedUser in
                        data["creator"] = fetchedUser
                        groupD.leave()
                    }
                    
                  
                    
                    groupD.enter()
                    self.fetchMedia(urlPath: urlPath) { fetchedImage in
                        data["image"] = fetchedImage
                        groupD.leave()
                    }
                   
                    
                    groupD.notify(queue: .main, execute: {
                        if _groupID == groupID{
                            eventsToReturn.append(EventModel(dictionary: data))
                        }
                    })
                }
                
                groupD.leave()
                
                groupD.notify(queue: .main, execute: {
                    self.events = eventsToReturn
                })
            })
        )
    }
    
    
    func leaveGroup(){
    
        COLLECTION_GROUP.document(self.group.id).updateData(["usersID":FieldValue.arrayRemove([USER_ID])])

        COLLECTION_USER.document(USER_ID).updateData(["groupsID":FieldValue.arrayRemove([self.group.id])])
        
        
        
            var notificationID = UUID().uuidString
            
            let notificationData = ["id":notificationID,
                                    "notificationName": "User Left",
                                    "notificationTime":Timestamp(),
                                    "notificationType":"userLeft", "notificationCreator9ID":USER_ID,
                                    "usersThatHaveSeen":[]] as [String:Any]
        COLLECTION_GROUP.document(self.group.id).collection("Notifications").document(notificationID).setData(notificationData)
            
        COLLECTION_GROUP.document(self.group.id).updateData(["notificationCount":FieldValue.increment((Int64(1)))])
           
//        for user in self.group.users{
//            self.notificationSender.sendPushNotification(to: user.fcmToken ?? " ", title: "\(self.group.groupName)", body: "\(user.nickName ?? " ") has left \(group.groupName)")
//            }
            
        }
    
    func fetchPollOptions(pollID: String, groupID: String, completion: @escaping ([PollOptionModel]) -> () ) -> () {
        var choicesToReturn : [PollOptionModel] = []

        COLLECTION_POLLS.document(pollID).collection("Options").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                
              
                
                    choicesToReturn.append(PollOptionModel(dictionary: data))
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(choicesToReturn)
            })
            
            
        }
    }
    
    func fetchUsersAnswered(usersID: [String], completion: @escaping ([User]) -> ()) -> () {
        var usersToReturn : [User] = []
        let groupD = DispatchGroup()
        groupD.enter()
        for userID in usersID{
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                
                usersToReturn.append(User(dictionary: data))
                
            }
        }
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    

    
    
    func listenToGroupPolls(groupID: String){
        var pollsToReturn : [PollModel] = []
        
        self.listeners.append( COLLECTION_GROUP.document(groupID).collection("Polls").addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()
            
            groupD.enter()
       
            for document in documents {
                var data = document.data()
                groupD.enter()
                self.fetchGroup(groupID: groupID) { fetchedGroup in
                    data["group"] = fetchedGroup
                    groupD.leave()
                }

                groupD.enter()
                self.fetchPollOptions(pollID: data["id"] as? String ?? " ", groupID: groupID) { fetchedChoices in
                    data["pollOptions"] = fetchedChoices
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUser(userID: data["creatorID"] as? String ?? " ") { fetchedUser in
                    data["creator"] = fetchedUser
                    groupD.leave()
                }
                
             
                
                groupD.enter()
                self.fetchUsersAnswered(usersID: data["usersAnsweredID"] as? [String] ?? []){ fetchedUsers in
                    data["usersAnswered"] = fetchedUsers
                    
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    pollsToReturn.append(PollModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                self.polls = pollsToReturn
            })
            
        })
    }
    
    
    func changeCurrentGroup(groupID: String, completion: @escaping (Bool) ->()) -> (){
        self.groupListener = nil
       
        self.listenToGroup(groupID: groupID) { fetchedGroup in
            self.finishedFetchingGroup = fetchedGroup
            self.listenToNotifications(groupID: groupID)
            self.listenToGroupEvents(_groupID: groupID)
            self.listenToGroupPolls(groupID: groupID)
            return completion(true)
        }
        
    }
    
    func listenToGroup(groupID: String, completion: @escaping (Bool) -> ()) -> (){
        let dp = DispatchGroup()
        self.groupListener = COLLECTION_GROUP.document(groupID).addSnapshotListener { snapshot, err in
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            let groupD = DispatchGroup()
            var eventsID = data["eventsID"] as? [String] ?? []
            print("events: \(eventsID.count)")
            groupD.enter()
                self.fetchGroupUsers(usersID: data["usersID"] as? [String] ?? []) { fetchedUsers in
                    data["users"] = fetchedUsers
                    groupD.leave()
                }
           

            
            groupD.notify(queue: .main, execute: {
                self.finishedFetchingGroup = true
                self.group = GroupModel(dictionary: data )
                return completion(true)
            })
            
          
        }
      

    }

    
    func fetchGroupUsers(usersID: [String], completion: @escaping ([User]) -> ()) -> () {
        var users : [User] = []
        
        var groupD = DispatchGroup()
        
        
        
        for userID in usersID {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                users.append(User(dictionary: data))
                groupD.leave()
                
            }
        }
        
        groupD.notify(queue: .main, execute: {
            return completion(users)
        })
        
        
    }
    
    
    func fetchGroupStories(groupID: String, completion: @escaping ([StoryModel]) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Stories").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            
            return completion(documents.map({ queryDocumentSnapshot -> StoryModel in
                let data = queryDocumentSnapshot.data()
                
                return StoryModel(dictionary: data)
            }))
            
            
           
            
        }
    }
    
    
    func listenToGroupChat(groupID: String, completion: @escaping (ChatModel) -> ()) -> (){
        self.listeners.append(COLLECTION_GROUP.document(groupID).collection("Chat").document(group.chatID ?? " ").addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
        
            let data =  snapshot?.data() as? [String:Any] ?? [:]
                
              
            self.groupChat = ChatModel(dictionary: data)
           
            
        })
    }
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()){
        
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
            
        }
        
    }
    
    
   
    
    func listenToNotifications(groupID: String) {
        
        
        var notificationsToReturn : [GroupNotificationModel] = []
        COLLECTION_GROUP.document(groupID).collection("Notifications").addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                var senderID = data["senderID"] as? String ?? ""
                var receiverID = data["receiverID"] as? String ?? ""
  
                if senderID != ""{
                    groupD.enter()
                    self.fetchUser(userID: senderID) { fetchedUser in
                        data["sender"] = fetchedUser
                        groupD.leave()
                    }
                    
                }
              
                if receiverID != "" {
                    groupD.enter()
                    self.fetchUser(userID: receiverID) { fetchedUser in
                        data["receiver"] = fetchedUser
                        groupD.leave()
                    }
                }
             
               
                
                groupD.notify(queue: .main, execute: {
                    notificationsToReturn.append(GroupNotificationModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                self.notifications = notificationsToReturn
            })
            
            
          
            
        }
    }
    
    func fetchGroupUnreadNotifications(userID: String, groupID: String, completion: @escaping ([GroupNotificationModel]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("Notifications").getDocuments { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents.filter({ (($0.get("usersThatHaveSeen") as? [String] ?? []).contains(userID) == false)})
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> GroupNotificationModel in
                let data = queryDocumentSnapshot.data()
                
                return GroupNotificationModel(dictionary: data)
            }))
            
        }
    }
    
   

    
    
    func fetchGroupCountdown(groupID: String,completion: @escaping ([CountdownModel]) -> () ) -> (){
        COLLECTION_GROUP.document(groupID).collection("Countdowns").getDocuments { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            
            
            
            return completion(documents.map({ queryDocumentSnapshot -> CountdownModel in
                let data = queryDocumentSnapshot.data()
                
                return CountdownModel(dictionary: data)
            }))
            
        }
    }
    
    func fetchEventUsersAttending(usersAttendingID: [String], eventID: String , groupID: String, completion: @escaping ([User]) -> ()) -> (){
        COLLECTION_GROUP.document(groupID).collection("Events").document(eventID).getDocument { snapshot, err in
            
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
    
    
    func fetchGroupEvents(groupID: String,completion: @escaping ([EventModel]) -> () ) -> (){
        
        var eventsToReturn : [EventModel] = []
        COLLECTION_GROUP.document(groupID).collection("Events").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                var id = data["id"] as? String ?? " "
                var usersAttendingID = data["usersAttendingID"] as? [String] ?? []
                var creatorID = data["creatorID"] as? String ?? " "
                groupD.enter()
                
                self.fetchEventUsersAttending(usersAttendingID: usersAttendingID, eventID: id, groupID: groupID) { fetchedUsers in
                    data["usersAttending"] = fetchedUsers
                
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUser (userID: creatorID){ fetchedUser in
                    data["creator"] = fetchedUser
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    eventsToReturn.append(EventModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(eventsToReturn)
            })
            
            
          
            
        }
    }
    
    func fetchGroupPolls(groupID: String,completion: @escaping ([PollModel]) -> () ) -> (){
        
        var pollsToReturn : [PollModel] = []
        COLLECTION_GROUP.document(groupID).collection("Polls").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            let groupD = DispatchGroup()

            groupD.enter()
       
            for document in documents {
                var data = document.data()
                
                groupD.enter()
                self.fetchPollOptions(pollID: data["id"] as? String ?? " ", groupID: groupID) { fetchedChoices in
                    data["pollOptions"] = fetchedChoices
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUser(userID: data["creatorID"] as? String ?? " ") { fetchedUser in
                    data["creator"] = fetchedUser
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUsersAnswered(usersID: data["usersAnsweredID"] as? [String] ?? []){ fetchedUsers in
                    data["usersAnswered"] = fetchedUsers
                    
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    pollsToReturn.append(PollModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(pollsToReturn)
            })
            
            
          
            
        }
    }
    

  
    
  
    
}
