//
//  PinnedMessageModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import Foundation
import SwiftUI
import Firebase


struct PinnedMessageModel : Identifiable {
    var id : String?
    var message: String?
    var name: String?
    var userProfilePicture: String?
    var timestamp: Timestamp?
    var pinnedTime: String?
    var pinnedBy: String?
}
