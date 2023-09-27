//
//  MapView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI
import Firebase

struct GroupMapView: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    @StateObject var locationManager = GroupMapLocationManager()
    @State var followUser : Bool = false
    @State var selectedUser : User = User()
    @State var isOn: Bool = false
    @State var finishedSetting : Bool = false
    
    var body: some View {
        
        
        ZStack(alignment: .bottomTrailing){
            
            
            Map(coordinateRegion: $locationManager.region, interactionModes: .all, showsUserLocation: false, annotationItems: locationManager.userLocations.uniqued()) { anno in
                MapAnnotation(coordinate: anno.coordinate) {
                    Button(action:{
                        self.selectedUser = anno.user
                        self.followUser.toggle()
                    },label:{
                        WebImage(url: URL(string: anno.user.profilePicture ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                    })


                }

            }
          
      
                
                    VStack(spacing: 20){
                        VStack{
                            HStack(alignment: .top){
                                        
                                        Toggle(isOn: $isOn) {
                                            VStack(alignment: .leading){
                                                Text("Location Sharing").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14)).bold()
                                                if userVM.user?.isLocationSharing ?? false {
                                                    Text("\(userVM.user?.lastLocationName ?? "")").lineLimit(1).foregroundColor(Color.gray).font(.system(size: 12))
                                                }else{
                                                    Text("Not Sharing Location").lineLimit(1).foregroundColor(Color.red).font(.system(size: 12))
                                                }
                                                
                                        
                                                Text("sharing location since \(userVM.user?.lastLocationTime.dateValue() ?? Date(), style: .time)").lineLimit(1).foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                                            }
                                            }
                                        
                                       
                                 
                                
                                Spacer()
                            }
                        }
                        ScrollView{
                            if locationManager.isLoading {
                                ProgressView()
                            }else{
                                ForEach(locationManager.userLocations.uniqued()){ userAnnotation in
                                    VStack{
                                        Divider()
                                    Button(action:{
                                        self.selectedUser = userAnnotation.user
                                        self.followUser.toggle()
                                    },label:{
                                        HStack(spacing: 4){
                                            WebImage(url: URL(string: userAnnotation.user.profilePicture ?? " "))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width:40,height:40)
                                                .clipShape(Circle())

                                            VStack(alignment: .leading, spacing: 1){
                                                Text("\(userAnnotation.user.id ?? "" == userVM.user?.id ?? "" ? "Me" : "\(userAnnotation.user.nickName ?? "")")").foregroundColor(FOREGROUNDCOLOR).font(.caption).bold()
                                                if userAnnotation.user.isLocationSharing {
                                                    Text("\(userAnnotation.user.lastLocationName)").foregroundColor(FOREGROUNDCOLOR).font(.caption)
                                                }else {
                                                    Text("\(userAnnotation.user.nickName ?? " ") is not sharing their location").foregroundColor(Color.red).font(.caption)
                                                }
                                                Text("Since \(userAnnotation.user.lastLocationTime.dateValue(), style: .time)").foregroundColor(FOREGROUNDCOLOR).font(.caption)
                                            }

                                            Spacer()
                                        }
                                    })
                                    }





                                }
                            }
                        }
                      
                        
                    }
                    
                    
                .padding().background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/3)
                
            

            NavigationLink(destination: SelectedUserMapView(followUser: $followUser, userAnnotations: $locationManager.userLocations, selectedUser: $selectedUser), isActive: $followUser) {
                EmptyView()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            locationManager.listenToAllLocations(users: groupVM.group.usersID)
            self.isOn = userVM.user?.isLocationSharing ?? false
            finishedSetting = true
        }.onChange(of: isOn, perform: { newValue in
            if finishedSetting{

                COLLECTION_USER.document(USER_ID).updateData(["isLocationSharing":newValue])
            }
           
        })
        
        
    }

}


struct UserAnnotations : Identifiable, Hashable{
    static func == (lhs: UserAnnotations, rhs: UserAnnotations) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
    }
    
    var id = UUID().uuidString
    var user: User
    var coordinate : CLLocationCoordinate2D
    
    
}



class GroupMapLocationManager : NSObject, ObservableObject, CLLocationManagerDelegate, MKMapViewDelegate {
    private let locationManager = CLLocationManager()
    @Published var userLocationName : String = ""
    @Published var userLocation : CLLocation?
    @Published var region =  MKCoordinateRegion()
    @Published var userLocations : [UserAnnotations] = []
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    @Published var isLoading: Bool = false
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()
        locationManager.stopUpdatingLocation()
        locationManager.requestLocation()
    }
    
   
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        // Handle failure to get a user’s location
        print("ERROR: \(error.localizedDescription)")
        return
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
                    self.userLocationName = placemark.name ?? ""
                    COLLECTION_USER.document(USER_ID).updateData(["lastLocationName":placemark.name ?? ""])
                    COLLECTION_USER.document(USER_ID).updateData(["lastLocationTime":Date()])
                }
            }
            self.userLocation = location
            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            COLLECTION_USER.document(USER_ID).updateData(["latitude":latitude, "longitude":longitude])
        }
        
    }
    
    func listenToAllLocations(users: [String]) {
        let dp = DispatchGroup()
        dp.enter()
        self.isLoading = true
        self.userLocations = []
        for user in users {
            dp.enter()
            COLLECTION_USER.document(user).addSnapshotListener { snapshot, error in
                if let error = error {
                    print("Error fetching user location for user: \(user). Error: \(error.localizedDescription)")
                    return
                }
                
                guard let data = snapshot?.data() else {
                    print("User location data for user: \(user) is nil")
                    return
                }
                
                guard let latitude = data["latitude"] as? Double, let longitude = data["longitude"] as? Double else {
                    print("User location data for user: \(user) is missing latitude or longitude")
                    return
                }
                
                // Create a UserAnnotations object with the user's location data
                let userLocation = UserAnnotations(user: User(dictionary: data), coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                // Add the user's location to the array of user locations
                self.userLocations.append(userLocation)
            }
            dp.leave()

        }
        dp.leave()
        dp.notify(queue: .main, execute:{
            self.isLoading = false
        })
           
        
        
    }
}


