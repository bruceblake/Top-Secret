//
//  EventsTabViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/20/23.
//

import Foundation
import Firebase

class EventsTabViewModel: ObservableObject {
    @Published var openToFriendsEvents: [EventModel] = []
    @Published var inviteOnlyEvents: [EventModel] = []
    @Published var attendingEvents: [EventModel] = []
    @Published var discoverEvents: [EventModel] = []
    @Published var pastEvents: [EventModel] = []
    @Published var isLoadingOpenToFriends: Bool = true
    @Published var isLoadingInviteOnlyEvents: Bool = true
    @Published var isLoadingAttendingEvents: Bool = true
    @Published var isLoadingDiscoverEvents: Bool = true
    @Published var isLoadingPastEvents: Bool = true
    @Published var radius: Int = 1
    @Published var listeners : [ListenerRegistration] = []
    @Published var showRSVPScreen: Bool = false
    
        
    func removeListeners(){
        for listener in self.listeners ?? []{
            listener.remove()
        }
    }
    
    func listenToEvents(){
        self.fetchAttendingEvents(user: userVM.user ?? User())
        self.fetchDiscoverEvents(user: userVM.user ?? User())
        self.fetchOpenToFriendsEvents(user: userVM.user ?? User())
        self.fetchInvitedToEvents(user: userVM.user ?? User())
        self.fetchPastEvents(user: userVM.user ?? User())
    }
    
    func fetchUsers(usersID: [String], completion: @escaping ([User]) -> ()) -> (){
        var usersToReturn : [User] = []
        let dp = DispatchGroup()
        dp.enter()
        for id in usersID {
            dp.enter()
            COLLECTION_USER.document(id).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                usersToReturn.append(User(dictionary: data))
                dp.leave()
            }
        }
        dp.leave()
        
        dp.notify(queue: .main, execute: {
            return completion(usersToReturn)
        })
    }

    
    func getFriendsAttending(event: EventModel, user: User) -> [User]{
        var friendsToReturn : [User] = []
        for attendingID in event.usersAttendingID ?? [] {
            for friend in user.friendsList ?? [] {
                if attendingID == friend.id ?? " "{
                    friendsToReturn.append(friend)
                }
            }
        }
        return friendsToReturn
    }
    
    func fetchUserEvents(eventsID: [String], completion: @escaping ([EventModel]) -> ()) -> (){
        let dp = DispatchGroup()
        var eventsToReturn : [EventModel] = []
        for id in eventsID{
            dp.enter()
            COLLECTION_EVENTS.document(id).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]

                eventsToReturn.append(EventModel(dictionary: data))
                dp.leave()

            }
            
        }
        
        dp.notify(queue: .main, execute: {
            return completion(eventsToReturn)
        })
                
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
    
    func fetchEventCreator(userID: String, completion: @escaping (User) -> ()) -> () {
        COLLECTION_USER.document(userID).getDocument { snapshot, err in
            if err != nil{
                print("Error")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(User(dictionary: data))
        }
    }
    
 
    
    
    func inviteToEvent(userID: String, invitedIDS: [User], event: EventModel){

        for invitedMember in invitedIDS {
                COLLECTION_USER.document(invitedMember.id ?? " ").updateData(["pendingEventInvitationID":FieldValue.arrayUnion([event.id])])
                COLLECTION_EVENTS.document(event.id).updateData(["usersUndecidedID":FieldValue.arrayUnion([invitedMember.id ?? " "])])
                COLLECTION_EVENTS.document(event.id).updateData(["usersInvitedID":FieldValue.arrayUnion([invitedMember.id ?? " "])])

                var notificationID = UUID().uuidString
               
                
                
                var userNotificationData = ["id":notificationID,
                    "name": "Invite To Event",
                    "timeStamp":Timestamp(),
                    "senderID":USER_ID,
                    "receiverID": invitedMember.id ?? " ",
                    "eventID": event.id,
                    "hasSeen":false,
                    "type":"invitedToEvent"] as [String:Any]
                COLLECTION_USER.document(invitedMember.id ?? " ").collection("Notifications").document(notificationID).setData(userNotificationData)
//                self.notificationSender.sendPushNotification(to: invitedMember.fcmToken ?? " ", title: "\(group.groupName)", body: "\(invitedMember.nickName ?? " ") created an event!")
            
            
        }
    }
    
   
 
   
   
    
    func declineEvent(userID: String, event: EventModel) {
        // TODO: Implement leave event
        
        let notificationID = UUID().uuidString
        
        let userNotificationData = [
            "id":notificationID,
            "timeStamp":Timestamp(),
            "type":"declinedEventInvitation",
            "eventID": event.id,
            "userID": event.creatorID ?? " ",
            "hasSeen":false] as [String:Any]
        
        for userID in event.usersAttendingID ?? [] {
            COLLECTION_USER.document(userID).collection("Notifications").document(notificationID).setData(userNotificationData)
        }
        COLLECTION_EVENTS.document(event.id).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersDeclinedID":FieldValue.arrayUnion([userID])])
        COLLECTION_USER.document(userID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([event.id])])
        COLLECTION_EVENTS.document(event.id).updateData(["usersUndecidedID":FieldValue.arrayRemove([userID])])
        COLLECTION_USER.document(userID).updateData(["eventsID":FieldValue.arrayRemove([event.id])])
    }
    
    
    func fetchEvent(eventID: String, completion: @escaping (EventModel) -> ()) -> (){
        let dp = DispatchGroup()
        
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            dp.enter()
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var creatorID = data["creatorID"] as? String ?? ""
            self.fetchEventCreator(userID: creatorID) { fetchedUser in
                data["creator"] = fetchedUser
                dp.leave()
            }
            dp.notify(queue: .main, execute:{
                return completion(EventModel(dictionary: data))
            })
        }
    }
    
    
    func fetchPastEvents(user: User){
        let dp = DispatchGroup()
        var eventsToReturn: [EventModel] = []
        self.isLoadingPastEvents = true
        var query = COLLECTION_EVENTS
        self.listeners.append(query.order(by: "eventStartTime", descending: false).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            dp.enter()

            for document in snapshot?.documents ?? [] {
                var data = document.data()
                var userID = data["creatorID"] as? String ?? " "
                var usersAttendingID = data["usersAttendingID"] as? [String] ?? []
                var ended = data["ended"] as? Bool ?? false
                dp.enter()
                self.fetchEventCreator(userID: userID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dp.leave()
                }
                dp.enter()
                self.fetchUsers(usersID: usersAttendingID) { fetchedAttendingInvitedd in
                    data["usersAttending"] = fetchedAttendingInvitedd
                    dp.leave()
                }
                dp.notify(queue: .main, execute: {
                    if ended && usersAttendingID.contains(where: {$0 == user.id ?? " "}){
                        eventsToReturn.append(EventModel(dictionary: data))
                    }
                })
                
            }
            
            dp.leave()
            dp.notify(queue: .main, execute: {
                self.pastEvents = eventsToReturn
                self.isLoadingPastEvents = false
            })
        })
    }
    
    func fetchDiscoverEvents(user: User){
        let dp = DispatchGroup()
        var eventsToReturn: [EventModel] = []
        self.isLoadingDiscoverEvents = true


        self.listeners.append(COLLECTION_EVENTS.whereField("invitationType", isEqualTo: "Discover").order(by: "eventStartTime", descending: false).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            dp.enter()


            for document in snapshot?.documents ?? [] {
                var data = document.data()
                var userID = data["creatorID"] as? String ?? " "
                var usersAttendingID = data["usersAttendingID"] as? [String] ?? []
                var startTime = data["eventStartTime"] as? Date ?? Date()
                var endTime = data["eventEndTime"] as? Date ?? Date()
                var id = data["id"] as? String ?? " "
                dp.enter()
                self.fetchEventCreator(userID: userID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dp.leave()
                }
                dp.enter()
                self.fetchUsers(usersID: usersAttendingID) { fetchedAttendingInvited in
                    data["usersAttending"] = fetchedAttendingInvited
                    dp.leave()
                }
                dp.notify(queue: .main, execute: {
                    
                            eventsToReturn.append(EventModel(dictionary: data))

                })
                
            }
            
            dp.leave()
            dp.notify(queue: .main, execute: {
                self.discoverEvents = eventsToReturn
                self.isLoadingDiscoverEvents = false
            })
        })
    }
    
    func fetchAttendingEvents(user: User){
        let dp = DispatchGroup()
        var eventsToReturn: [EventModel] = []
        self.isLoadingAttendingEvents = true


        self.listeners.append(COLLECTION_EVENTS.order(by: "eventStartTime", descending: false).whereField("ended", isEqualTo: false).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            dp.enter()


            for document in snapshot?.documents ?? [] {
                var data = document.data()
                var userID = data["creatorID"] as? String ?? " "
                var usersAttendingID = data["usersAttendingID"] as? [String] ?? []
                var startTime = data["eventStartTime"] as? Date ?? Date()
                var endTime = data["eventEndTime"] as? Date ?? Date()
                var id = data["id"] as? String ?? " "
                dp.enter()
                self.fetchEventCreator(userID: userID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dp.leave()
                }
                dp.enter()
                self.fetchUsers(usersID: usersAttendingID) { fetchedAttendingInvited in
                    data["usersAttending"] = fetchedAttendingInvited
                    dp.leave()
                }
                dp.notify(queue: .main, execute: {
                    
                         if usersAttendingID.contains(where: {$0 == user.id ?? " "}){
                            eventsToReturn.append(EventModel(dictionary: data))
                        }
                    
                  
                    
                })
                
            }
            
            dp.leave()
            dp.notify(queue: .main, execute: {
                self.attendingEvents = eventsToReturn
                self.isLoadingAttendingEvents = false
            })
        })
        
    }
    
    func fetchOpenToFriendsEvents(user: User) {
        let dp = DispatchGroup()
        var eventsToReturn: [EventModel] = []
        self.isLoadingOpenToFriends = true
        var idList = user.friendsListID ?? []
        //fetch all the events that:
        //1. the invitation type is "Open to Friends"
        //2. the event has not ended
        //3. the creator is a friend of the user
        COLLECTION_EVENTS.order(by: "eventStartTime", descending: false).whereField("invitationType", isEqualTo: "Open to Friends").whereField("ended", isEqualTo: false).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            dp.enter()
            snapshot?.documents.forEach { document in
                
                var data = document.data()
                var userID = data["creatorID"] as? String ?? " "
                var usersUndecidedID = data["usersUndecidedID"] as? [String] ?? []
                var usersExcludedID = data["usersExcludedID"] as? [String] ?? []
                var usersInvitedID = data["usersInvitedID"] as? [String] ?? []
                var ended = data["ended"] as? Bool ?? false
                var id = data["id"] as? String ?? ""
                var endTime = data["eventEndTime"] as? Date ?? Date()
                var creatorID = data["creatorID"] as? String ?? ""
                dp.enter()
                
                self.fetchEventCreator(userID: userID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dp.leave()
                }
                
                dp.enter()
                self.fetchUsers(usersID: usersUndecidedID) { fetchedUndecidedUsers in
                    data["usersUndecided"] = fetchedUndecidedUsers
                    dp.leave()
                }
                
                dp.enter()
                self.fetchUsers(usersID: usersExcludedID) { fetchedExcludedUsers in
                    data["usersExcluded"] = fetchedExcludedUsers
                    dp.leave()
                }
                
                dp.notify(queue: .main, execute: {
                    if !usersExcludedID.contains(where: {$0 == user.id ?? " "}) && idList.contains(where: {$0 == creatorID}){
                        eventsToReturn.append(EventModel(dictionary: data))
                    }
                })
                
            }
            dp.leave()
            
            dp.notify(queue: .main, execute: {
                self.openToFriendsEvents = eventsToReturn
                self.isLoadingOpenToFriends = false
            })
            
            
        }
    }
    
    func fetchInvitedToEvents(user: User){
        var eventsToReturn: [EventModel] = []
        let dispatchGroup = DispatchGroup()
        self.listeners.append( COLLECTION_EVENTS.whereField("usersUndecidedID", arrayContains: user.id ?? " ").order(by: "eventStartTime", descending: false).addSnapshotListener { snapshot, err in
            if let err = err {
                print("Fetch events error: \(err.localizedDescription)")
            }
            self.isLoadingInviteOnlyEvents = true
            dispatchGroup.enter()

            snapshot?.documents.forEach { document in

                var data = document.data()
                var userID = data["creatorID"] as? String ?? " "
                var usersUndecidedID = data["usersUndecidedID"] as? [String] ?? []
                var usersInvitedID = data["usersInvitedID"] as? [String] ?? []
                var ended = data["ended"] as? Bool ?? false
                var id = data["id"] as? String ?? ""
                var endTime = data["eventEndTime"] as? Date ?? Date()
                dispatchGroup.enter()

                self.fetchEventCreator(userID: userID) { fetchedCreator in
                    data["creator"] = fetchedCreator
                    dispatchGroup.leave()
                }
                
                dispatchGroup.enter()
                self.fetchUsers(usersID: usersUndecidedID) { fetchedUndecidedUsers in
                    data["usersUndecided"] = fetchedUndecidedUsers
                    dispatchGroup.leave()
                }
                
                
                dispatchGroup.notify(queue: .main, execute: {
                    if !ended {
                      if usersInvitedID.contains(where: {$0 == user.id ?? " "}){
                            eventsToReturn.append(EventModel(dictionary: data))
                        }
                        
                    }
                })
                
            }
           
            dispatchGroup.leave()

            dispatchGroup.notify(queue: .main) {
                self.inviteOnlyEvents = eventsToReturn
                self.isLoadingInviteOnlyEvents = false
            }
        })
        
        

    }
    
  
    
    
}
