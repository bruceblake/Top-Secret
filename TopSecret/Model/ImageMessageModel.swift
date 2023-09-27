//
//  ImageMessageModel.swift
//  TopSecret
//
//  Created by nathan frenzel on 1/5/22.
//

import Foundation
import Swift
import Firebase



struct ImageMessageModel:Identifiable {
    var id : String?
    var name: String?
    var userProfilePicture: String?
    var timestamp: Timestamp?
    var image: String?
    //var privacy: Bool?
    //var inGallery: Bool?
}
