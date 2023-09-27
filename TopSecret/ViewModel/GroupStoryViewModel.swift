//
//  GroupStoryViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/12/22.
//

import Foundation
import Firebase


class GroupStoryViewModel : ObservableObject {
    
    
    func createStory(groupID: String, URL: String, user: User, dateCreated: Date){
        
        let id = UUID().uuidString
        
        let data = ["id":id,
                    "URL":URL,
                    "groupID":groupID,
                    "creatorID":user.id ?? "USER_ID",
                    "dateCreated":dateCreated,
                    "usersSeenStory":[]] as [String:Any]
        
        
        COLLECTION_GROUP.document(groupID).collection("Stories").document(id).setData(data) { err in
            if err != nil {
                print("ERROR \(err!.localizedDescription)")
                return
            }
        }
        
        let notificationData = ["id":UUID().uuidString,
                                "notificationName": "Story Posted",
                                "notificationTime":Timestamp(),
                                "notificationType":"storyPosted", "notificationCreator":user.id ?? "USER_ID"] as [String:Any]
        COLLECTION_GROUP.document(groupID).collection("Notifications").addDocument(data: notificationData)
        COLLECTION_GROUP.document(groupID).collection("UnreadNotifications").addDocument(data: notificationData)
        
    }
    
    func seeStory(){
        //TODO
    }
    
}
