//
//  PlaceModel.swift
//  Top Secret
//
//  Created by Bruce Blake on 10/11/22.
//

import Foundation
import SwiftUI


struct PlaceModel : Codable, Identifiable {
    let id : String
    let longitude : Double
    let latitude : Double
    let address : String
    
    
    init(dictionary: [String:Any]){
        self.id = UUID().uuidString
        self.longitude = dictionary["longitude"] as! Double
        self.latitude = dictionary["latitude"] as! Double
        self.address = dictionary["address"] as! String
    }
}
