//
//  UserNotificationViewModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/27/22.
//

import Foundation

class UserNotificationViewModel: ObservableObject{
    
    func readAllNotification(userID: String, notifications: [UserNotificationModel]){
        for notification in notifications {
            if (notification.hasSeen ?? false) == false{
                COLLECTION_USER.document(userID).collection("Notifications").document(notification.id).updateData(["hasSeen":true])
            }
          
        }
    }
    
    func readNotification(notification: UserNotificationModel){
        if (notification.hasSeen ?? false) == false{
            COLLECTION_USER.document(USER_ID).collection("Notifications").document(notification.id).updateData(["hasSeen":true])
        }
    }
    
    func getTimeSinceNotification(date: Date) -> String{
       let interval = (Date() - date)
        
        
        var seconds = interval.second ?? 0
        var minutes = (seconds / 60)
        var hours = (minutes / 60)
        var days = (hours / 24)
        var weeks = (days / 7)
        var months = (weeks / 4)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
        }else if seconds < 2419200 {
            time = "\(weeks)w"
        }else if seconds < 29030400 {
            time = "\(months)mo"
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
