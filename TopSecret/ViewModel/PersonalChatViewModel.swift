//
//  PersonalChatViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/16/22.
//

import Foundation
import Firebase
import SwiftUI
import Combine
import FirebaseStorage



class PersonalChatViewModel : ObservableObject {
    @Published var chat : ChatModel = ChatModel()
    @Published var messages : [Message] = []
    @Published var lastDocument : QueryDocumentSnapshot?
    @Published var scrollToBottom : Int = 0
    @Published var text: String = ""
    @Published var currentChatColor = "green"
    @Published var chatListener : ListenerRegistration?
    @Published var messageListeners : [ListenerRegistration] = []
    @Published var personalChats: [ChatModel] = []
    @Published var coverMessages : [Message] = []
    @Published var lastMessageListener : ListenerRegistration?
    @Published var isLoading : Bool = false
    @Published var hasMoreMessages: Bool = true
    @Published var sendingMedia: Bool = false
    @Published var imagesSent: Int = 0
    @Published var videosSent: Int = 0
    @Published var finishedSendingImages: Bool = false
    @Published var finishedSendingVideos: Bool = false
    @Published var documentsLeftToFetch: Int = 0
    @Published var documentsFetched: Int = 0
    @Published var failedToSend : Bool = false
    @Published var sendingMediaID: [String] = []
    @Published var pageSize : Int = 40
    let notificationSender = PushNotificationSender()
    var colors : [String] = ["red","green","teal","purple"]
    var cancellables = Set<AnyCancellable>()
    @Published var testListener : ListenerRegistration?
      
    
    
    
    func startTyping(userID: String, chatID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersTypingID":FieldValue.arrayUnion([userID])])
    }
    
    func stopTyping(userID: String, chatID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersTypingID":FieldValue.arrayRemove([userID])])
    }
    
    func openChat(userID: String, chatID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersIdlingID":FieldValue.arrayUnion([userID])])
    }
    
    func exitChat(userID: String, chatID: String){
        COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersIdlingID":FieldValue.arrayRemove([userID])])
        if chatListener != nil{
            chatListener?.remove()
        }
    }
    
    
    func getPersonalChatUser(chat: ChatModel, userID: String) -> User{
        for user in chat.users ?? []{
            if user.id != userID{
                return user
            }
        }
        return User()
    }
    
  
    
    
    
    func getTotalNotifications(userID: String) -> Int {
        var sum = 0
        for chat in self.personalChats{
            if !(chat.usersThatHaveSeenLastMessage?.contains(userID) ?? false ){
                sum += 1
            }
        }
        return sum
    }
    
    
   
    
    func fetchChatUsers(users: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        
        var groupD = DispatchGroup()
        
        groupD.enter()
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
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }
    
    func increasePageSize(chatID: String){
        self.pageSize += 40
        self.testListener?.remove()
        self.listenToMessages(chatID: chatID)
    }
    
    func listenToMessages(chatID: String){
        self.testListener = COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp", descending: false).limit(toLast: (self.pageSize + self.messages.count)).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
           
            var messagesToReturn : [Message] = []
            let dp = DispatchGroup()
            
            dp.enter()
                for document in snapshot?.documentChanges ?? [] {
                        dp.enter()
                        var data = document.document.data()
                        let id = data["id"] as? String ?? ""
                        let type = data["type"] as? String ?? ""
                        let value = data["value"] as? String ?? ""
                        let repliedMessageID = data["repliedMessageID"] as? String ?? ""
                        if type == "repliedMessage"{
                            dp.enter()
                            self.fetchReplyMessages(chatID: chatID, messageID: repliedMessageID) { fetchedReplyMessage in
                                data["repliedMessage"] = fetchedReplyMessage
                                dp.leave()
                            }
                        }
                        if type == "pollMessage"{
                            dp.enter()
                            
                            self.fetchPoll(pollID: value){ fetchedPoll in
                                data["poll"] = fetchedPoll
                                dp.leave()
                            }
                        }
                        if type == "eventMessage"{
                            dp.enter()
                            
                            self.fetchEvent(eventID: value){ fetchedEvent in
                                data["event"] = fetchedEvent
                                dp.leave()
                            }
                        }
                        dp.leave()
                    
                        dp.notify(queue: .main, execute:{
                            if document.type == .added{
                                print("added more to messages")
                                if !self.messages.contains(where: {$0.id == id}){
                                    self.messages.append(Message(dictionary: data))
                                }
                                
                            }else if document.type == .removed {
                                print("removed some messages")
                                self.messages.removeAll(where: {$0.id == id})
                            }else if document.type == .modified{
                               let index = self.messages.firstIndex(where: {$0.id == id})
                                print("modified: \(value)")
                                if let index = index {
                                    if index >= 0 && index < self.messages.count {
                                        self.messages[index] = Message(dictionary: data)
                                    }
                                }
                                
                            }
                        })
                    
                  
                }
            
         
            dp.leave()
            dp.notify(queue: .main, execute: {
                self.messages = self.messages.sorted(by: {$0.timeStamp?.dateValue() ?? Date() < $1.timeStamp?.dateValue() ?? Date()})
            })
            
        }
    }
    
    func fetchReplyMessages(chatID: String, messageID: String, completion: @escaping (ReplyMessageModel) -> ()) -> (){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").whereField("id",isEqualTo: messageID).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot?.documents ?? []
            
            
            if documents.isEmpty{
                var replyMessageData = ["id":UUID().uuidString,
                                        "value":"Message Has Been Deleted",
                                        "type":"deletedMessage"] as! [String:Any]
                return completion(ReplyMessageModel(dictionary: replyMessageData))
                
            }else{
                for document in documents{
                    var messageData = document.data() as [String:Any]
                    return completion(ReplyMessageModel(dictionary: messageData))
                    
                }
            }
            
        }
    }
    
    
    
    func fetchMoreMessages(chatID: String){
        let query = COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp", descending: true).start(afterDocument: lastDocument!).limit(to: 10)
        
       
        
        self.messageListeners.append(query.addSnapshotListener { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            var messagesToReturn : [Message] = []
            let dp = DispatchGroup()
            guard let documents = snapshot?.documentChanges else {return}
            
            dp.enter()
            
            for document in documents {
                dp.enter()
                
                var data = document.document.data()
                let id = data["id"] as? String ?? ""
                let type = data["type"] as? String ?? ""
                let value = data["value"] as? String ?? ""
                let repliedMessageID = data["repliedMessageID"] as? String ?? ""
                if type == "repliedMessage"{
                    dp.enter()
                    self.fetchReplyMessages(chatID: chatID, messageID: repliedMessageID) { fetchedReplyMessage in
                        data["repliedMessage"] = fetchedReplyMessage
                        dp.leave()
                    }
                }
                if type == "pollMessage"{
                    dp.enter()
                    
                    self.fetchPoll(pollID: value){ fetchedPoll in
                        data["poll"] = fetchedPoll
                        dp.leave()
                    }
                }
                if type == "eventMessage"{
                    dp.enter()
                    
                    self.fetchEvent(eventID: value){ fetchedEvent in
                        data["event"] = fetchedEvent
                        dp.leave()
                    }
                }
                dp.leave()

                dp.notify(queue: .main, execute: {
                    if document.type == .added{
                        if !self.messages.contains(where: {$0.id == id}){
                            messagesToReturn.append(Message(dictionary: data))
                        }
                        
                    }else if document.type == .removed {
                        self.messages.removeAll(where: {$0.id == id})
                    }else if document.type == .modified{
                       let index = self.messages.firstIndex(where: {$0.id == id})
                        if let index = index {
                            if index >= 0 && index < self.messages.count {
                                self.messages[index] = Message(dictionary: data)
                            }
                        }
                        
                    }
                    
                })
               
              
            }
            dp.leave()
            dp.notify(queue: .main, execute:{
                self.documentsLeftToFetch -= messagesToReturn.count
                self.lastDocument = snapshot?.documents.last
                self.messages.insert(contentsOf: messagesToReturn.reversed(), at: 0)
            })
        })
    }
    

    func getDocumentsToFetchCount(chatID: String, completion: @escaping (Int) -> ()){
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            return completion(snapshot?.count ?? 0)
        }
    }
   
//   func fetchFirstMessages(chatID: String, userID: String){
//       self.removeListeners()
//       self.messageListeners.append(COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").order(by: "timeStamp", descending: true).limit(to: 10).addSnapshotListener { snapshot, err in
//           if err != nil {
//               print(err!.localizedDescription)
//               return
//           }
//           var messagesToReturn : [Message] = []
//           let dp = DispatchGroup()
//
//               dp.enter()
//
//
//               for document in snapshot?.documentChanges ?? [] {
//                       dp.enter()
//                       var data = document.document.data()
//                       let id = data["id"] as? String ?? ""
//                       let type = data["type"] as? String ?? ""
//                       let value = data["value"] as? String ?? ""
//                       let repliedMessageID = data["repliedMessageID"] as? String ?? ""
//                       if type == "repliedMessage"{
//                           dp.enter()
//                           self.fetchReplyMessages(chatID: chatID, messageID: repliedMessageID) { fetchedReplyMessage in
//                               data["repliedMessage"] = fetchedReplyMessage
//                               dp.leave()
//                           }
//                       }
//                       if type == "pollMessage"{
//                           dp.enter()
//
//                           self.fetchPoll(pollID: value){ fetchedPoll in
//                               data["poll"] = fetchedPoll
//                               dp.leave()
//                           }
//                       }
//                       if type == "eventMessage"{
//                           dp.enter()
//
//                           self.fetchEvent(eventID: value){ fetchedEvent in
//                               data["event"] = fetchedEvent
//                               dp.leave()
//                           }
//                       }
//                       dp.leave()
//
//                       dp.notify(queue: .main, execute:{
//                           if document.type == .added{
//                               print("added more to messages")
//                               if !self.messages.contains(where: {$0.id == id}){
//                                   self.messages.append(Message(dictionary: data))
//                               }
//
//                           }else if document.type == .removed {
//                               print("removed some messages")
//                               self.messages.removeAll(where: {$0.id == id})
//                           }else if document.type == .modified{
//                              let index = self.messages.firstIndex(where: {$0.id == id})
//                               print("modified: \(value)")
//                               if let index = index {
//                                   if index >= 0 && index < self.messages.count {
//                                       self.messages[index] = Message(dictionary: data)
//                                   }
//                               }
//
//                           }
//                       })
//
//
//               }
//
//               dp.leave()
//               dp.notify(queue: .main, execute:{
//                   if self.documentsFetched == 0 {
//                       self.documentsFetched = messagesToReturn.count
//
//                   }
//                   self.getDocumentsToFetchCount(chatID: chatID) { count in
//                       self.documentsLeftToFetch = (count - self.documentsFetched)
//                   }
//                   self.lastDocument = snapshot?.documents.first
//
//
//
//
//               })
//
//       })
//
//   }
    
    func removeListeners(){
        self.messageListeners.forEach { listener in
            listener.remove()
        }
    }
    
    
    
    func fetchEvent(eventID: String, completion: @escaping (EventModel) -> ()) -> () {
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let groupD = DispatchGroup()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var groupID = data["groupID"] as? String ?? ""
            var creatorID = data["creatorID"] as? String ?? " "
            var urlPath = data["urlPath"] as? String ?? ""
            
            groupD.enter()
            self.fetchUser(userID: creatorID) { fetchedUser in
                data["creator"] = fetchedUser
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroup(groupID: groupID) { fetchedGroup in
                data["group"] = fetchedGroup
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchMedia(urlPath: urlPath) { fetchedImage in
                data["image"] = fetchedImage
                groupD.leave()
            }
            
            
            groupD.notify(queue: .main, execute: {
                return completion(EventModel(dictionary: data))
            })
        }
        
    }
    
    func fetchMedia(urlPath: String, completion: @escaping (UIImage) -> ()) -> (){
        let storageRef = Storage.storage().reference()
        let fileRef = storageRef.child(urlPath)
        
        DispatchQueue.global(qos: .userInteractive).async{
            fileRef.getData(maxSize: 5 * 1024 * 1024) { data, err in
                if err != nil {
                    print("ERROR: \(err?.localizedDescription ?? "")")
                }
                
                if let image = UIImage(data: data ?? Data())  {
                    return completion(image)
                }
            }
        }
        
        
    }
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            
            
            return completion(User(dictionary: data))
            
            
        }
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
    
    func fetchPoll(pollID: String, completion: @escaping (PollModel) ->() ) -> () {
        COLLECTION_POLLS.document(pollID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let groupD = DispatchGroup()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            var groupID = data["groupID"] as? String ?? ""
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
            self.fetchGroup(groupID: groupID) { fetchedGroup in
                data["group"] = fetchedGroup
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchUsersAnswered(usersID: data["usersAnsweredID"] as? [String] ?? []){ fetchedUsers in
                data["usersAnswered"] = fetchedUsers
                
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute:{
                return completion(PollModel(dictionary: data))
            })
        }
    }
    
    func fetchPost(postID: String, completion: @escaping (GroupPostModel) ->() ) -> (){
        COLLECTION_POSTS.document(postID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let groupD = DispatchGroup()
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var id = data["id"] as? String ?? "deleted"
            if id == "deleted"{
                let deletedPostData = ["id":id] as! [String:Any]
                return completion(GroupPostModel(dictionary: deletedPostData))
            }
            var creatorID = data["creatorID"] as? String ?? " "
            var groupID = data["groupID"] as? String ?? " "
            var urlPath = data["urlPath"] as? String ?? " "
            groupD.enter()
            self.fetchUser(userID: creatorID) { fetchedUser in
                data["creator"] = fetchedUser
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchGroup(groupID: groupID) { fetchedGroup in
                data["group"] = fetchedGroup
                groupD.leave()
            }
            
            groupD.enter()
            self.fetchMedia(urlPath: urlPath) { fetchedImage in
                data["image"] = fetchedImage
                groupD.leave()
            }
            groupD.notify(queue: .main, execute:{
                return completion(GroupPostModel(dictionary: data))
            })
            
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
    
    func sendNewDayMessage(chatID: String){
        let dp = DispatchGroup()
        dp.enter()
        let id = UUID().uuidString
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekdayString = dateFormatter.string(from: Date())
        let messageText = "\(weekdayString)"
        let textMessageData = ["timeStamp":Timestamp(),
                               "id":id,
                               "type":"date",
                               "value":messageText] as! [String:Any]
        dp.leave()
        dp.notify(queue: .main, execute:{
            COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(id).setData(textMessageData)
        })
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
                               "userID":user.id ?? " ",
                               "value":messageText] as! [String:Any]
        dp.leave()
        dp.notify(queue: .main, execute:{
            COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(id).setData(textMessageData)
            COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).delete()
        })
        
    }
    
    
    func sendVideoMessage(thumbnailUrlString: String, videoUrl: URL, user: User, completion: @escaping (Bool) -> ()) {
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
                                            "value":url?.absoluteString ?? " ",
                                            "thumbnailUrl":thumbnailUrlString] as! [String:Any]
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
    
    func sendMultipleVideosMessage(thumbnailUrls: [URL], videoUrls: [URL], user: User, completion: @escaping (Bool) -> ()){
        let dp = DispatchGroup()
        dp.enter()
        DispatchQueue.main.async{
            print("firstCount: \(thumbnailUrls.count)")
            let messageID = UUID().uuidString
            var urls : [String] = []
            var thumbnailImages: [String] = []
                for index in videoUrls.indices{
                    dp.enter()
                    let data = try! Data(contentsOf: videoUrls[index])
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
    //                                COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).updateData(["urls":FieldValue.arrayUnion([url?.absoluteString ?? " "])])
                                    urls.append(url?.absoluteString ?? " ")
                                    dp.leave()
                                    self.videosSent += 1
                                }
                            }
                        }
                }
                for index in thumbnailUrls.indices{
                    dp.enter()
                    let data = try! Data(contentsOf: thumbnailUrls[index])
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
    //                                COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).updateData(["thumbnailUrls":FieldValue.arrayUnion([url?.absoluteString ?? " "])])
                                    
                                    thumbnailImages.append(url?.absoluteString ?? " ")
                                    dp.leave()
                                }
                            }
                        }
                }
            dp.leave()
            dp.notify(queue: .main, execute: {
                print("urls: \(urls.count)")
                print("thumbnails: \(thumbnailImages.count)")
                let imageMessageData = ["name":user.nickName ?? "",
                                        "timeStamp":Timestamp(),
                                        "id":messageID,
                                        "profilePicture":user.profilePicture ?? "",
                                        "type":"multipleVideos",
                                        "userID":user.id ?? " ",
                                        "thumbnailUrls":thumbnailImages,
                                        "urls":urls] as! [String:Any]
                COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).setData(imageMessageData)
                
                     COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastMessageID":messageID])
                     
                     COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
                     
                     COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastActionDate":Timestamp()])
                return completion(true)

            })
        }
       
       
        
       
        
    }
    
    func sendMultipleImagesMessage(images: [UIImage], user: User, completion: @escaping (Bool) -> ()){
        let dp = DispatchGroup()
        let messageID = UUID().uuidString
        
        var urls : [String] = []
        dp.enter()
            for image in images{
                dp.enter()
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
                        
                      
                            urls.append(downloadedURL?.absoluteString ?? " ")
                            self.imagesSent += 1
                            dp.leave()
                            
                        }
                        
                    }
                    
                    
                }
            }
        dp.leave()
        dp.notify(queue: .main, execute:{
            let imageMessageData = ["name":user.nickName ?? "",
                                    "timeStamp":Timestamp(),
                                    "id":messageID,
                                    "profilePicture":user.profilePicture ?? "",
                                    "type":"multipleImages",
                                    "userID":user.id ?? " ",
                                    "urls":urls] as! [String:Any]
            COLLECTION_PERSONAL_CHAT.document(self.chat.id).collection("Messages").document(messageID).setData(imageMessageData)
            
                 COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastMessageID":messageID])
                 
                 COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
                 
                 COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastActionDate":Timestamp()])
            return completion(true)

        })
        
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
                    print("here 1")
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
                        print("here 2")
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastMessageID":messageID])
                        
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])
                        
                        COLLECTION_PERSONAL_CHAT.document(self.chat.id).updateData(["lastActionDate":Timestamp()])
                        return completion(true)
                    })
                }
                
            }else{
                return completion(false)
            }
            
            
        }
    }
    
    func sendTextMessage(text: String, user: User, timeStamp: Timestamp, nameColor: String, messageID: String, messageType: String, chatID: String, completion: @escaping (Bool) -> ()) -> (){
        
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
        self.sendingMedia = true
        self.sendingMediaID.append(messageID)
        self.text = ""
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
            if self.sendingMedia {
                self.sendingMedia = false
                self.failedToSend = true
                return completion(false)
            }
        })
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).setData(textMessageData, completion: { err in
            if err != nil {
                print("ERROR")
                self.sendingMedia = false
                self.failedToSend = true
                return completion(false)
            }else{
                
                dp.leave()
            }
            
        })
        
        
        dp.notify(queue: .main, execute:{
            self.notificationSender.sendPushNotification(to: user.id ?? "", title: user.nickName ?? "", body: text)
            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastMessageID":messageID])

            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["usersThatHaveSeenLastMessage":[user.id ?? " "]])

            COLLECTION_PERSONAL_CHAT.document(chatID).updateData(["lastActionDate":Timestamp()])
            
            self.sendingMedia = false
            self.failedToSend = false
            self.sendingMediaID.removeAll(where: {$0 == messageID})
            self.text = ""
            return completion(true)
        })
        
        
        
    }
    
    func getLastMessage() -> Message{
        return self.messages.last ?? Message()
    }
    
    
    
    
    
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
    
    
    func listenToChat(chatID: String){
        
        print("Chat Removed!")
        chatListener?.remove()
        chatListener = COLLECTION_PERSONAL_CHAT.document(chatID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var data = snapshot?.data() ?? [:]
            let users = data["usersID"] as? [String] ?? []
            let lastMessageID = data["lastMessageID"] as? String ?? " "
            let usersTypingID = data["usersTypingID"] as? [String] ?? []
            let usersIdlingID = data["usersIdlingID"] as? [String] ?? []
            let id = data["id"] as? String ?? ""
            let groupD = DispatchGroup()
            
            
            //fetch all chat users
            groupD.enter()
            self.fetchChatUsers(users: users) { fetchedUsers in
                data["users"] = fetchedUsers
                groupD.leave()
            }

            groupD.enter()

            self.fetchLastMessage(chatID: chatID, messageID: lastMessageID){ fetchedMessage in
                data["lastMessage"] = fetchedMessage
                groupD.leave()
            }

            groupD.enter()
            self.fetchChatUsers(users: usersIdlingID){ fetchedUsers in
                data["usersIdling"] = fetchedUsers
                groupD.leave()
            }


            groupD.enter()
            self.fetchChatUsers(users: usersTypingID){ fetchedUsers in
                data["usersTyping"] = fetchedUsers
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute:{
                print("fetched chat!")
                self.chat = ChatModel(dictionary: data)
            })
            
        }
    }
    
    
    
    
    func fetchLastMessage(chatID: String, messageID: String, completion: @escaping (Message) -> ()) -> () {
        COLLECTION_PERSONAL_CHAT.document(chatID).collection("Messages").document(messageID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data() as? [String:Any] ?? [:]
            return completion(Message(dictionary: data))
            
        }
    }
    
    
    
}
