//
//  Constants.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/18/21.
//

import Foundation
import Firebase
import SwiftUI
import AudioToolbox

let userVM = UserViewModel.shared
let COLLECTION_USER = Firestore.firestore().collection("Users")
let COLLECTION_POSTS = Firestore.firestore().collection("Posts")
let COLLECTION_GROUP = Firestore.firestore().collection("Groups")
let COLLECTION_CHAT = Firestore.firestore().collection("Chats")
let COLLECTION_POLLS = Firestore.firestore().collection("Polls")
let COLLECTION_EVENTS = Firestore.firestore().collection("Events")
let COLLECTION_PERSONAL_CHAT = Firestore.firestore().collection("Personal Chats")
let COLLECTION_GALLERY_POSTS = Firestore.firestore().collection("Gallery Posts")
let COLLECTION_JUNCTION_GROUP_USER = Firestore.firestore().collection("Junction_Group_User")
let COLLECTION_GAMES = Firestore.firestore().collection("Games")
let USER_ID = userVM.userSession?.uid ?? " "
let FOREGROUNDCOLOR : Color = Color("Foreground")
let BACKGROUNDCOLOR : Color = Color("Background")


extension UIDevice {
    static func vibrate(){
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
