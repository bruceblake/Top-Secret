//
//  CreateEventView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import SDWebImageSwiftUI
import Firebase
import CoreLocation
import MapKit


struct CreateEventView: View {
    
    @State var eventName: String = ""
    @State var eventStartTime : Date = Date()
    @State var membersCanInviteGuests : Bool = false
    @State var isAllDay : Bool = false
    @State var eventEndTime : Date = Date()
    @State var selectedFriends : [User] = []
    var selectedGroups : [GroupModel]?
    @State var openFriendsList : Bool = false
    @State var openGroupsList : Bool = false
    @State var searchLocationView : Bool = false
    @State var openImagePicker: Bool = false
    @State var image = UIImage(named: "topbarlogo")!
    var isGroup : Bool
    var event: EventModel?
    @StateObject var eventVM = EventViewModel()
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    let options = ["Open to Friends", "Invite Only", "Discover", "Group Only"]
    @State var selectedOption : Int = 1
    @State var invitationType : String = "Invite Only"
    @State var showLocationPicker: Bool = false
    @State var location = EventModel.Location()
    @EnvironmentObject var locationManager : LocationManager
    @State var openDescriptionView : Bool = false
    @State var description: String = ""
    @State var openInviteMembersView : Bool = false
    @State var openAddContactsView : Bool = false
    @State var invitedMembers : [User] = []
    @State var openExcludeMembersView : Bool = false
    @State var excludedMembers: [User] = []
    @State var isShowingPhotoPicker:Bool = false
    @State var pickedAnImage: Bool = false
    @State var createEventChat : Bool = false
    @State var createGroupFromEvent: Bool = false
    @State var nonSpecifiedEndDate: Bool = false
    @State var imageText : String = "Add Event Cover"
    @State var isKeyboardPresented = false
    @Binding var showAddEventView : Bool
    @State var selectedAnImage : Bool = false
    
//    @StateObject var contactVM = ContactsViewModel()

    
    var body: some View {
        ZStack{
            Color("Background")
            if selectedAnImage{
                Image(uiImage: image).scaledToFill().ignoresSafeArea()
            }
            VStack{
                
                HStack(alignment: .center){
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                    
                    
                    
                  

                    Spacer()
                    
                    Button(action:{
                        isShowingPhotoPicker.toggle()
                    },label:{
                        Text("\(imageText)").foregroundColor(FOREGROUNDCOLOR).padding(5).padding(.horizontal).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                    }) .fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                        ImagePicker(avatarImage: $image, allowsEditing: true)
                    })
                    Spacer()
                    
                    Button(action:{
                        
                        if event != nil{
                            eventVM.editEvent(event: event!, name: eventName, startTime: eventStartTime, endTime: eventEndTime, user: userVM.user ?? User(), image: selectedAnImage ? image : nil, invitationType: invitationType, location: location, membersCanInviteGuests: membersCanInviteGuests, invitedMembers: invitedMembers, excludedMembers: excludedMembers, description: description, createEventChat: createEventChat, createGroupFromEvent: createGroupFromEvent) { finished in
                                if finished{
                                    self.showAddEventView = false
                                }else{
                                    print("failed to edit")
                                }
                            }
                        }else{
                           
                            eventVM.createEvent(group: !isGroup ? nil : selectedGroupVM.group , eventName: eventName,eventStartTime: eventStartTime , eventEndTime: eventEndTime, user: userVM.user ?? User(), image: selectedAnImage ? image : nil, invitationType: invitationType, location: location, membersCanInviteGuests: membersCanInviteGuests, invitedMembers: invitedMembers, excludedMembers: excludedMembers, description: description, createEventChat: createEventChat, createGroupFromEvent: createGroupFromEvent) { finished in
                                if finished{
                                    self.showAddEventView = false
                                }else{
                                    print("failed to create")
                                }
                            }
                            
                           
                        }
                        
                    },label:{
                        if event != nil {
                            if eventVM.creatingEvent {
                                ProgressView().padding(.horizontal,10).padding(.vertical,5).background(RoundedRectangle(cornerRadius: 16))
                            }else{
                            Text("Edit").foregroundColor(FOREGROUNDCOLOR).padding(.horizontal,10).padding(.vertical,5).background(RoundedRectangle(cornerRadius: 16).fill(eventName == "" || eventStartTime > eventEndTime ? Color("Color") : Color("AccentColor"))).disabled(eventName == "")
                            }
                        }else{
                            if eventVM.creatingEvent {
                                ProgressView().padding(.horizontal,10).padding(.vertical,5).background(RoundedRectangle(cornerRadius: 16))
                            }else{
                                Text("Create").foregroundColor(FOREGROUNDCOLOR).padding(.horizontal,10).padding(.vertical,5).background(RoundedRectangle(cornerRadius: 16).fill(eventName == "" || eventStartTime > eventEndTime ? Color("Color") : Color("AccentColor"))).disabled(eventName == "")
                            }
                        
                        }
                      
                        
                    }).disabled(eventName == "" || eventStartTime > eventEndTime)
                }.padding(.top,50).padding(.horizontal,10)
                
                
                ScrollView{
                    
                    
                    VStack(alignment: .leading, spacing: 20){
                        //Event Name
                        
                        VStack(){
                            
                            TextField("Event Name",text: $eventName).multilineTextAlignment(.center).font(.system(size: 25, weight: .bold))
                            Rectangle().frame(width: UIScreen.main.bounds.width-50, height: 2).foregroundColor(Color.gray)
                            
                        }.padding(10)
                        HStack{
                            
                            Text("Invitation Type").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            Divider()
                            Menu {
                                VStack{
                                    ForEach(options, id: \.self){ option in
                                        Button(action:{
                                            if option == options[0]{
                                                withAnimation{
                                                    selectedOption = 0
                                                    invitationType = "Open to Friends"
                                                }
                                            }
                                           
                                            else if option == options[1]{
                                                withAnimation{
                                                    selectedOption = 1
                                                    invitationType = "Invite Only"
                                                }
                                            }
                                            
                                            else if option == options[2]{
                                                withAnimation{
                                                    selectedOption = 2
                                                    invitationType = "Discover"
                                                }
                                            }
                                            
                                            else if option == options[3]{
                                                withAnimation{
                                                    selectedOption = 3
                                                    invitationType = "Group Only"
                                                }
                                            }
                                            
                                            
                                            
                                        },label:{
                                            Text(option)
                                        })
                                    }
                                }
                            } label: {
                                HStack{
                                    Text("\(options[selectedOption])").foregroundColor(FOREGROUNDCOLOR)
                                    Image(systemName: "chevron.down").foregroundColor(Color.gray)
                                }
                            }
                            
                            
                        }.padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(.horizontal)
                        
                        
                        //place here
                        
                        VStack(alignment: .leading){
                            Text("Event Details").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            VStack{
                                HStack{
                                    Toggle(isOn: $isAllDay) {
                                        Text("All Day")
                                    }
                                }
                                Divider()
                                
                                
                                
                                HStack{
                                    Text("Start")
                                    if isAllDay{
                                        DatePicker("", selection: $eventStartTime, displayedComponents: .date)
                                    }else{
                                        DatePicker("", selection: $eventStartTime)
                                    }
                                    
                                    Spacer()
                                }
                                
                                VStack(alignment: .leading){
                                    if !nonSpecifiedEndDate{
                                        HStack{
                                            Text("End")
                                            if isAllDay{
                                                DatePicker("", selection: $eventEndTime, displayedComponents: .date)
                                            }else{
                                                DatePicker("", selection: $eventEndTime)
                                            }
                                            Spacer()
                                        }
                                        if eventStartTime > eventEndTime{
                                            Text("End Date cannot be before Start Date").foregroundColor(Color.red).font(.caption)
                                        }
                                        if eventStartTime < Date(){
                                            Text("Start Date cannot be before today").foregroundColor(Color.red).font(.caption)
                                        }
                                        if eventStartTime == eventEndTime && !isAllDay{
                                            Text("Start Date and End Date cannot be the same.. lame party").foregroundColor(Color.red).font(.caption)
                                        }
                                    }
                                  
                                    
                                    Toggle(isOn: $nonSpecifiedEndDate) {
                                        Text("Non-Specified End Date")
                                    }
                                }
                               
                                
                                
                                Divider()
                                
                                Button(action:{
                                    let dp = DispatchGroup()
                                    dp.enter()
//                                    if location.id == nil {
//                                        self.location = EventModel.Location()
//                                    }
                                 
                                    dp.leave()
                                    dp.notify(queue: .main, execute:{
                                        self.showLocationPicker = true
                                    })
                                },label:{
                                    HStack{
                                        Image(systemName: "mappin").foregroundColor(FOREGROUNDCOLOR)
                                        
                                            if location.id == nil {
                                                Text("Add Location").foregroundColor(FOREGROUNDCOLOR)
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                            }else{
                                                Text("\(location.name)").foregroundColor(location.address.isEmpty ? FOREGROUNDCOLOR : Color.blue).lineLimit(1)
                                                Spacer()
                                                Button(action:{
                                                    
                                                    location = EventModel.Location()
                                                },label:{
                                                    Image(systemName: "xmark").foregroundColor(Color.gray)
                                                })
                                            }
                                        
                                       
                                        
                                        
                                    }
                                }).sheet(isPresented: $showLocationPicker, content: {
                                    LocationPickerView(location: $location, showLocationPicker: $showLocationPicker)
                                })
                                
                                
                                
                                Divider()
                                
                                Button(action:{
                                    openDescriptionView = true
                                },label:{
                                    HStack{
                                        Image(systemName: "text.alignleft").foregroundColor(FOREGROUNDCOLOR)
                                        Text("\(description == "" ? "Description" : description)").lineLimit(2).foregroundColor(description == "" ? FOREGROUNDCOLOR : Color.gray)
                                        
                                        Spacer()
                                        Button(action:{
                                            
                                        },label:{
                                            Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                        })
                                    }
                                }).sheet(isPresented: $openDescriptionView, content: {
                                    AddEventDescriptionView(description: $description)
                                })
                                
                              
                              
                                
                                
                            }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        }.padding(.horizontal)
                        
                        VStack(alignment: .leading){
                            Text("Participants").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            VStack{
                                
                                Button {
                                   
                                    openInviteMembersView = true
                                } label: {
                                    HStack{
                                        VStack(alignment: .leading){
                                            HStack{
                                                Text("Invite Members").foregroundColor(FOREGROUNDCOLOR)
                                                Text("\(invitedMembers.count) invited").foregroundColor(Color.gray)
                                            }
                                            HStack{
                                                ForEach(invitedMembers) { member in
                                                    WebImage(url: URL(string: member.profilePicture ?? " "))
                                                        .resizable()
                                                        .scaledToFill()
                                                        .frame(width:25,height:25)
                                                        .clipShape(Circle())
                                                        .overlay(Circle().stroke(Color("AccentColor"), lineWidth: 1))
                                                }
                                            }
                                           
                                        }
                                        Spacer()
                                        Button(action:{
                                            
                                        },label:{
                                            Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                        })
                                    }.padding(.bottom,5)
                                }.sheet(isPresented: $openInviteMembersView, content: {
                                    InviteMembersToEventView(selectedUsers: $invitedMembers, openInviteFriendsView: $openInviteMembersView, openAddContactsView: $openAddContactsView, excludedMembers: excludedMembers)
                                })
//                                .sheet(isPresented: $openAddContactsView, content: {
//                                    ContactsView(contactVM: contactVM)
//                                })

                                if selectedOption == 0 {
                                    Divider()
                                    Button {
                                        
                                        openExcludeMembersView = true
                                    } label: {
                                        HStack{
                                            VStack(alignment: .leading){
                                                HStack{
                                                    Text("Exclude Members").foregroundColor(FOREGROUNDCOLOR)
                                                    Text("\(excludedMembers.count) invited").foregroundColor(Color.gray)
                                                }
                                                HStack{
                                                    ForEach(excludedMembers) { member in
                                                        WebImage(url: URL(string: member.profilePicture ?? " "))
                                                            .resizable()
                                                            .scaledToFill()
                                                            .frame(width:25,height:25)
                                                            .clipShape(Circle())
                                                            .overlay(Circle().stroke(Color("AccentColor"), lineWidth: 1))
                                                    }
                                                }
                                               
                                            }
                                            Spacer()
                                            Button(action:{
                                                
                                            },label:{
                                                Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                            })
                                        }.padding(.bottom,5)
                                        
                                        
                                    }.sheet(isPresented: $openExcludeMembersView, content: {
                                        ExcludeMembersToEventView(selectedUsers: $excludedMembers, openInviteFriendsView: $openExcludeMembersView, invitedMembers: invitedMembers)
                                    })
                                }
                            
                                Divider()
                                
                                Toggle(isOn: $membersCanInviteGuests) {
                                    Text("Members Can Invite Guests")
                                }
                                
                                Divider()
                                
                                Toggle(isOn: $createEventChat) {
                                    Text("Create a Group Chat for the Event")
                                }
                                
                                Divider()
                                
                                Toggle(isOn: $createGroupFromEvent) {
                                    Text("Create a Group from this Event")
                                }
                                
                                
                                
                                
                            }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        }.padding(.horizontal)
                        
                        
                        
                        
                        
                    }.padding(.vertical,10)
                    
                    
                    
                }
                
                
                
                
                
                
            }.resizeToScreenSize().offset(y: self.isKeyboardPresented ? 100 : 0)
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            eventStartTime = eventStartTime.addingTimeInterval(300)
            eventEndTime = eventEndTime.addingTimeInterval(3900)
            if event != nil {
                if event?.invitationType ?? EventModel.InvitationType.openToFriends == EventModel.InvitationType.openToFriends  {
                    self.selectedOption = 0
                }else{
                    self.selectedOption = 1
                }
                
                self.invitedMembers = event?.usersUndecided ?? []
                
                self.location = event?.location ?? EventModel.Location()
            }else{
                for group in selectedGroups ?? []{
                    for member in group.users{
                        if member.id != USER_ID{
                            self.invitedMembers.append(member)
                        }
                    }
                }
            }
            
           
            
        }.onChange(of: image) { newValue in
            self.imageText = "Change Event Cover"
            self.selectedAnImage = true
        } .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            self.isKeyboardPresented = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
            self.isKeyboardPresented = false
        }
    }
}



struct LocationPickerView: View {
    
    @Binding var location: EventModel.Location
    @Environment(\.presentationMode) var presentationMode
    @State private var mapRegion = MKCoordinateRegion()
    @StateObject var locationVM = LocationSearchViewModel()
    let regionSize = 500.0 //meters
    @State var annotations: [Annotation] = []
    struct Annotation : Identifiable{
        let id = UUID().uuidString
        var name : String
        var coordinate: CLLocationCoordinate2D
        var address: String
    }
    @State private var searchText = ""
    @State private var selectedPlace : MKLocalSearchCompletion = MKLocalSearchCompletion()
    @EnvironmentObject var locationManager : LocationManager
    @Binding var showLocationPicker : Bool
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(alignment: .center){
                    Button(action:{
                        locationVM.queryFragment = ""
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                  
                    
                    
                    Spacer()
                    
                        Button(action:{
                            withAnimation{
                                locationVM.showMap.toggle()
                            }
                        },label:{
                            HStack(spacing: 5){
                                Image(systemName: "magnifyingglass").foregroundColor(FOREGROUNDCOLOR)
                                Text("\(locationVM.showMap ? "Search for location" : "Searching for location...")").foregroundColor(FOREGROUNDCOLOR)
                               
                            }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("\(locationVM.showMap ? "Color" : "AccentColor")")))
                        })
                        
                        Spacer()
                    
                 
                    Circle().foregroundColor(Color.clear).frame(width: 40, height: 40)
                    
                }.padding(10)
                
                if locationVM.showMap {
                    ZStack{
                        LocationMapViewSelection(locationVM: locationVM, selectedPlace: $selectedPlace, location: location)
                        
                        
                        VStack{
                            Spacer()
                          
                            if locationVM.selectedLocationCoordinate == nil {
                                HStack{
                                    
                                    Spacer()
                                    Text("Select  place for your event").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title3)
                                    Spacer()
                              
                                   
                                }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).padding().padding(.bottom)
                            }else{
                                HStack{
                                    VStack(alignment: .leading){
                                        Text("Select this place").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.title3)
                                        Text("\(selectedPlace.title)").foregroundColor(.gray).font(.subheadline)
                                        Text("\(selectedPlace.subtitle)").foregroundColor(.gray).font(.subheadline)
                                    }
                                    Spacer()
                                    Button(action:{
                                        locationVM.queryFragment = ""
                                        self.location = EventModel.Location(name: selectedPlace.title, id: UUID().uuidString, address: selectedPlace.subtitle, latitude: locationVM.selectedLocationCoordinate?.latitude ?? 0.0, longitude: locationVM.selectedLocationCoordinate?.longitude ?? 0.0)
                                       showLocationPicker = false

                                    },label:{
                                     
                                        Image(systemName: "chevron.right").foregroundColor(FOREGROUNDCOLOR).frame(width: 50, height: 50).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                                    })
                                   
                                }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).padding().padding(.bottom)
                            }
                                
                            
                           
                        }
                        
                        
                    }
                    .edgesIgnoringSafeArea(.all).navigationBarHidden(false)
                    .onAppear{
                        if location.id == nil{
                            if let coordinate = locationManager.userLocation?.coordinate{
                                locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                locationManager.pickedLocation = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                                
                            }
                        }else{
                            locationManager.mapView.region = .init(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                        }


                    }
                }else{
                    
                    SearchBar(text: $locationVM.queryFragment, placeholder: "Enter location", onSubmit: {
                        
                    })
                    
                    List(locationVM.results, id: \.self) { place in
                        Button(action:{
                            let placeID = UUID().uuidString
//                            locationManager.pickedLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//                            locationManager.updatePlacemark(location: .init(latitude: place.coordinate.latitude , longitude: place.coordinate.longitude))

                           locationVM.selectLocation(place)
                            locationVM.showMap = true
                            selectedPlace = place
                        },label:{
                            VStack(alignment: .leading){
                                Text(place.title).foregroundColor(FOREGROUNDCOLOR).font(.title2)
                                Text(place.subtitle).foregroundColor(FOREGROUNDCOLOR).font(.callout)
                            }
                        })
                       
                    }
                }
            }
        }
    }
}
            

struct LocationMapViewSelection: View {
    @EnvironmentObject var locationManager : LocationManager
    @ObservedObject var locationVM : LocationSearchViewModel
    @Binding var selectedPlace: MKLocalSearchCompletion
    @State var location: EventModel.Location
    
    var body : some View {
        ZStack{
            LocationMapViewHelper(locationVM: locationVM)
            
        }.onReceive(locationManager.$pickedPlaceMark, perform: { newPlaceMark in
            if let newPlaceMark = newPlaceMark{
                let placeMark = MKPlacemark(placemark: newPlaceMark)
            }
         
        })
    }
}

struct LocationMapViewHelper : UIViewRepresentable {
    @ObservedObject var locationVM : LocationSearchViewModel
    let mapView = MKMapView()
    let locationManager = LocationManager()
    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let coordinate = locationVM.selectedLocationCoordinate {
            context.coordinator.addAndSelectAnnotation(withCoordinate: coordinate)
        }
    }
    
    func makeCoordinator() -> LocationMapCoordinator {
        return LocationMapCoordinator(parent: self)
    }
}

extension LocationMapViewHelper {
    
    class LocationMapCoordinator : NSObject, MKMapViewDelegate {
        
        let parent : LocationMapViewHelper
        
        init(parent: LocationMapViewHelper){
            self.parent = parent
            super.init()
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation){
            let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            parent.mapView.setRegion(region, animated: true)
        }
        
        func addAndSelectAnnotation(withCoordinate coordinate: CLLocationCoordinate2D){
            parent.mapView.removeAnnotations(parent.mapView.annotations)
            parent.mapView.showsUserLocation = false
            let anno = MKPointAnnotation()
            anno.coordinate = coordinate
            self.parent.mapView.addAnnotation(anno)
            self.parent.mapView.selectAnnotation(anno, animated: true)
            parent.mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: parent.mapView.annotations[0].coordinate.latitude, longitude: parent.mapView.annotations[0].coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
        }
        
    }
}

class LocationSearchViewModel : NSObject, ObservableObject {
 
    var queryFragment: String = "" {
        didSet{
            searchCompleter.queryFragment = queryFragment
//            if queryFragment == ""{
//                self.showMap = true
//            }else{
//                self.showMap = false
//            }
        }
    }
    @Published var showMap = true
    @Published var results = [MKLocalSearchCompletion]()
    @Published var selectedLocationCoordinate : CLLocationCoordinate2D?
    private let searchCompleter = MKLocalSearchCompleter()
 
    override init(){
        super.init()
        searchCompleter.delegate = self
        searchCompleter.queryFragment = queryFragment
    }
    
    func selectLocation(_ localSearch: MKLocalSearchCompletion) {
        locationSearch(forLocalSearchCompletion: localSearch) { response, error in
            
            if let error = error {
                print("ERROR")
                return
            }
            
            guard let item = response?.mapItems.first else {return}
            let coordinate = item.placemark.coordinate
            self.selectedLocationCoordinate = coordinate
        }
    }
    
    func locationSearch(forLocalSearchCompletion localSearch: MKLocalSearchCompletion, completion: @escaping MKLocalSearch.CompletionHandler){
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = localSearch.title.appending(localSearch.subtitle)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start(completionHandler: completion)
    }
    
}

extension LocationSearchViewModel : MKLocalSearchCompleterDelegate{
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results
    }
}
