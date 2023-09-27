//
//  RecentSearchModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/6/22.
//

import Foundation
import Firebase


struct RecentSearchModel : Identifiable{
    var id : String
    var text: String
    var time: Timestamp
    
    init(dictionary: [String:Any]){
        self.id = dictionary["id"] as! String
        self.text = dictionary["text"] as! String
        self.time = dictionary["time"] as! Timestamp
    }
}
