//
//  TopSecretApp.swift
//  TopSecret
//
//  Created by Bruce Blake on 4/2/21.
//
import SwiftUI
import Firebase
import UIKit
import UserNotifications
import CoreData

@main
struct TopSecretApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared
   
    var body: some Scene {
        
        WindowGroup {
            ContentView().environmentObject(UserViewModel()).environmentObject(TabViewModel())
                .environmentObject(RegisterValidationViewModel()).environmentObject(SelectedGroupViewModel()).environmentObject(ShareViewModel()).environmentObject(LocationManager()).environmentObject(EventsTabViewModel())
        }
    }
}


