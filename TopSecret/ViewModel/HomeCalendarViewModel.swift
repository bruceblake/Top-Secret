//
//  HomeCalendarViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/14/22.
//

import Foundation
import SwiftUI
import Combine


class HomeCalendarViewModel : ObservableObject {
    
 
    @Published var eventsResults : [EventModel] = []
    @Published var eventsReturnedResults : [EventModel] = []
    @Published var countdownResults : [CountdownModel] = []
    @Published var countdownReturnedResults : [CountdownModel] = []
    @Published var selectedOption : String = ""
    @Published var currentDate : Date = Date()
    
    private var cancellables = Set<AnyCancellable>()
    

    func startSearch(groupID: String){
        self.fetchEvents(groupID: groupID)
    }
    
    func setCurrentDate(currentDate: Date){
        self.currentDate = currentDate
    }
    
   
    
    private func filterResults(selectedOption: String, eventsResults: [EventModel], countdownResults: [CountdownModel]) -> [[Any]]{
        
        var res : [[Any]] = []
        
        res.append(eventsResults.filter {
            let eventDate = $0.eventStartTime?.dateValue() ?? Date()
            
            let dateComponents = Calendar.current.dateComponents([.day, .hour, .second], from: eventDate)
            
    
            
            return dateComponents.day ?? 0 == Calendar.current.dateComponents([.day, .hour, .second], from: currentDate).day! && dateComponents.hour ?? 0 >= Calendar.current.dateComponents([.day, .hour], from: currentDate).hour!
        })
        
        res.append(countdownResults.filter {
            let countdownDate = $0.endDate?.dateValue() ?? Date()
            
            let dateComponents = Calendar.current.dateComponents([.day, .hour], from: countdownDate)
            
            return dateComponents.day ?? 0 == Calendar.current.dateComponents([.day], from: currentDate).day! && dateComponents.hour ?? 0 > Calendar.current.dateComponents([.day], from: currentDate).hour!
        })
        
        
        return res
        
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
    
    func fetchEvents(groupID: String) {
        COLLECTION_GROUP.document(groupID).collection("Events").order(by: "eventStartTime", descending: false).getDocuments { snapshot, err in
         
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
                let users = data["usersAttendingID"] as? [String] ?? []
                self.fetchEventUsersAttending(usersAttendingID: users, eventID: data["id"] as? String ?? " ", groupID: groupID) { fetchedUsers in
                    data["usersAttending"] = fetchedUsers
                    groupD.leave()
                }
                
                groupD.notify(queue: .main, execute: {
                    eventsToReturn.append(EventModel(dictionary: data))
                })
            }
            
            groupD.leave()
            
         
            
            groupD.notify(queue: .main, execute: {
                self.eventsResults = eventsToReturn
            })
            
        }
        
        $selectedOption
            .combineLatest($eventsResults, $countdownResults)
            .map(self.filterResults)
            .sink { [self](returnedResults) in
                eventsReturnedResults = returnedResults[0] as? [EventModel] ?? []
                countdownReturnedResults = returnedResults[1] as? [CountdownModel] ?? []
            }
            .store(in: &self.cancellables)
        
      
            
        
    }
    

    
    
    
  
    
}

