//
//  GroupCalendarViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/16/22.
//

import Foundation
import SwiftUI
import Combine






class GroupCalendarViewModel : ObservableObject {
    
    @Published var eventsResults : [EventModel] = []
    @Published var selectedOption : String = ""
  
    
    
   
    private var cancellables = Set<AnyCancellable>()
    
    func startSearch(group: GroupModel, startDay: Date, endDay: Date){
        self.fetchEvents(group: group, startDay: startDay, endDay: endDay)
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
    
    func fetchEvents(group: GroupModel, startDay: Date, endDay: Date) {
        COLLECTION_EVENTS.getDocuments { snapshot, err in
         
            if err != nil {
                print("ERROR")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No document!")
                return
            }
            
            var eventsToReturn : [EventModel] = []
            
            var groupD = DispatchGroup()
            
           
            groupD.enter()
            
            for document in documents {
                groupD.enter()

                var data = document.data()
                var startTime = data["eventStartTime"] as? Date ?? Date()
                let users = data["usersAttendingID"] as? [String] ?? []
                var groupID = data["groupID"] as? String ?? ""
                self.fetchEventUsersAttending(usersAttendingID: users, eventID: data["id"] as? String ?? " ", groupID: group.id) { fetchedUsers in
                    data["usersAttending"] = fetchedUsers
                    groupD.leave()
                }
                
                
                
                
                groupD.notify(queue: .main, execute: {
                    if group.id == groupID {
                        eventsToReturn.append(EventModel(dictionary: data))
                    }
                })
            }
            
            groupD.leave()
            
         
            
            groupD.notify(queue: .main, execute: {
                self.eventsResults = eventsToReturn
            })
            
        }
        
      
            
        
    }
    
    
}

extension Date {
    func isBetween(date date1: Date, andDate date2: Date) -> Bool {
        return date1.compare(self).rawValue * self.compare(date2).rawValue >= 0
    }
}
