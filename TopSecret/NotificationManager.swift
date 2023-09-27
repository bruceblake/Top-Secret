//
//  NotificationManager.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/31/22.
//

import Foundation
import UserNotifications

final class NotificationManager : ObservableObject {
    
    @Published private(set) var notifications: [UNNotificationRequest] = []
    @Published private(set) var authorizationStatus : UNAuthorizationStatus?
    
    func reloadAuthorizationStatus(){
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async{
                self.authorizationStatus = settings.authorizationStatus
            
            }
        }
    }
    
    
    func requestAuthorization(){
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.badge,.sound]) { isGranted, _ in
            DispatchQueue.main.async{
                self.authorizationStatus = isGranted ? .authorized : .denied
            }
        }

    }
    
    
    func reloadLocalNotifications(){
        print("reloadLocalNotifications")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { notifications in
            DispatchQueue.main.async{
                self.notifications = notifications
            }
        })
    }
    
    
    func createLocalNotification(title: String , hour: Int, min: Int, completion: @escaping (Error?) -> Void){
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = min
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.sound = .default
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: notificationContent, trigger: trigger)
    
        UNUserNotificationCenter.current().add(request, withCompletionHandler: completion)
    }
}
