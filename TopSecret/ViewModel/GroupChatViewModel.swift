//
//  GroupChatViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseStorage


class GroupChatViewModel : ObservableObject {
    @Published var messages : [Message] = []
    @Published var text: String = ""
    @Published var currentChatColor = "green"
    @Published var scrollToBottom = 0
    @Published var usersIdling : [User] = []
    @Published var usersTyping : [User] = []
    @Published var readAllMessagesListener : ListenerRegistration?
    @Published var chatListener : ListenerRegistration?
    @Published var usersIdlingListener : ListenerRegistration?
    @Published var chat : ChatModel = ChatModel()
    @Published var users: [User] = []
    @Published var sendingMedia: Bool = false
    @Published var imagesSent: Int = 0
    @Published var videosSent: Int = 0
    
    
    func readLastMessage(chatID: String, userID: String){
        
        
        
        COLLECTION_PERSONAL_CHAT.document(chatID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var usersThatHaveSeen = data["usersThatHaveSeenLastMessage"] as? [String] ?? []
            if !usersThatHaveSeen.contains(userID){
                COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
                
                COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":FieldValue.arrayUnion([userID])])
             
                
                
                
            }
            
            
        }
        
        
        
        
    }
    
    func startTyping(userID: String, chatID: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersTypingID":FieldValue.arrayUnion([userID])])
       
        
    }
    
    func stopTyping(userID: String, chatID: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersTypingID":FieldValue.arrayRemove([userID])])
        
        
    }
  
    
    func openChat(userID: String, chatID: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("UsersIdling").document(userID).setData(["user":userID])
    }
    
    func exitChat(userID: String, chatID: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("UsersIdling").document(userID).delete()

        
    }
    
    
    
    
    func readAllMessages(chatID: String, groupID: String){
        
        
        readAllMessagesListener = COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp", descending: false).addSnapshotListener { snapshot, err in
            if err != nil {
                print(err!.localizedDescription)
                return
            }
            
            self.messages = snapshot!.documents.map{ snapshot -> Message in
                let data = snapshot.data()
                
                

                
                return Message(dictionary: data)
            }
        }
        
    }
    
    
    //action
    
    
    func sendTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chatID: String){
        
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":timeStamp,
                               "nameColor":nameColor,
                               "id":messageID,
                               "profilePicture":user.profilePicture
                               ?? "",
                               "type":messageType,
                               "value":text,
                               "userID":user.id ?? " "] as! [String:Any]
        
        let dp = DispatchGroup()
        
        dp.enter()
        
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).setData(textMessageData)
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":messageID])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
            
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
            
            
            
        })
        
        
        
        
    }
    
    func editMessage(messageID: String, chatID: String, text: String, groupID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).updateData(["messageValue":text])
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).updateData(["edited":true])
        self.scrollToBottom += 1

    }
    
    
    func getLastMessage() -> Message{
        return self.messages.last ?? Message()
    }
    
    
    func sendVideoMessage(videoUrl: URL, user: User, completion: @escaping (Bool) -> ()) {
        let data = try! Data(contentsOf: videoUrl)
        let storageRef = Storage.storage().reference()
        let path = "\(self.chat.id)/ChatVideos/\(UUID().uuidString).mp4"
        let fileRef = storageRef.child(path)
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        let dp = DispatchGroup()
        dp.enter()
        let uploadTask = fileRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                print("Error uploading video: \(error.localizedDescription)")
                completion(false)
            } else {
                fileRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        print("Error getting download URL: \(error?.localizedDescription ?? "unknown error")")
                        self.sendingMedia = false
                        completion(false)
                        return
                    }
                    let messageID = UUID().uuidString
                    let imageMessageData = ["name":user.nickName ?? "",
                                            "timeStamp":Timestamp(),
                                            "id":messageID,
                                            "profilePicture":user.profilePicture ?? "",
                                            "type":"video",
                                            "userID":user.id ?? " ",
                                            "value":url?.absoluteString ?? " "] as! [String:Any]
                    COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).setData(imageMessageData)
                    dp.leave()
                    
                    dp.notify(queue: .main, execute:{
                        
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastMessageID":messageID])
                        
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
                        
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastActionDate":Timestamp()])
                        return completion(true)
                    })
                }
            }
        }
    }
    
    func sendImageMessage(image: UIImage, user: User, completion: @escaping (Bool) -> ()){
        
        
        let storageRef = Storage.storage().reference()
        
        let imageData = image.jpegData(compressionQuality: 0.1)
        
        guard imageData != nil else {
            return completion(false)
        }
        let path = "\(self.chat.id)/ChatImages/\(UUID().uuidString).jpg"
        let fileRef = storageRef.child(path)
        let dp = DispatchGroup()
        
        dp.enter()
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata , err in
            if err == nil && metadata != nil {

                fileRef.downloadURL { downloadedURL, err in
                    if err != nil {
                        print("ERROR")
                        dp.leave()
                        return completion(false)
                    }
                    let messageID = UUID().uuidString
                    let imageMessageData = ["name":user.nickName ?? "",
                                            "timeStamp":Timestamp(),
                                            "id":messageID,
                                            "profilePicture":user.profilePicture ?? "",
                                            "type":"image",
                                            "userID":user.id ?? " ",
                                            "value":downloadedURL?.absoluteString ?? " "] as! [String:Any]
                    COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).setData(imageMessageData)
                    dp.leave()
                    
                    dp.notify(queue: .main, execute:{
                        
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastMessageID":messageID])
                        
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
                        
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastActionDate":Timestamp()])
                        return completion(true)
                    })
                }
                
            }
            
            
        }
    }
    
    func sendReplyTextMessage(text: String, user: User, nameColor: String, repliedMessageID: String, messageType: String, chatID: String){
        let id = UUID().uuidString
        
        
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":Timestamp(),
                               "nameColor":nameColor,
                               "id":id,
                               "profilePicture":user.profilePicture
                               ?? "",
                               "type":"repliedMessage",
                               "value":text,
                               "userID":user.id ?? " ",
                               "repliedMessageID":repliedMessageID] as! [String:Any]
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(id).setData(textMessageData)
        
    }
    
    func editMessage(messageID: String, chatID: String, text: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).updateData(["value":text])
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).updateData(["edited":true])
    }
    
    func deleteMessage(messageID: String, chatID: String, user: User){
        let dp = DispatchGroup()
        dp.enter()
        let id = UUID().uuidString
        let messageText = "\(user.nickName ?? "") deleted a chat!"
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":id])
        let textMessageData = ["name":user.nickName ?? "",
                               "timeStamp":Timestamp(),
                               "id":id,
                               "type":"delete",
                               "value":messageText] as! [String:Any]
        dp.leave()
        dp.notify(queue: .main, execute:{
            COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(id).setData(textMessageData)
            COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).delete()
        })
        
    }
    func sendMultipleVideosMessage(videoUrls: [URL], user: User, completion: @escaping (Bool) -> ()){
        let dp = DispatchGroup()
        dp.enter()
        let messageID = UUID().uuidString
        
        let imageMessageData = ["name":user.nickName ?? "",
                                "timeStamp":Timestamp(),
                                "id":messageID,
                                "profilePicture":user.profilePicture ?? "",
                                "type":"multipleVideos",
                                "userID":user.id ?? " "] as! [String:Any]
        COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).setData(imageMessageData)
        
             COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastMessageID":messageID])
             
             COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
             
             COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastActionDate":Timestamp()])
        dp.leave()

        dp.notify(queue: .main, execute:{
            for url in videoUrls{
                let data = try! Data(contentsOf: url)
                let storageRef = Storage.storage().reference()
                let path = "\(self.chat.id)/ChatVideos/\(UUID().uuidString).mp4"
                let fileRef = storageRef.child(path)
                let metadata = StorageMetadata()
                metadata.contentType = "video/mp4"
                    let uploadTask = fileRef.putData(data, metadata: metadata) { (metadata, error) in
                        if let error = error {
                            print("Error uploading video: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            fileRef.downloadURL { (url, error) in
                                guard let downloadURL = url else {
                                    print("Error getting download URL: \(error?.localizedDescription ?? "unknown error")")
                                    self.sendingMedia = false
                                    completion(false)
                                    return
                                }
                                COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).updateData(["urls":FieldValue.arrayUnion([url?.absoluteString ?? " "])])
                                self.videosSent += 1
                            }
                        }
                    }
            }
            return completion(true)
        })
       
        
    }
    
    func sendMultipleImagesMessage(images: [UIImage], user: User, completion: @escaping (Bool) -> ()){
        let dp = DispatchGroup()
        dp.enter()
        let messageID = UUID().uuidString
        
        let imageMessageData = ["name":user.nickName ?? "",
                                "timeStamp":Timestamp(),
                                "id":messageID,
                                "profilePicture":user.profilePicture ?? "",
                                "type":"multipleImages",
                                "userID":user.id ?? " "] as! [String:Any]
        COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).setData(imageMessageData)
        
             COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastMessageID":messageID])
             
             COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
             
             COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastActionDate":Timestamp()])
        dp.leave()

        dp.notify(queue: .main, execute:{
            for image in images{
                let storageRef = Storage.storage().reference()
                
                let imageData = image.jpegData(compressionQuality: 0.1)
                
                guard imageData != nil else {
                    return completion(false)
                }
                let path = "\(self.chat.id)/ChatImages/\(UUID().uuidString).jpg"
                let fileRef = storageRef.child(path)
                let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata , err in
                    if err == nil && metadata != nil {

                        fileRef.downloadURL { downloadedURL, err in
                            if err != nil {
                                print("ERROR")
                                dp.leave()
                                return completion(false)
                            }
                        
                      
                            COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).updateData(["urls":FieldValue.arrayUnion([downloadedURL?.absoluteString ?? " "])])
                            self.imagesSent += 1

                            
                        }
                        
                    }
                    
                    
                }
            }
            return completion(true)
        })
    }
    
    //fetching
    func listenToChat(chatID: String, groupID: String, completion: @escaping (Bool) -> ()) -> (){
        
        
        
        
        chatListener = COLLECTION_PERSONAL_CHAT.document(chatID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() ?? [:]
            let usersID = data["usersID"] as? [String] ?? []
            let groupD = DispatchGroup()
            
            
            //fetch all chat users
            groupD.enter()
            self.fetchChatUsers(users: usersID) { fetchedUsers in
                data["users"] = fetchedUsers
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute: {
                self.chat = ChatModel(dictionary: data)
                self.users = data["users"] as? [User] ?? []
                print("id count: \(usersID.count)")
                return completion(true)
            })
            
            
        }
    }
    
    func listenToUsersIdling(chatID: String, groupID: String){
        
    usersIdlingListener  = COLLECTION_PERSONAL_CHAT.document(chatID).collection("UsersIdling").addSnapshotListener({ snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let snapshot = snapshot else{
                print("ERROR")
                return
            }
        
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added{
                    var user = diff.document.get("user") as? String ?? " "
                    self.fetchChatUser(userID: user) { fetchedUser in
                        if !self.usersIdling.contains(fetchedUser){
                        self.usersIdling.append(fetchedUser)
                        }
                      
                    }
                }else if diff.type == .removed {
                    var user = diff.document.get("user") as? String ?? " "
                    self.fetchChatUser(userID: user) { fetchedUser in
                        self.usersIdling.removeAll { idleUser in
                            return idleUser == fetchedUser
                        }
                        
                      
                    }
                }
            }
            
        })
    }
    
    func fetchChatUser(userID: String,completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
        }
    }
    
    
    func getColor(userID: String, groupChat: ChatModel) -> String{
        var ans = ""
        for maps in groupChat.nameColors ?? []{
            for key in maps.keys{
                if key == userID{
                    ans = maps[userID] ?? ""
                }
            }
        }
        return ans
    }
    
    func checkIfUserIsIdling(userID: String) -> Bool {
     
        
        return self.chat.usersIdlingID.contains(userID) 
        
    }
    
    func fetchChatUsers(users: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        
        var groupD = DispatchGroup()
        
        for userID in users {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                
                usersToReturn.append(User(dictionary: data))
                groupD.leave()
            }
        }
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    

    
    func readLastMessage() -> Message {
        return self.messages.last ?? Message()
    }
    
    
    //persis to storage
    
    func persistImageToStorage(image: UIImage, chatID: String, messageID: String, groupID: String) {
        let fileName = "images/\(chatID)"
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
                COLLECTION_GROUP.document(groupID).collection("Chat").document(chatID).collection("Messages").document(messageID).updateData(["messageValue":imageURL])
            }
        }
        
    }
}
