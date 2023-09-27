//
//  GroupMapViewRepresentable.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/19/23.
//

import Foundation
import SwiftUI
import MapKit
import CoreLocation
import SDWebImageSwiftUI



struct GroupMapViewRepresentable : UIViewRepresentable {
    let mapView = MKMapView()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var groupVM: SelectedGroupViewModel
    
    
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userVM.user?.latitude ?? 0.0 , longitude: userVM.user?.longitude ?? 0.0), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
        mapView.setRegion(region, animated: true)
        
        for user in groupVM.group.users {
               if let latitude = user.latitude, let longitude = user.longitude {
                   let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
               }
           }
        
        return mapView
    }
    
    
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
//            context.coordinator.configurePolyline(withDestinationCoordinate: CLLocationCoordinate2D(latitude: 38.6, longitude: -77.3))
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}

extension GroupMapViewRepresentable {
    class MapCoordinator : NSObject, MKMapViewDelegate{
        let parent: GroupMapViewRepresentable
        var userLocationCoordinate : CLLocationCoordinate2D?
        init(parent: GroupMapViewRepresentable){
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            self.userLocationCoordinate = userLocation.coordinate
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let overlay = MKPolylineRenderer(overlay: overlay)
            overlay.strokeColor = .blue
            overlay.lineWidth = 6
            return overlay
        }
        
        func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D){
//            guard let userLocationCoordinate = userLocationCoordinate else {return}
            getDestinationRoute(from: CLLocationCoordinate2D(latitude: 38.6, longitude: -77.3), to: coordinate) { route in
                self.parent.mapView.addOverlay(route.polyline)
            }
        }
        
        func getDestinationRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> Void){
            let userPlacemark = MKPlacemark(coordinate: userLocation)
            let destPlacemark = MKPlacemark(coordinate: destination)
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: userPlacemark)
            request.destination = MKMapItem(placemark: MKPlacemark(placemark: destPlacemark))
            let directions = MKDirections(request: request)
            print("place 1: \(userPlacemark.name ?? " ")")
            print("place 2: \(destPlacemark.name ?? " ")")
            directions.calculate { response, error in
                if let error = error {
                    print("ERROR: \(error.localizedDescription)")
                    return
                }
                
                guard let route = response?.routes.first else {return}
                completion(route)
            }
        }
    }
    
    
    
    
}




