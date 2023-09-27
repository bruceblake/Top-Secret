//
//  CreateGroupViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

import Firebase
import Combine
import FirebaseStorage



class GroupViewModel: ObservableObject {
    
    
    @ObservedObject var chatRepository = ChatRepository()
    @ObservedObject var chatVM = ChatViewModel()
    @Published var groupChat : ChatModel = ChatModel()
    @Published var usersProfilePictures : [String] = []
    @Published var groupProfileImage = ""
    @Published var activeUsers : [User] = []
    let notificationSender = PushNotificationSender()


    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()!
            
            print("Fetched User!")
            return completion(User(dictionary: data))
        }
    }

    
   
    
    
    func loadActiveUsers(group: GroupModel){
        COLLECTION_GROUP.document(group.id).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let users = snapshot?.get("usersID") as? [String] ?? []
            
            self.activeUsers.removeAll()
            for user in users {
                
                self.fetchUser(userID: user) { fetchedUser in
                    self.activeUsers.append(fetchedUser)
                }
                
            }
            
            
            
        }
    }
    
  
    
    func changeMOTD(motd: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["motd":motd])
    }
    
    func getUsersProfilePictures(groupID: String){
        self.usersProfilePictures = []
        COLLECTION_GROUP.document(groupID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            let data = snapshot!.data()
            
            let users = data?["usersID"] as? [String] ?? []
            
            for user in users{
                COLLECTION_USER.document(user).getDocument { (snapshot, err) in
                    if err != nil{
                        print("ERROR")
                        return
                    }
                    self.usersProfilePictures.append(snapshot?.get("profilePicture")as? String ?? "")
                }
            }
            
        }
    }
    
    
    func getChat(chatID: String){
        COLLECTION_CHAT.document(chatID).getDocument { (snapshot, err) in
            if err != nil{
                print("ERROR")
                return
            }
            let data = snapshot!.data()
            self.groupChat = ChatModel(dictionary: data ?? [:])
        }
    }
    
   
    func sendGroupInvitation(groupID: String, friendID: String, userID: String){
        
        COLLECTION_USER.document(friendID).updateData(["pendingGroupInvitationID":FieldValue.arrayUnion([groupID])])
        
      
        var notificationID = UUID().uuidString
        
        var userNotificationData = ["id":notificationID,
                                    "name": "Group Invitation",
                                    "timeStamp":Timestamp(),
                                    "type":"sentGroupInvitation",
                                    "senderID":USER_ID,
                                    "receiverID":friendID,
                                    "hasSeen":false,
                                    "groupID":groupID,
                                    "requiresAction":true] as [String:Any]
        
        COLLECTION_USER.document(friendID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)

        notificationID = UUID().uuidString
        let groupNotificationData: [String: Any] = [
            "id": notificationID,
            "timeStamp": Timestamp(),
            "senderID":USER_ID,
            "receiverID":friendID,
            "type": "invitedToGroup"]
        COLLECTION_GROUP.document(groupID).collection("Notifications").document(notificationID).setData(groupNotificationData)
        
    }
    
    func acceptGroupInvitation(group: GroupModel, user: User){
        
        let dp = DispatchGroup()
        dp.enter()
        COLLECTION_USER.document(user.id ?? " ").updateData(["pendingGroupInvitationID":FieldValue.arrayRemove([group.id])])
        
        joinGroup(group: group, user: user)
        var users = group.usersID
        users.append(user.id ?? " ")
        dp.leave()
     
        dp.notify(queue: .main, execute: {
            for id in users{
                var notificationID = UUID().uuidString
                
                var userNotificationData = [
                    "id":notificationID,
                    "name": "acceptedGroupInvitation",
                    "timeStamp":Timestamp(),
                    "type":"acceptedGroupInvitation",
                    "senderID":user.id ?? " ",
                    "receiverID":id,
                    "hasSeen":false,
                    "groupID":group.id] as [String:Any]
                COLLECTION_USER.document(id).collection("Notifications").document(notificationID).setData(userNotificationData)
                COLLECTION_USER.document(id).updateData(["userNotificationCount":FieldValue.increment((Int64(1)))])
            }
            var notificationID = UUID().uuidString
            let groupNotificationData: [String: Any] = [
                "id": notificationID,
                "timeStamp": Timestamp(),
                "senderID":USER_ID,
                "type": "acceptedGroupInvitation"]
            COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(groupNotificationData)
        })
      
     

        
        
    }
    
    func denyGroupInvitation(group: GroupModel, user: User){
        
        let dp = DispatchGroup()
        dp.enter()
        COLLECTION_USER.document(user.id ?? " ").updateData(["pendingGroupInvitationID":FieldValue.arrayRemove([group.id])])
        var users = group.usersID
        users.append(user.id ?? " ")
        dp.leave()
        dp.notify(queue: .main, execute:{
            for id in users {
                var notificationID = UUID().uuidString
                
                var userNotificationData = [
                    "id":notificationID,
                    "name": "deniedGroupInvitation",
                    "timeStamp":Timestamp(),
                    "type":"deniedGroupInvitation",
                    "senderID":user.id ?? " ",
                    "receiverID":id,
                    "hasSeen":false,
                    "groupID":group.id] as [String:Any]
                
                COLLECTION_USER.document(id).collection("Notifications").document(notificationID).setData(userNotificationData)

            }
            var notificationID = UUID().uuidString
            let groupNotificationData: [String: Any] = [
                "id": notificationID,
                "timeStamp": Timestamp(),
                "senderID":USER_ID,
                "type": "deniedGroupInvitation"]
            COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(groupNotificationData)
        })
        
        
        
        
        
    }
    
   
    
    func joinGroup(group: GroupModel, user: User){
        COLLECTION_GROUP.document(group.id).updateData(["usersID":FieldValue.arrayUnion([user.id])])
        COLLECTION_USER.document(user.id ?? "").updateData(["groupsID":FieldValue.arrayUnion([group.id])])
             
           
                 
        self.chatRepository.joinChat(chatID: group.chatID ?? " " , userID: user.id ?? " ", groupID: group.id)

             var notificationID = UUID().uuidString
             
             let notificationData = ["id":notificationID,
                                     "name": "User Added",
                                     "timeStamp":Timestamp(),
                                     "type":"userAdded", "userID":user.id,
                                     "usersThatHaveSeen":[]] as [String:Any]
        
        COLLECTION_GROUP.document(group.id).collection("Notifications").document(notificationID).setData(notificationData)
        COLLECTION_GROUP.document(group.id).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            let data = snapshot?.data() as! [String:Any]
            let eventsID = data["eventsID"] as? [String] ?? []
            for id in eventsID {
                COLLECTION_USER.document(user.id ?? " ").updateData(["eventsID":FieldValue.arrayUnion([id])])
            }
          
        }
       
        COLLECTION_GROUP.document(group.id).updateData(["notificationCount":FieldValue.increment((Int64(1)))])
        
        for user in group.users ?? [] {
            notificationSender.sendPushNotification(to: user.fcmToken ?? " ", title: "\(group.groupName)", body: "\(user.nickName ?? " ") has joined \(group.groupName)")
        }
        
        
             
    }
    

        

    
    
    
    func createGroup(groupName: String, dateCreated: Date, users: [String], image: UIImage, groupID: String){
        
        
        for user in users{
            if user != userVM.user?.id ?? " "{
                self.sendGroupInvitation(groupID: groupID, friendID: user, userID: USER_ID)
            }
        }
        COLLECTION_USER.document(USER_ID).updateData(["groupsID":FieldValue.arrayUnion([groupID])])
        print("id: \(USER_ID)")
        
        
        
        let chatID = UUID().uuidString

        let data = ["groupName" : groupName, "usersID": [USER_ID] , "id":groupID, "chatID": chatID, "dateCreated":Timestamp(), "groupProfileImage": " "
        ] as [String:Any]
                
        COLLECTION_GROUP.document(groupID).setData(data) { (err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            self.persistImageToStorage(groupID: groupID ,image: image, completion: { fetchedImageString in
                self.chatRepository.createGroupChat(name: groupName, users: [USER_ID], groupID: groupID, chatID: chatID, profileImage: fetchedImageString)
            })
        }
    }
   
    
    
  
    
    func isInGroup(user1: User, group: GroupModel, completion: @escaping (Bool) -> () ) -> (){
        COLLECTION_GROUP.document(group.id).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            let users = snapshot?.get("usersID") as? [String] ?? []
            for user in users {
                return completion(user == user1.id)
            }
        }
    }
    
    func changeBio(bio: String, groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["bio":bio])
    }
    
    
    
 
    
    func persistImageToStorage(groupID: String, image: UIImage, completion: @escaping (String) -> ()) -> (){
       let fileName = "groupImages/\(groupID)"
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
                COLLECTION_GROUP.document(groupID).updateData(["groupProfileImage":imageURL])
                return completion(imageURL)
            }
        }
      
    }

    
    
    
  

    
}






