//
//  BadgeModel.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/22/22.
//

import Foundation


struct Badge : Identifiable {
    var id : String?
    var badgeName: String?
    var badgeDescription: String?
    var badgeImage : String?
    
    
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as? String ?? ""
        self.badgeName = dictionary["badgeName"] as? String ?? ""
        self.badgeDescription = dictionary["badgeDescription"] as? String ?? ""
        self.badgeImage = dictionary["badgeImage"] as? String ?? ""
    }
    
    
}
