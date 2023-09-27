//
//  GroupNotificationViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import Foundation
import SwiftUI
import Firebase

class GroupNotificationViewModel : ObservableObject {
    
    func readAllNotification(userID: String, groupID: String, notifications: [GroupNotificationModel]){
        for notification in notifications {
            if !(notification.usersThatHaveSeen?.contains(where: {$0 == userID}) ?? false) {
                COLLECTION_GROUP.document(groupID).collection("Notifications").document(notification.id).updateData(["usersThatHaveSeen":FieldValue.arrayUnion([userID])])
            }
          
        }
    }
    
    func getTimeSinceNotification(date: Date) -> String{
       let interval = (Date() - date)
        
        
        var seconds = interval.second ?? 0
        var minutes = (seconds / 60)
        var hours = (minutes / 60)
        var days = (hours / 24)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
        }
        if time == "0s"{
            return "now"
        }
        else{
        return time
        }
        
    }
    
    func setRequiresAction(usersID: [String], notificationID: String){
        for id in usersID{
            COLLECTION_USER.document(id).collection("Notifications").document(notificationID).updateData(["requiresAction":false])
        }
    }
}
