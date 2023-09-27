//
//  EventModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase
import CoreLocation


struct EventModel : Identifiable, Hashable{
    
    static func == (lhs: EventModel, rhs: EventModel) -> Bool {
        return lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    var id: String = UUID().uuidString
    var eventName : String?
    var eventLocation : String?
    var eventStartTime : Timestamp?
    var eventEndTime : Timestamp?
    var usersInvitedID: [String]?
    var usersInvited : [User]?
    var usersExcludedID: [String]?
    var usersExcluded: [User]?
    var usersAttendingID : [String]?
    var usersAttending : [User]?
    var usersDeclinedID: [String]?
    var usersDeclined: [User]?
    var usersUndecidedID: [String]?
    var usersUndecided: [User]?
    var creatorID: String?
    var creator : User?
    var groupID: String?
    var group: GroupModel?
    var timeStamp: Timestamp?
    var image: UIImage?
    var eventImage: String?
    var urlPath: String?
    var likedListID: [String]?
    var likedList: [User]?
    var dislikedListID: [String]?
    var dislikedList: [User]?
    var description: String?
    var membersCanInviteGuests: Bool?

    var invitationType: InvitationType?
    var location: Location?
    var ended: Bool?
    
    struct Location : Identifiable {
        var id : String?
        let name: String
        let address: String
        let latitude: Double
        let longitude: Double
        var coordinate : CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        func toDictionary() -> [String: Any] {
            return [
                "name": self.name,
                "id":self.id,
                "address":self.address,
                "latitude": self.latitude,
                "longitude": self.longitude
            ]
        }
        
        init(name: String, id: String?, address: String = "", latitude: Double, longitude: Double){
            self.id = UUID().uuidString
            self.name = name
            self.latitude = latitude
            self.address = address
            self.longitude = longitude
        }
        
        init(){
            self.id = nil
            self.name = ""
            self.latitude = 0.0
            self.address = ""
            self.longitude = 0.0
        }
    }

    
enum InvitationType {
    case openToFriends, inviteOnly
}
     
  
    init(){
        self.id = UUID().uuidString
        self.eventName = "Game Changer Pitch Competition"
        self.eventLocation = "Lyric Theater"
        self.eventStartTime = Timestamp(date: Date())
    }
    
    init(dictionary: [String:Any]) {
        self.id = dictionary["id"] as? String ?? "EVENT_ID"
        self.eventName = dictionary["eventName"] as? String ?? "EVENT_NAME"
        self.eventLocation = dictionary["eventLocation"] as? String ?? "EVENT_LOCATION"
        self.eventStartTime = dictionary["eventStartTime"] as? Timestamp ?? Timestamp()
        self.eventEndTime = dictionary["eventEndTime"] as? Timestamp ?? Timestamp()
        self.usersInvitedID = dictionary["usersInvitedID"] as? [String] ?? []
        self.usersInvited = dictionary["usersInvited"] as? [User] ?? []
        self.usersExcludedID = dictionary["usersExcludedID"] as? [String] ?? []
        self.usersExcluded = dictionary["usersExcluded"] as? [User] ?? []
        self.usersAttendingID = dictionary["usersAttendingID"] as? [String] ?? []
        self.usersAttending = dictionary["usersAttending"] as? [User] ?? []
        self.usersDeclinedID = dictionary["usersDeclinedID"] as? [String] ?? []
        self.usersDeclined = dictionary["usersDeclined"] as? [User] ?? []
        self.usersUndecidedID = dictionary["usersUndecidedID"] as? [String] ?? []
        self.usersUndecided = dictionary["usersUndecided"] as? [User] ?? []
        self.creatorID = dictionary["creatorID"] as? String ?? " "
        self.creator = dictionary["creator"] as? User ?? User()
        self.groupID = dictionary["groupID"] as? String ?? ""
        self.group = dictionary["group"] as? GroupModel ?? GroupModel()
        self.timeStamp = dictionary["timeStamp"] as? Timestamp ?? Timestamp()
        self.image = dictionary["image"] as? UIImage ?? UIImage()
        self.urlPath = dictionary["urlPath"] as? String ?? ""
        self.likedListID = dictionary["likedListID"] as? [String] ?? []
        self.likedList = dictionary["likedList"] as? [User] ?? []
        self.dislikedListID = dictionary["dislikedListID"] as? [String] ?? []
        self.dislikedList = dictionary["dislikedList"] as? [User] ?? []
        self.description = dictionary["description"] as? String ?? ""
        self.membersCanInviteGuests = dictionary["membersCanInviteGuests"] as? Bool ?? false
        self.eventImage = dictionary["eventImage"] as? String ?? ""
        self.ended = dictionary["ended"] as? Bool ?? false

        
        if let invitationTypeString = dictionary["invitationType"] as? String, let invitationType = InvitationType.fromFirestoreValue(invitationTypeString) {
            self.invitationType = invitationType
        }

        if let locationData = dictionary["location"] as? [String: Any] {
            self.location = Location(
                name: locationData["name"] as? String ?? "",
                id: locationData["id"] as? String ?? "", address: locationData["address"] as? String ?? "",
                latitude: locationData["latitude"] as? Double ?? 0.0,
                longitude: locationData["longitude"] as? Double ?? 0.0
            )
        }
    }
    
   
    
    
}



extension EventModel.InvitationType {
    static func fromFirestoreValue(_ value: Any?) -> EventModel.InvitationType? {
           guard let value = value as? String else {
               return nil
           }
           switch value {
           case "openToFriends":
               return .openToFriends
           case "inviteOnly":
               return .inviteOnly
           default:
               return nil
           }
       }
}

extension EventModel {
    func isWithinRadius(radius: Double, currentLocation: CLLocation) -> Bool {
        guard let location = self.location else {
            return false
        }
        let eventLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let distance = currentLocation.distance(from: eventLocation) / 1609.34 // Convert to kilometers
        return distance <= radius
    }
}
