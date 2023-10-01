//
//  UserViewModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/9/21.
//
import Foundation
import Firebase
import SwiftUI
import Combine
import Network
import FirebaseStorage

class UserViewModel : ObservableObject {
    
    

    
    
    let notificationSender = PushNotificationSender()
    //firebase
    @Published var userSession : FirebaseAuth.User?
    @Published var firestoreListeners : [ListenerRegistration] = []
    @Published var user : User?
    @Published var loginErrorMessage = ""
    
    @Published var groups: [GroupModel] = []
    @Published var personalChats: [ChatModel] = []
    @Published var notifications : [UserNotificationModel] = []
    
    
    @Published var showNotification : Int = 0 //on value change, send notification
    @Published var fcmToken : String?
    @Published var hideTabButtons : Bool = false
    @Published var showAddContent : Bool = false
    @Published var finishedFetchingGroups : Bool = false
    @Published var timedOut : Bool = false
    @Published var startFetch : Bool = false
    @Published var showWarning: Bool = false
    @Published var hasUnreadMessages : Bool = false
    @Published var hideBackground: Bool = false
    @Published var unreadChatsCount : Int = 0
    @Published var unreadNotificationsCount: Int = 0
    @Published var notificationsCount : Int = 0
    let monitor = NWPathMonitor()
    let queue = DispatchQueue(label: "Monitor")
    @Published private(set) var connected: Bool? = nil
    @Published var userListener : ListenerRegistration?
    static let shared = UserViewModel()
    let store = Firestore.firestore()
    let path = "Users"
    
    
    private var cancellables : Set<AnyCancellable> = []
    
    init(){
        let dp = DispatchGroup()
        dp.enter()
        self.userSession = Auth.auth().currentUser
        
        dp.leave()
        
        dp.notify(queue: .main, execute: {
            self.checkConnection()
            self.beginListening()
        })
        
    }
    
    
    func beginListening(){
        let dp = DispatchGroup()
        dp.enter()
        
        self.removeListeners()
        dp.leave()
        dp.notify(queue: .main, execute:{
            self.listenToAll(uid: self.userSession?.uid ?? " ")
            let uid = self.userSession?.uid ?? " "
            print("user_id: \(uid)")
        })
    }
    
    func checkConnection() {
        DispatchQueue.main.async{
            self.monitor.pathUpdateHandler = { path in
                DispatchQueue.main.async{
                    self.connected = (path.status == .satisfied)
                }
            }
            self.monitor.start(queue: self.queue)
        }
    }
    
    func endConnection(){
        DispatchQueue.main.async{
            self.monitor.cancel()
        }
    }
    
    func followGroup(groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["followersID":FieldValue.arrayUnion([userID])])
        COLLECTION_USER.document(userID).updateData(["groupsFollowingID":FieldValue.arrayUnion([groupID])])
    }
    
    func unfollowGroup(groupID: String, userID: String){
        COLLECTION_GROUP.document(groupID).updateData(["followersID":FieldValue.arrayRemove([userID])])
        COLLECTION_USER.document(userID).updateData(["groupsFollowingID":FieldValue.arrayRemove([groupID])])
    }
    
    
    
    func refresh(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            if !self.finishedFetchingGroups && !self.timedOut{
                self.timedOut = true
                self.startFetch = false
            }
        }
    }
    
    //listeners
    
    
    func getTotalNotifications(userID: String) -> Int {
        var sum = 0
        for chat in self.personalChats{
            if !(chat.usersThatHaveSeenLastMessage?.contains(userID) ?? false ){
                sum += 1
            }
        }
        return sum
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
    
    func getUnreadNotificationsCount(notifications: [UserNotificationModel]) -> Int {
        var count : Int = 0
        for noti in notifications {
            if !(noti.hasSeen ?? false){
                count += 1
            }
        }
        return count
    }
    
    func getUnreadChatCount(chats: [ChatModel]) -> Int {
        var count : Int = 0
        for chat in chats {
            if !(chat.usersThatHaveSeenLastMessage?.contains(self.user?.id ?? " ") ?? false){
                count += 1
            }
        }
        return count
    }
    
    func listenToNotifications(userID: String){
        self.firestoreListeners.append(
            
            COLLECTION_USER.document(userID).collection("Notifications").order(by: "timeStamp", descending: true).addSnapshotListener({ snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                var notificationsToReturn : [UserNotificationModel] = []
                let groupD = DispatchGroup()
                
                
                let documents = snapshot!.documents
                
                groupD.enter()
                for document in documents{
                    var data = document.data() as? [String:Any] ?? [:]
                    var type = data["type"] as? String ?? ""
                    var eventID = data["eventID"] as? String ?? ""
                    var groupID = data["groupID"] as? String ?? ""
                    var senderID = data["senderID"] as? String ?? ""
                    var receiverID = data["receiverID"] as? String ?? ""
                    
                    if eventID != "" {
                        groupD.enter()
                        self.fetchNotificationEvent(eventID: eventID) { fetchedEvent in
                            data["event"] = fetchedEvent
                            groupD.leave()
                        }
                    }
                    
                    if groupID != "" {
                        groupD.enter()
                        self.fetchNotificationGroup(groupID: groupID) { fetchedGroup in
                            data["group"] = fetchedGroup
                            groupD.leave()
                        }
                    }
                    
                    if senderID != "" {
                        groupD.enter()
                        self.fetchNotificationUser(userID: senderID) { fetchedUser in
                            data["sender"] = fetchedUser
                            groupD.leave()
                        }
                    }
                    
                    if receiverID != "" {
                        groupD.enter()
                        self.fetchNotificationUser(userID: receiverID) { fetchedUser in
                            data["receiver"] = fetchedUser
                            groupD.leave()
                        }
                    }
                    
                    
                    groupD.notify(queue: .main, execute:{
                        notificationsToReturn.append(UserNotificationModel(dictionary: data))
                    })
                    
                }
                groupD.leave()
                
                groupD.notify(queue: .main, execute:{
                    self.notifications = notificationsToReturn
                    self.unreadNotificationsCount = self.getUnreadNotificationsCount(notifications: notificationsToReturn)
                })
                
            })
            
            
            
        )
    }
    
    func listenToPersonalChats(userID: String){
        
        self.firestoreListeners.append( COLLECTION_PERSONAL_CHAT.whereField("usersID", arrayContains: userID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            var chatsToReturn : [ChatModel] = []
            let groupD = DispatchGroup()
            
            
            let documents = snapshot!.documents
            
            groupD.enter()
            for document in documents{
                var data = document.data()
                var groupID = data["groupID"] as? String ?? " "
                let usersID = data["usersID"] as? [String] ?? []
                let lastMessageID = data["lastMessageID"] as? String ?? " "
                let usersTypingID = data["usersTypingID"] as? [String] ?? []
                let usersThatHaveSeenLastMessage = data["usersThatHaveSeenLastMessage"] as? [String] ?? []
                let id = data["id"] as? String ?? " "
                let chatType = data["chatType"] as? String ?? ""
                
                groupD.enter()
                self.fetchChatUsers(users: usersID) { fetchedUsers in
                    data["users"] = fetchedUsers
                    groupD.leave()
                }
                groupD.enter()
                self.fetchLastMessage(chatID: id, messageID: lastMessageID) { fetchedMessage in
                    data["lastMessage"] = fetchedMessage
                    groupD.leave()
                }
                
                groupD.enter()
                self.fetchUsersTyping(chatID: id, usersTypingID: usersTypingID){ fetchedUsers in
                    data["usersTyping"] = fetchedUsers
                    groupD.leave()
                }
                
                if chatType == "groupChat"{
                    //fetch group
                    groupD.enter()
                    self.fetchGroup(groupID: groupID) { fetchedGroup in
                        data["group"] = fetchedGroup
                        groupD.leave()
                    }
                }

                groupD.notify(queue: .main, execute:{
                    chatsToReturn.append(ChatModel(dictionary: data))
                })
                
            }
            groupD.leave()
            
            groupD.notify(queue: .main, execute:{
                self.personalChats = chatsToReturn
                self.unreadChatsCount = self.getUnreadChatCount(chats: chatsToReturn)
            })
            
        }
        )
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
    
    func fetchUsersTyping(chatID: String, usersTypingID: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        var groupD = DispatchGroup()
        
        for userID in usersTypingID {
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
    
    
    
    
    
    
    func listenToUser(uid: String){
        self.firestoreListeners.append(COLLECTION_USER.document(uid).addSnapshotListener { (snapshot, err) in
            
            
            if err != nil {
                print("ERROR - User Not Being Fetched")
                return
            }
            
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            let usersLoggedInCount = data["usersLoggedInCount"] as? Int ?? 0
            var appIconBadgeNumber = data["appIconBadgeNumber"] as? Int ?? 0
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            //fetch user friends list
            self.fetchUserFriendsList(friendsList: data["friendsListID"] as? [String] ?? []) { fetchedFriends in
                data["friendsList"] = fetchedFriends
                groupD.leave()
            }
            
 
            groupD.notify(queue: .main, execute:{
                UIApplication.shared.applicationIconBadgeNumber = appIconBadgeNumber
                self.user = User(dictionary: data)
            })
            
            
            
        })
        
        
    }
    
    
    
    
    func listenToUserGroups(uid: String){
        
        self.firestoreListeners.append( COLLECTION_GROUP.whereField("usersID", arrayContains: uid).addSnapshotListener { (snapshot, err) in
            
            if err != nil {
                print("ERROR! find")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            var groupsToReturn : [GroupModel] = []
            
            //fetching notifications
            
            
            
            let groupD = DispatchGroup()
            
            
            for document in documents {
                var data = document.data()
                var usersID = data["usersID"] as? [String] ?? []
                
                //                  self.fetchGroupNotifications(groupID: document.documentID) { fetchedNotifications in
                //                      data["groupNotifications"] = fetchedNotifications
                //                      groupD.leave()
                //                  }
                //
                //                  groupD.enter()
                //
                //                  self.fetchGroupUnreadNotifications(userID: uid, groupID: data["id"] as? String ?? " ") { fetchedUnreadNotifications in
                //                      data["unreadGroupNotifications"] = fetchedUnreadNotifications
                //                      groupD.leave()
                //                  }
                groupD.enter()
                self.fetchGroupUsers(usersID: usersID) { fetchedUsers in
                    data["users"] = fetchedUsers
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    groupsToReturn.append(GroupModel(dictionary: data))
                })
                
            }
            
            
            
            groupD.notify(queue: .main, execute: {
                self.groups = groupsToReturn
                //                  self.encodeGroups(groups: groupsToReturn)
                self.finishedFetchingGroups = true
                //encode groups to local storage
                
            })
            
        })
        
        
        
        
        
        
        
    }
    
    
    func fetchGroupUsers(usersID: [String],  completion: @escaping ([User]) -> ()) -> () {
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
    
    
    func deletePoll(pollID: String){
        COLLECTION_POLLS.document(pollID).delete()
    }
    
    func signIn(withEmail email: String, password: String, completion: @escaping (User) -> ()) -> (){
        
        Auth.auth().signIn(withEmail: email, password: password) { [self] (result,err) in
            
            if let x = err {
                let error = x as NSError
                switch error.code {
                    case AuthErrorCode.networkError.rawValue:
                        loginErrorMessage = "There was a network error"
                    case AuthErrorCode.internalError.rawValue:
                        loginErrorMessage = "There was an internal error"
                    case AuthErrorCode.invalidEmail.rawValue:
                        loginErrorMessage = "This email address is invalid"
                    case AuthErrorCode.missingEmail.rawValue:
                        loginErrorMessage = "You must include an email address"
                    case AuthErrorCode.rejectedCredential.rawValue:
                        loginErrorMessage = "The email or password is incorrect"
                        
                    default:
                        loginErrorMessage = "\(error.localizedDescription)"
                }
            }
            
            let dp = DispatchGroup()
            dp.enter()
            withAnimation(.spring()){
                self.userSession = result?.user
                print("id: \(self.userSession?.uid ?? "")")
                dp.leave()
            }
            
            dp.notify(queue: .main, execute:{
                self.beginListening()
            })
            
            
            
            
            
        }
        
    }
    
    
    
    func createUser(email:String,username:String,nickName:String,birthday: Date, password: String, profilePicture: UIImage, completion: @escaping (Bool) -> ()) -> (){
        let dp = DispatchGroup()
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            if let err = err{
                print("DEBUG: ERROR: \(err.localizedDescription)")
                return completion(false)
            }
            
            
            
            guard let user = result?.user else {return completion(false)}
            
            var data = ["email": email,
                        "username": username,
                        "nickName": nickName,
                        "uid": user.uid,
                        "birthday": birthday,"profilePicture":"", "bio":"","isActive":true,"dateCreated":Timestamp()
                        
                        
            ] as [String : Any]
            
            COLLECTION_USER.document(user.uid).setData(data)
            
            dp.enter()
            self.persistImageToStorage(userID: user.uid, image: profilePicture) { fetchedImage in
                data["profilePicture"] = fetchedImage
                
                dp.leave()
            }
            
            
            dp.notify(queue: .main, execute:{
                print("DEBUG: Succesfully uploaded user data!")
                
                withAnimation {
                    self.userSession = user
                }
                self.user = User(dictionary: data)
                self.beginListening()
                Auth.auth().currentUser?.sendEmailVerification(completion: { (err) in
                    
                })
                return completion(true)
            })
            
            
            
            
        }
    }
    
    func removeListeners(){
        for listener in firestoreListeners{
            listener.remove()
        }
    }
    
    func printListenersCount(){
        print("listener count: \(firestoreListeners.count)")
    }
    
    func signOut(){
        let dp = DispatchGroup()
        
        dp.enter()
        
        COLLECTION_USER.document(self.userSession?.uid ?? " ").getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            let usersLoggedInCount = data["usersLoggedInCount"] as? Int ?? 0
        }
        
        dp.leave()
        dp.notify(queue: .main, execute:{
            self.loginErrorMessage = ""
            try? Auth.auth().signOut()
            self.userListener?.remove()
            self.userSession = nil
            self.removeListeners()
        })
    }
    
    
    //fetch
    
    
    
    
    func fetchUser(userID: String, completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).getDocument { (snapshot, err) in
            if err != nil {
                print("ERROR")
                return
            }
            
            
            var data = snapshot?.data() as? [String:Any] ?? [:]
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            self.fetchUserFriendsList(friendsList: data["friendsList"] as? [String] ?? []) { fetchedFriends in
                data["friendsList"] = fetchedFriends
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute:{
                return completion(User(dictionary: data))
            })
            
            
        }
    }
    
    
    
    func persistImageToStorage(userID: String, image: UIImage, completion: @escaping (String) -> ()) -> () {
        let dp = DispatchGroup()
        dp.enter()
        let fileName = "userProfileImages/\(userID)"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        ref.putData(imageData, metadata: nil) { (metadata, err) in
            if err != nil{
                print("ERROR")
                return completion("")
            }
            ref.downloadURL { (url, err) in
                if err != nil{
                    print("ERROR: Failed to retreive download URL")
                    return
                }
                print("Successfully stored image in database")
                let imageURL = url?.absoluteString ?? ""
                COLLECTION_USER.document(userID).updateData(["profilePicture":imageURL])
                dp.leave()
                dp.notify(queue: .main, execute: {
                    return completion(imageURL)
                })
            }
        }
        
    }
    
    func fetchUserBlockedList(blockedList: [String], completion: @escaping ([User]) -> ()) -> (){
        var users : [User] = []
        
        var groupD = DispatchGroup()
        
        
        groupD.enter()
        
        for userID in blockedList {
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
        
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(users)
        })
        
    }
    
    func fetchUserPersonalChats(personalChats: [String], completion: @escaping ([ChatModel]) -> ()) -> () {
        var personalChatsToReturn : [ChatModel] = []
        var groupD = DispatchGroup()
        
        groupD.enter()
        for chat in personalChats {
            COLLECTION_PERSONAL_CHAT.document(chat).getDocument { snapshot , err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                var usersThatHaveSeenLastMessage = data["usersThatHaveSeenLastMessage"] as? [String] ?? []
                
                personalChatsToReturn.append(ChatModel(dictionary: data))
                
                
            }
        }
        
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(personalChatsToReturn)
        })
    }
    
    
    
    func fetchUserFriendsList(friendsList: [String], completion: @escaping ([User]) -> ()) -> (){
        var users : [User] = []
        
        var groupD = DispatchGroup()
        
        
        groupD.enter()
        
        for userID in friendsList {
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
        
        groupD.leave()
        
        groupD.notify(queue: .main, execute: {
            return completion(users)
        })
        
    }
    
    func fetchUserNotifications(userID: String, completion: @escaping ([UserNotificationModel]) -> ()) -> () {
        
        var notificationsToReturn : [UserNotificationModel] = []
        COLLECTION_USER.document(userID).collection("Notifications").order(by: "notificationTime", descending: true).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else{
                return
            }
            
            let groupD = DispatchGroup()
            
            groupD.enter()
            
            for document in documents {
                var data = document.data() as? [String:Any] ?? [:]
                var notificationType = data["notificationType"] as? String ?? " "
                var actionTypeID = data["actionTypeID"] as? String ?? " "
                var actionType = data["actionType"] as? String ?? " "
                
                
                
                groupD.enter()
                self.fetchUserNotificationCreator(notificationType: notificationType, notificationCreatorID: data["notificationCreatorID"] as? String ?? " ") { fetchedCreator in
                    data["notificationCreator"] = fetchedCreator
                    groupD.leave()
                    
                }
                
                groupD.enter()
                self.fetchUserNotificationAction(notificationActionType: actionType, notificationActionID: actionTypeID) { fetchedAction in
                    data["action"] = fetchedAction
                    groupD.leave()
                }
                
                
                
                
                
                
                
                groupD.notify(queue: .main, execute: {
                    notificationsToReturn.append(UserNotificationModel(dictionary: data))
                } )
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(notificationsToReturn)
            })
            
        }
    }
    
    
    
    func fetchNotificationEvent(eventID: String, completion: @escaping (EventModel) -> ()) -> (){
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
                
            }
            
            var groupD = DispatchGroup()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var creatorID = data["creatorID"] as? String ?? " "
            
            groupD.enter()
            self.fetchUser(userID: creatorID) { fetchedUser in
                data["creator"] = fetchedUser
                groupD.leave()
            }
            
            groupD.notify(queue: .main, execute: {
                return completion(EventModel(dictionary: data))
            })
        }
    }
    
    func fetchNotificationUser(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
        }
    }
    
    
    
    
    func fetchUserNotificationCreator(notificationType: String, notificationCreatorID: String, completion: @escaping (Any) -> ()) -> (){
        
        switch notificationType {
            case "eventCreated","invitedToEvent":
                self.fetchNotificationEvent(eventID: notificationCreatorID){ fetchedEvent in
                    return completion(fetchedEvent)
                }
            case "sentFriendRequest", "acceptedFriendRequest","sentGroupInvitation":
                self.fetchNotificationUser(userID: notificationCreatorID){ fetchedUser in
                    return completion(fetchedUser)
                }
            case "acceptedGroupInvitation":
                self.fetchNotificationGroup(groupID: notificationCreatorID){ fetchedGroup in
                    return completion(fetchedGroup)
                }
            default:
                return completion("not a valid notification yet")
        }
        
        
        
    }
    
    func fetchUserNotificationAction(notificationActionType: String, notificationActionID: String, completion: @escaping (Any) -> ()) -> (){
        
        switch notificationActionType {
            case "openGroup":
                self.fetchNotificationGroup(groupID: notificationActionID){ fetchedGroup in
                    return completion(fetchedGroup)
                }
            case "acceptedFriendRequest", "sentFriendRequest":
                self.fetchNotificationUser(userID: notificationActionID) { fetchedUser in
                    return completion(fetchedUser)
                }
            default:
                return completion("not a valid notification yet")
        }
        
        
        
    }
    
    
    func fetchNotificationGroup(groupID: String, completion: @escaping (GroupModel) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
            if err != nil{
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(GroupModel(dictionary: data))
        }
    }
    
    
    
    
    
    
    
    func fetchEventUsersAttending(usersAttendingID: [String], eventID: String , groupID: String, completion: @escaping ([User]) -> ()) -> (){
        
        var usersToReturn : [User] = []
        
        
        let groupD = DispatchGroup()
        
        for userID in usersAttendingID {
            groupD.enter()
            COLLECTION_USER.document(userID).getDocument { userSnapshot, err in
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
    
    
    
    
    
    
    func readUserNotification(userNotification: UserNotificationModel, userID: String){
        COLLECTION_USER.document(userID).collection("Notifications").document(userNotification.id).updateData(["hasSeen":true])
        COLLECTION_USER.document(userID).updateData(["userNotificationCount":0])
    }
    
    
    func concatenate(followedGroups: [GroupModel], groups: [GroupModel]) -> [GroupModel]{
        var arr1 : [GroupModel] = []
        arr1 = groups
        arr1.append(contentsOf: followedGroups)
        return arr1
    }
    
    func getIDS(userGroups: [GroupModel]) -> [String]{
        var arr : [String] = [""]
        for group in userGroups{
            arr.append(group.id)
        }
        return arr
    }
    
    
    
    func setUserActivity(isActive: Bool, userID: String, completion: @escaping (User) -> ()) -> (){
        COLLECTION_USER.document(userID).updateData(["isActive":isActive])
        if !isActive{
            COLLECTION_USER.document(userID).updateData(["lastActive":Timestamp()])
        }
        
        
        COLLECTION_USER.document(userID).getDocument(completion: { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            
            return completion(User(dictionary: data ?? [:] ))
            
        })
        
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
    
    func fetchGroupNotificationCreator(notificationCreatorID: String, completion: @escaping (User) -> ()) -> (){
        
        COLLECTION_USER.document(notificationCreatorID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            return completion(User(dictionary: data))
            
        }
        
    }
    
    func fetchGroupNotifications(groupID: String, completion: @escaping ([GroupNotificationModel]) -> ()) -> () {
        
        
        var notificationsToReturn : [GroupNotificationModel] = []
        COLLECTION_GROUP.document(groupID).collection("Notifications").getDocuments { snapshot, err in
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
                
                self.fetchGroupNotificationCreator(notificationCreatorID: data["notificationCreatorID"] as? String ?? " ") { fetchedUser in
                    data["notificationCreator"] = fetchedUser
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    notificationsToReturn.append(GroupNotificationModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(notificationsToReturn)
            })
            
            
            
            
        }
    }
    
    

    
    func listenToAll(uid: String){
        self.listenToUserGroups(uid: uid)
        //        self.listenToNetworkChanges(uid: uid)
        self.listenToUser(uid: uid)
        self.listenToPersonalChats(userID: uid)
        self.listenToNotifications(userID: uid)
    }
    
   
    

    
    func resetPassword(email: String){
        Auth.auth().sendPasswordReset(withEmail: email) { (err) in
            if err != nil {
                print("ERROR: \(err?.localizedDescription)")
            }
            
        }
        
    }
    
    
    func fetchUserGroups(){
        //TODO
        COLLECTION_GROUP.whereField("usersID", arrayContains: user?.id ?? "").getDocuments { (snapshot, err) in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
            
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            self.groups = documents.map{ queryDocumentSnapshot -> GroupModel in
                let data = queryDocumentSnapshot.data()
                
                
                
                
                return GroupModel(dictionary: data)
                
            }
            
            print("Fetched User Groups!")
            
            
        }
    }
    
    func fetchUser(){
        
        guard let uid = userSession?.uid else {return}
        
        store.collection(path).document(uid).getDocument { (snapshot, _) in
            guard let data = snapshot?.data() else {return}
            let user = User(dictionary: data)
            
            self.user = user
            
        }
    }
    
    
    
    
    
    
    
    
    func getUserFriendsList(user: User, completion: @escaping ([User]) -> () ) -> (){
        let friendsList = user.friendsList ?? []
        if !friendsList.isEmpty{
            COLLECTION_USER.whereField("uid", in: user.friendsList ?? [" "]).addSnapshotListener{ (snapshot, err) in
                if err != nil {
                    print("ERROR")
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No documents!")
                    return
                    
                }
                
                
                return completion(documents.map { (queryDocumentSnapshot) -> User in
                    let data = queryDocumentSnapshot.data()
                    return User(dictionary: data)
                })
                
                
                
            }
            
            
            
            
        }else{
            print("User has no friends!")
        }
        
        
    }
    
    
    func sendFriendRequest(friend: User, completion: @escaping (Bool) -> ()) -> () {
        
        if (friend.blockedAccountsID ?? []).contains(where: {$0 == self.user?.id ?? " "}){
            return completion(false)
        }else{
            let dp = DispatchGroup()
            dp.enter()
            COLLECTION_USER.document(self.user?.id ?? " ").updateData(["outgoingFriendInvitationID":FieldValue.arrayUnion([friend.id ?? " "])])
            
            COLLECTION_USER.document(friend.id ?? " ").updateData(["incomingFriendInvitationID":FieldValue.arrayUnion([user?.id ?? " "])])
            
            notificationSender.sendPushNotification(to: friend.fcmToken ?? " ", title: "\(self.user?.username ?? "")", body: "\(self.user?.nickName ?? "") sent a friend request")
            
            
            
            let notificationID = UUID().uuidString
            
            let userNotificationData = ["id":notificationID,
                                        "name": "Friend Request",
                                        "timeStamp":Timestamp(),
                                        "senderID":USER_ID,
                                        "receiverID":friend.id ?? " ",
                                        "hasSeen":false,
                                        "type":"sentFriendRequest",
                                        "requiresAction":true] as [String:Any]
            
            
            COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
            
            COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
            
            dp.leave()
            dp.notify(queue: .main, execute:{
                return completion(true)
            })
        }
        
        
    }
    
    func unsendFriendRequest(friend: User, completion: @escaping (Bool) -> ()) -> (){
        
        let dp = DispatchGroup()
        dp.enter()
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["outgoingFriendInvitationID":FieldValue.arrayRemove([friend.id ?? " "])])
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["incomingFriendInvitationID":FieldValue.arrayRemove([user?.id ?? " "])])
        
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "name": "Friend Request",
            "timeStamp":Timestamp(),
            "type":"rescindFriendRequest",
            "senderID":USER_ID,
            "receiverID":friend.id ?? " ",
            "hasSeen":false,
            "requiresAction":false] as [String:Any]
        
        
        COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
        
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").whereField("type", isEqualTo: "sentFriendRequest").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents!")
                return
                
            }
            
            for document in documents {
                let id = document.documentID
                COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(id).updateData(["requiresAction":false])
            }
            
        }
        
        dp.leave()
        dp.notify(queue: .main, execute: {
            return completion(true)
        })
    }
    
    
    func acceptFriendRequest(friend: User){
        
        
        //Removing from eachothers pending friends list
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["incomingFriendInvitationID":FieldValue.arrayRemove([friend.id ?? " "])])
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["outgoingFriendInvitationID":FieldValue.arrayRemove([self.user?.id ?? " "])])
        //END
        
        
        
        self.addFriend(friendID: friend.id ?? " "){ finished in
            print("Added Friend!")
        }
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "name": "Friend Request",
            "timeStamp":Timestamp(),
            "type":"acceptedFriendRequest",
            "senderID":USER_ID,
            "receiverID":friend.id ?? " ",
            "hasSeen":false,
            "finished":true] as [String:Any]
        
        
        COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
        
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        
        notificationSender.sendPushNotification(to: friend.fcmToken ?? " ", title: "\(self.user?.username ?? "")", body: "\(self.user?.nickName ?? "") accepted your friend request")
    }
    
    func denyFriendRequest(friend: User){
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["incomingFriendInvitationID":FieldValue.arrayRemove([friend.id ?? " "])])
        
        COLLECTION_USER.document(friend.id ?? " ").updateData(["outgoingFriendInvitationID":FieldValue.arrayRemove([user?.id ?? " "])])
        
        
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "name": "Friend Request",
            "timeStamp":Timestamp(),
            "type":"deniedFriendRequest",
            "senderID":USER_ID,
            "receiverID": friend.id ?? " ",
            "hasSeen":false,
            "finished":true] as [String:Any]
        
        
        COLLECTION_USER.document(friend.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
        
        
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        notificationSender.sendPushNotification(to: friend.fcmToken ?? " ", title: "\(self.user?.username ?? "")", body: "\(self.user?.nickName ?? "") denied your friend request")
    }
    
    func checkIfUsersHavePersonalChats(user1: String, user2: String, completion: @escaping (Bool) -> ()) -> (){
        COLLECTION_PERSONAL_CHAT.whereField("usersID", arrayContains: [user1,user2]).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            if snapshot?.documents.isEmpty ?? false{
                COLLECTION_PERSONAL_CHAT.whereField("usersID", arrayContains: [user2,user1]).getDocuments { snapshot, err in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                    return completion(!(snapshot?.documents.isEmpty ?? false))
                    
                }
            }else{
                return completion(true)
            }
            
        }
    }
    
    func deletePost(postID: String){
        COLLECTION_POSTS.document(postID).delete()
    }
    
    func updateGroupPostLike(postID: String, userID: String, actionToLike: Bool, completion: @escaping ([[String]]) -> ()) -> (){
        
        //user has liked post and not disliked
        //user has disliked and not liked
        
        let dp = DispatchGroup()
        COLLECTION_POSTS.document(postID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
                
                
                
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            var likedListID = data["likedListID"] as? [String] ?? []
            var dislikedListID = data["dislikedListID"] as? [String] ?? []
            
            if likedListID.contains(userID){
                // if user already liked, and goal is to dislike, then remove like and dislike
                //if user already liked, and goal is to like, remove like
                dp.enter()
                
                if !actionToLike{
                    
                    COLLECTION_POSTS.document(postID).updateData(["dislikedListID":FieldValue.arrayUnion([userID])])
                    dislikedListID.append(userID)
                }
                
                COLLECTION_POSTS.document(postID).updateData(["likedListID":FieldValue.arrayRemove([userID])])
                likedListID.removeAll(where: {$0 == userID})
                
                dp.leave()
                dp.notify(queue: .main, execute:{
                    
                    return completion([likedListID, dislikedListID])
                })
                
            }else if dislikedListID.contains(userID){
                //if user has already disliked, and goal is to like, then remove dislike and like
                //if user has already disliked, and goal is to dislike, then remove dislike
                dp.enter()
                if actionToLike{
                    
                    //like
                    COLLECTION_POSTS.document(postID).updateData(["likedListID":FieldValue.arrayUnion([userID])])
                    likedListID.append(userID)
                    
                }
                
                COLLECTION_POSTS.document(postID).updateData(["dislikedListID":FieldValue.arrayRemove([userID])])
                dislikedListID.removeAll(where: {$0 == userID})
                
                
                dp.leave()
                dp.notify(queue: .main, execute:{
                    
                    return completion([likedListID, dislikedListID])
                    
                })
            }
            else{
                dp.enter()
                if actionToLike{
                    COLLECTION_POSTS.document(postID).updateData(["likedListID":FieldValue.arrayUnion([userID])])
                    likedListID.append(userID)
                }else{
                    COLLECTION_POSTS.document(postID).updateData(["dislikedListID":FieldValue.arrayUnion([userID])])
                    dislikedListID.append(userID)
                }
                
                dp.leave()
                dp.notify(queue: .main, execute:{
                    
                    return completion([likedListID, dislikedListID])
                    
                })
                
            }
            
        }
        
        
    }
    
    
    
    func addFriend(friendID: String, completion: @escaping (Bool) -> ()) -> (){
        
        let dp = DispatchGroup()
        
        dp.enter()
        //add to eachothers friend list
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["friendsListID":FieldValue.arrayUnion([friendID])])
        
        
        COLLECTION_USER.document(friendID ).updateData(["friendsListID":FieldValue.arrayUnion([user?.id ?? " "])])
        
        
        
        self.checkIfUsersHavePersonalChats(user1: self.user?.id ?? " ", user2: friendID, completion: { usersHaveChat in
            if !usersHaveChat{
                
                print("Creating new personal chat!")
                let id = UUID().uuidString
                let chatData = ["dateCreated":Date(),
                                "usersID":[friendID,self.user?.id ?? " "],
                                "id":id,
                                "chatType":"personal","lastMessageID":"NO_MESSAGE"] as [String:Any]
                //create personal chat
                COLLECTION_PERSONAL_CHAT.document(id).setData(chatData){ err in
                    if err != nil {
                        print("ERROR")
                        return
                    }
                }
                //picks colors
                
                
                COLLECTION_USER.document(self.user?.id ?? " ").updateData(["personalChatsID":FieldValue.arrayUnion([id])])
                
                COLLECTION_USER.document(friendID).updateData(["personalChatsID":FieldValue.arrayUnion([id])])
            }
        })
        dp.leave()
        
        dp.notify(queue: .main, execute:{
            return completion(true)
        })
    }
    
    
    
    func removeFriend(friendID: String, sendNotification: Bool = true, completion: @escaping (Bool) -> ()) -> () {
        
        
        //friends list
        let dp = DispatchGroup()
        
        dp.enter()
        
        COLLECTION_USER.document(self.user?.id ?? " ").updateData(["friendsListID":FieldValue.arrayRemove([friendID])])
        COLLECTION_USER.document(friendID).updateData(["friendsListID":FieldValue.arrayRemove([self.user?.id ?? " "])])
        
        
        
        COLLECTION_PERSONAL_CHAT.whereField("usersID", isEqualTo: [friendID,self.user?.id ?? " "]).getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            print("got here")
            
            let documents = snapshot!.documents
            if documents.isEmpty{
                COLLECTION_PERSONAL_CHAT.whereField("usersID", isEqualTo: [self.user?.id ?? " ",friendID]).getDocuments { snapshot, err in
                    let documents = snapshot!.documents
                    for document in documents {
                        let id = document.get("id") as? String ?? " "
                        COLLECTION_PERSONAL_CHAT.document(id).delete()
                        print("Chat Deleted")
                    }
                }
            }else{
                for document in documents {
                    let id = document.get("id") as? String ?? " "
                    COLLECTION_PERSONAL_CHAT.document(id).delete()
                    print("Chat Deleted")
                }
            }
            
        }
        
        if sendNotification{
        let notificationID = UUID().uuidString
        
        let userNotificationData = ["id":notificationID,
                                    "timeStamp":Timestamp(),
                                    "senderID":USER_ID,
                                    "receiverID":friendID,
                                    "hasSeen":false,
                                    "type":"removedFriend",
                                    "requiresAction":false] as [String:Any]
        
        
        COLLECTION_USER.document(friendID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
        }
        
        
        dp.leave()
        
        dp.notify(queue: .main, execute: {
            return completion(true)
        })
        
    }
    
    
    
    
    
    func unblockUser(unblocker: String, blockee: String){
        COLLECTION_USER.document(unblocker).updateData(["blockedAccountsID":FieldValue.arrayRemove([blockee])])
        COLLECTION_USER.document(blockee).updateData(["blockedAccountsID":FieldValue.arrayRemove([unblocker])])
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = ["id":notificationID,
                                    "timeStamp":Timestamp(),
                                    "senderID":USER_ID,
                                    "receiverID":blockee,
                                    "hasSeen":false,
                                    "type":"unblockedUser",
                                    "requiresAction":false] as [String:Any]
        
        
        COLLECTION_USER.document(blockee).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
    }
    
    
    func blockUser(blocker: String, blockee: String){
        COLLECTION_USER.document(blocker).updateData(["blockedAccountsID":FieldValue.arrayUnion([blockee])])
        COLLECTION_USER.document(blockee).updateData(["blockedAccountsID":FieldValue.arrayUnion([blocker])])
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = ["id":notificationID,
                                    "timeStamp":Timestamp(),
                                    "senderID":USER_ID,
                                    "receiverID":blockee,
                                    "hasSeen":false,
                                    "type":"blockedUser",
                                    "requiresAction":false] as [String:Any]
        
        
        COLLECTION_USER.document(blockee).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        
        
        self.removeFriend(friendID: blockee, sendNotification: false){ finished in
            print("removed friend")
        }
    }
    
    
    
    
    
    
    func fetchChat(chatID: String, completion: @escaping (ChatModel) -> ()) -> (){
        COLLECTION_CHAT.document(chatID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot!.data()
            return completion(ChatModel(dictionary: data ?? [:]))
            
        }
    }
    
    
    
    
    
    
    
    
    func fetchGroupBadges(groupID: String, completion: @escaping ([Badge]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("Badges").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            return completion(documents.map({ queryDocumentSnapshot -> Badge in
                let data = queryDocumentSnapshot.data()
                return Badge(dictionary: data)
            }))
            
            
        }
    }
    
    func fetchGroupPolls(groupID: String, completion: @escaping ([PollModel]) -> ()) -> () {
        COLLECTION_GROUP.document(groupID).collection("Polls").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let documents = snapshot!.documents
            
            return completion(documents.map({ queryDocumentSnapshot -> PollModel in
                let data = queryDocumentSnapshot.data()
                
                return PollModel(dictionary: data)
            }))
        }
    }
    
    
    
    
    func fetchGroupStories(groupID: String, completion: @escaping ([StoryModel]) -> ()){
        
        
        COLLECTION_GROUP.document(groupID).collection("Story").getDocuments { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            return completion(snapshot!.documents.map({ queryDocumentSnapshot -> StoryModel in
                let data = queryDocumentSnapshot.data()
                
                return StoryModel(dictionary: data)
            }))
            
        }
        
        
    }
    
    
    
    
    func answerPollOption(poll: PollModel, pollOption: PollOptionModel, userID: String, completion: @escaping (PollModel) -> ()) -> (){
        let groupD = DispatchGroup()
        
        groupD.enter()
        //updates poll option picked users
        if !(poll.usersAnsweredID?.contains(userID) ?? false){
            COLLECTION_POLLS.document(poll.id ?? " ").collection("Options").document(pollOption.id ?? " ").updateData(["pickedUsersID":FieldValue.arrayUnion([userID])])
            
            COLLECTION_GROUP.document(poll.groupID ?? "").collection("Polls").document(poll.id ?? " ").collection("Options").document(pollOption.id ?? " ").updateData(["pickedUsersID":FieldValue.arrayUnion([userID])])
            
            //update poll answered users
            COLLECTION_POLLS.document(poll.id ?? " ").updateData(["usersAnsweredID":FieldValue.arrayUnion([userID])])
            COLLECTION_GROUP.document(poll.groupID ?? "").collection("Polls").document(poll.id ?? " ").updateData(["usersAnsweredID":FieldValue.arrayUnion([userID])])
        }
        
        groupD.leave()
        groupD.notify(queue: .main, execute:{
            COLLECTION_POLLS.document(poll.id ?? " ").getDocument { snapshot, err in
                if err != nil{
                    print("ERROR")
                    return
                }
                var data = snapshot?.data() as? [String:Any] ?? [:]
                
                let groupID = data["groupID"] as? String ?? ""
                
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
        })
        
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
                
                
                groupD.enter()
                self.fetchUsersAnswered(usersID: data["pickedUsersID"] as? [String] ?? []){ fetchedUsers in
                    data["pickedUsers"] = fetchedUsers
                    
                    groupD.leave()
                }
                
                choicesToReturn.append(PollOptionModel(dictionary: data))
            }
            
            groupD.leave()
            
            groupD.notify(queue: .main, execute: {
                return completion(choicesToReturn)
            })
            
            
        }
    }
    
    func updateGroupEventLike(eventID: String, userID: String, actionToLike: Bool, completion: @escaping ([[String]]) -> ()) -> (){
        
        //user has liked post and not disliked
        //user has disliked and not liked
        
        let dp = DispatchGroup()
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
                
                
                
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            var likedListID = data["likedListID"] as? [String] ?? []
            var dislikedListID = data["dislikedListID"] as? [String] ?? []
            
            if likedListID.contains(userID){
                // if user already liked, and goal is to dislike, then remove like and dislike
                //if user already liked, and goal is to like, remove like
                dp.enter()
                
                if !actionToLike{
                    
                    COLLECTION_EVENTS.document(eventID).updateData(["dislikedListID":FieldValue.arrayUnion([userID])])
                    dislikedListID.append(userID)
                }
                
                COLLECTION_EVENTS.document(eventID).updateData(["likedListID":FieldValue.arrayRemove([userID])])
                likedListID.removeAll(where: {$0 == userID})
                
                dp.leave()
                dp.notify(queue: .main, execute:{
                    
                    return completion([likedListID, dislikedListID])
                })
                
            }else if dislikedListID.contains(userID){
                //if user has already disliked, and goal is to like, then remove dislike and like
                //if user has already disliked, and goal is to dislike, then remove dislike
                dp.enter()
                if actionToLike{
                    
                    //like
                    COLLECTION_EVENTS.document(eventID).updateData(["likedListID":FieldValue.arrayUnion([userID])])
                    likedListID.append(userID)
                    
                }
                
                COLLECTION_EVENTS.document(eventID).updateData(["dislikedListID":FieldValue.arrayRemove([userID])])
                dislikedListID.removeAll(where: {$0 == userID})
                
                
                dp.leave()
                dp.notify(queue: .main, execute:{
                    
                    return completion([likedListID, dislikedListID])
                    
                })
            }
            else{
                dp.enter()
                if actionToLike{
                    COLLECTION_EVENTS.document(eventID).updateData(["likedListID":FieldValue.arrayUnion([userID])])
                    likedListID.append(userID)
                }else{
                    COLLECTION_EVENTS.document(eventID).updateData(["dislikedListID":FieldValue.arrayUnion([userID])])
                    dislikedListID.append(userID)
                }
                
                dp.leave()
                dp.notify(queue: .main, execute:{
                    
                    return completion([likedListID, dislikedListID])
                    
                })
                
            }
            
        }
        
        
    }
    
    
    func editGroupPost(postID: String, editText: String){
        COLLECTION_POSTS.document(postID).updateData(["description":editText])
    }
    
    
}

