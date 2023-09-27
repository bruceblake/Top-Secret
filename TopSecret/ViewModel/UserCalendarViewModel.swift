//
//  UserCalendarViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/20/22.
//

import Combine
import SwiftUI
import Foundation

class UserCalendarViewModel : ObservableObject {
    
    
    @Published var eventsResults : [EventModel] = []
    @Published var selectedOption : String = ""
    @Published var isLoading: Bool = false

    
   
    private var cancellables = Set<AnyCancellable>()
    
    func startSearch(eventsID: [String]){
        self.fetchEvents(eventsID: eventsID)
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
    
    func fetchEvents(eventsID: [String]) {
        self.isLoading = true
        let dp = DispatchGroup()
        var eventsToReturn : [EventModel] = []

        dp.enter()
        for id in eventsID{
            dp.enter()
            self.fetchEvent(eventID: id) { fetchedEvents in
                if let fetchedEvents = fetchedEvents{
                    eventsToReturn.append(fetchedEvents)
                }
                dp.leave()
            }
        }
        dp.leave()
      
        dp.notify(queue: .main, execute: {
            self.eventsResults = eventsToReturn
            self.isLoading = false
        })
        
    }
    
    func fetchEvent(eventID: String, completion: @escaping (EventModel?) -> ()){
        COLLECTION_EVENTS.document(eventID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return completion(nil)
            }
            let dp = DispatchGroup()
            
            guard var data = snapshot?.data() else {return completion(nil)}
            var creatorID = data["creatorID"] as? String ?? " "
            dp.enter()
            self.fetchCreator(creatorID: creatorID) { fetchedCreator in
                data["creator"] = fetchedCreator
                dp.leave()
            }
           print("fetching event")
            dp.notify(queue: .main, execute: {
                return completion(EventModel(dictionary: data))
            })
            
        }
    }
    
    
    func fetchCreator(creatorID: String, completion: @escaping (User) -> ()){
        COLLECTION_USER.document(creatorID).getDocument { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            return completion(User(dictionary: data))
        }
    }
    
    
}





