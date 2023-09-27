//
//  EventAttendanceViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/25/23.
//

import Foundation
import Firebase

class EventAttendanceViewModel : ObservableObject {
    
    @Published var event : EventModel = EventModel()
    @Published var eventListener : ListenerRegistration?
    @Published var isLoading : Bool = false
    
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
    
    func listenToEvent(eventID: String){
        eventListener = COLLECTION_EVENTS.document(eventID).addSnapshotListener { snapshot, err in
            let dp = DispatchGroup()
            self.isLoading = true
            if err != nil {
                print("ERROR")
            }
            print("listening to events")
            var data = snapshot?.data() as? [String:Any] ?? [:]
            var usersAttendingID = data["usersAttendingID"] as? [String] ?? []
            var usersUndecidedID = data["usersUndecidedID"] as? [String] ?? []
            var usersDeclinedID = data["usersDeclinedID"] as? [String] ?? []

            dp.enter()
            self.fetchUsers(usersID: usersAttendingID) { fetchedUsers in
                data["usersAttending"] = fetchedUsers
                dp.leave()
            }
            
            dp.enter()
            self.fetchUsers(usersID: usersUndecidedID) { fetchedUsers in
                data["usersUndecided"] = fetchedUsers
                dp.leave()
            }
            dp.enter()
            self.fetchUsers(usersID: usersDeclinedID) { fetchedUsers in
                data["usersDeclined"] = fetchedUsers
                dp.leave()
            }
            
            dp.notify(queue: .main, execute: {
                self.event = EventModel(dictionary: data)
                self.isLoading = false
            })
        }
    }
    
    func removeListener(){
        self.eventListener?.remove()
        print("removed")
    }
    
    
    func uninviteToEvent(userID: String, eventID: String){
        COLLECTION_USER.document(userID).updateData(["pendingEventInvitationID":FieldValue.arrayRemove([eventID])])
        
        COLLECTION_EVENTS.document(eventID).updateData(["usersUndecidedID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(eventID).updateData(["usersAttendingID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(eventID).updateData(["usersDeclinedID":FieldValue.arrayRemove([userID])])
        COLLECTION_EVENTS.document(eventID).updateData(["usersInvitedID":FieldValue.arrayRemove([userID])])

        var notificationID = UUID().uuidString
       
        
        
        var userNotificationData = ["id":notificationID,
            "timeStamp":Timestamp(),
            "senderID":USER_ID,
            "receiverID": userID,
            "eventID": eventID,
            "hasSeen":false,
            "type":"uninvitedToEvent"] as [String:Any]
        COLLECTION_USER.document(USER_ID).collection("Notifications").document(notificationID).setData(userNotificationData)
        
        COLLECTION_USER.document(userID).collection("Notifications").document(notificationID).setData(userNotificationData)
    }
}
