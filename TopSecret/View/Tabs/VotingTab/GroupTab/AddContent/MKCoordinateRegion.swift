//
//  MKCoordinateRegion.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/19/22.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit

extension MKCoordinateRegion {
    
    static func goldenGateRegion() -> MKCoordinateRegion {
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.819527098978355, longitude:  -122.47854602016669), latitudinalMeters: 5000, longitudinalMeters: 5000)
    }
    
    func getBinding() -> Binding<MKCoordinateRegion>? {
        return Binding<MKCoordinateRegion>(.constant(self))
    }
}
