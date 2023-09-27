//
//  LocationManager.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/19/22.
//

import Foundation
import CoreLocation
import Firebase
import SwiftUI
import MapKit

final class LocationManager : NSObject, ObservableObject, CLLocationManagerDelegate, MKMapViewDelegate {
    @Published var userLocation : CLLocation?
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 20, longitude: 37), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
    @Published var city = ""
    @Published var state = ""
    @Published var mapView : MKMapView = .init()
    @Published var pickedLocation : CLLocation?
    @Published var pickedPlaceMark: CLPlacemark?
    @Published var userLocationName : String = ""
    private let locationManager = CLLocationManager()
    let userVM = UserViewModel.shared
    
    override init() {
        super.init()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.stopUpdatingLocation()
        locationManager.delegate = self
        locationManager.requestLocation()
        mapView.delegate = self
        
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKPointAnnotation {
            let identifier = "User"
            var view: CustomAnnotationView
            
            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView {
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                view = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.isDraggable = true
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
            }
            
            return view
        } else {
            return nil
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        guard let newLocation = view.annotation?.coordinate else {return}
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlacemark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
    }
    
    func updatePlacemark(location: CLLocation){
        Task{
            do{
                guard let place = try await reverseLocationCoordinates(location: location) else {return}
                await MainActor.run(body: {
                    self.pickedPlaceMark = place
                })
            }
            catch{
                
            }
        }
        
    }
    
    func reverseLocationCoordinates(location: CLLocation)async throws->CLPlacemark?{
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        guard let location = locations.last else { return }
        DispatchQueue.main.async {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let error = error {
                    print(error)
                    return
                }
                
                
                if let placemark = placemarks?.first {
                    self.city = placemark.locality ?? "City"
                    self.state = placemark.administrativeArea ?? "State"
                    self.userLocationName = placemark.name ?? ""
                    COLLECTION_USER.document(self.userVM.user?.id ?? " ").updateData(["lastLocationName":placemark.name ?? ""])
                }
            }
            self.userLocation = location
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), latitudinalMeters: 0.03, longitudinalMeters: 0.03)
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            
            
            COLLECTION_USER.document(self.userVM.user?.id ?? " ").updateData(["latitude":latitude, "longitude":longitude])
            
            
            
            
        }
        
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
        print("ERROR: \(error.localizedDescription)")
        return
    }
    
    func configurePolyline(withDestinationCoordinate coordinate: CLLocationCoordinate2D){
        guard let userLocationCoordinate = self.userLocation?.coordinate else {return}
        getDestinationRoute(from: userLocationCoordinate, to: coordinate) { route in
            self.mapView.addOverlay(route.polyline)
        }
    }
    
    func getDestinationRoute(from userLocation: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion: @escaping(MKRoute) -> Void){
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let destPlacemark = MKPlacemark(coordinate: destination)
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: MKPlacemark(placemark: destPlacemark))
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error {
                print("ERROR")
                return
            }
            
            guard let route = response?.routes.first else {return}
            completion(route)
        }
    }
}

    

class CustomAnnotationView: MKAnnotationView {
    
    override var annotation: MKAnnotation? {
        didSet {
            if let annotation = annotation as? MKPointAnnotation {
                // Set the image and center offset for the annotation view
                // Assume "originalImage" is the original image you want to resize
                var originalImage = UIImage(named: "MapPin")
                originalImage = originalImage?.withTintColor(UIColor(Color("AccentColor")))
                
                let newSize = CGSize(width: 60, height: 60) // Define the size you want
                UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
                originalImage?.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
                let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.image = resizedImage
                
                
                
                self.centerOffset = CGPoint(x: 0, y: -self.image!.size.height / 2)
            }
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            // Create a custom callout view
            let calloutView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
            calloutView.backgroundColor = UIColor.white
            
            let calloutLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 180, height: 80))
            calloutLabel.numberOfLines = 1
            calloutLabel.text = "Custom Callout View"
            calloutView.addSubview(calloutLabel)
            
            // Set the callout view for the annotation view
            self.detailCalloutAccessoryView = calloutView
        } else {
            self.detailCalloutAccessoryView = nil
        }
    }
}
