import SwiftUI
import Foundation
import Combine
import CoreLocation
import SDWebImageSwiftUI


struct DiscoverView : View{
    @State var selectedEvent: EventModel = EventModel()
    @State var selectedOption : Int = 0
    @State var selectedRadiusOption : Int = 0
    @State var radius: Int = 100
    @State var type : String = "restaurant"
    @StateObject var locationManager = LocationManager()
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var eventVM = EventsTabViewModel()
    @State var searchText : String = ""
    @State var showAddEventView: Bool = false
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    func getRadiusInMiles(radius: Int) -> Double{
        round(Double(radius / 1609))
    }
    
    let columns : [GridItem] = [
        GridItem(.flexible(), spacing: 5),
        GridItem(.flexible(), spacing: 5)
    ]
    var body: some View {
        ZStack{
            VStack{
             
    
                //Events
                    ScrollView(showsIndicators: false){
                        VStack(spacing: 20){
                            
                          
                            
                            VStack(alignment: .leading){
                                Text("Attending").font(.title2).bold().padding(.leading,5)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        if eventVM.isLoadingAttendingEvents {
                                            ProgressView()
                                        }else{
                                            
                                            if eventVM.attendingEvents.isEmpty{
                                                Text("Currently there are no events, come back later?").padding(.leading,5).foregroundColor(Color.gray)
                                            }else{
                                                ForEach(eventVM.attendingEvents.uniqued(), id: \.id) { event in
                                                    Button(action:{
                                                        self.selectedEvent = event
                                                        self.showAddEventView.toggle()
                                                    },label:{
                                                        EventTabEventCell(event: event, eventsVM: eventVM, userIsAttending: event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false)
                                                    })
                                                 
                                                   
                                                }
                                            }
                                           
                                        }
                                       
                                    }
                                    
                                }
                            }
                            
                            VStack(alignment: .leading){
                                Text("Invited To").font(.title2).bold().padding(.leading,5)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        if eventVM.isLoadingInviteOnlyEvents {
                                            ProgressView()
                                        }else{
                                            
                                            if eventVM.inviteOnlyEvents.isEmpty{
                                                Text("Currently there are no events, come back later?").padding(.leading,5).foregroundColor(Color.gray)
                                            }else{
                                                ForEach(eventVM.inviteOnlyEvents.uniqued(), id: \.id) { event in
                                                    
                                                    Button(action:{
                                                        self.selectedEvent = event
                                                        self.showAddEventView.toggle()
                                                    },label:{
                                                        EventTabEventCell(event: event, eventsVM: eventVM, userIsAttending: event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false)
                                                    })
                                                 
                                                   
                                                }
                                            }
                                           
                                        }
                                       
                                    }
                                    
                                }
                            }
                            
                            VStack(alignment: .leading){
                                Text("Open To Friends").font(.title2).bold().padding(.leading,5)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        if eventVM.isLoadingOpenToFriends {
                                            ProgressView()
                                        }else{
                                            if eventVM.openToFriendsEvents.isEmpty{
                                                Text("Currently there are no events, come back later?").padding(.leading,5).foregroundColor(Color.gray)
                                            }else{
                                                ForEach(eventVM.openToFriendsEvents.uniqued(), id: \.id) { event in
                                                    Button(action:{
                                                        self.selectedEvent = event
                                                        self.showAddEventView.toggle()
                                                    },label:{
                                                        EventTabEventCell(event: event, eventsVM: eventVM, userIsAttending: event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false)
                                                    })
                                                 
                                                   
                                                }
                                            }
                                           
                                        }
                                       
                                    }
                                    
                                }
                            }
                            
                            VStack(alignment: .leading){
                                Text("Past Events").font(.title2).bold().padding(.leading,5)
                                ScrollView(.horizontal, showsIndicators: false){
                                    HStack(spacing: 20){
                                        if eventVM.isLoadingPastEvents {
                                            ProgressView()
                                        }else{
                                            if eventVM.pastEvents.isEmpty{
                                                Text("Currently there are no events, come back later?").padding(.leading,5).foregroundColor(Color.gray)
                                            }else{
                                                ForEach(eventVM.pastEvents.uniqued(), id: \.id) { event in
                                                    Button(action:{
                                                        self.selectedEvent = event
                                                        self.showAddEventView.toggle()
                                                    },label:{
                                                        EventTabEventCell(event: event, eventsVM: eventVM, userIsAttending: event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false)
                                                    })
                                                 
                                                   
                                                }
                                            }
                                           
                                        }
                                       
                                    }
                                    
                                }
                            }
                            
                            
                        }.padding(.bottom, UIScreen.main.bounds.width/3)
                      
                       
                    }.padding(10)
            
                    
                    
                
                
                
                
                Spacer()
                
            }.onTapGesture {
                eventVM.showRSVPScreen = false
            }
            if eventVM.showRSVPScreen {
                VStack{
                    Spacer()
                    VStack{
                       Text("Send Event Flyer")
                        ForEach(userVM.groups){ group in
                            GroupSearchCell(group: group)
                        }
                    }.padding().background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                    Spacer()
                }
            }
           
            NavigationLink(destination: EventDetailView(eventID: selectedEvent.id, showAddEventView: $showAddEventView), isActive: $showAddEventView) {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all).frame(width: UIScreen.main.bounds.width).onAppear{
            eventVM.fetchAttendingEvents(user: userVM.user ?? User())
            eventVM.fetchDiscoverEvents(user: userVM.user ?? User())
            eventVM.fetchOpenToFriendsEvents(user: userVM.user ?? User())
            eventVM.fetchInvitedToEvents(user: userVM.user ?? User())
            eventVM.fetchPastEvents(user: userVM.user ?? User())
        }.onDisappear{
            eventVM.removeListeners()
        }
    }
}



struct EventTabEventCell : View {
    @State var event: EventModel
    @State var friendsAttending: [User] = []
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var eventsVM : EventsTabViewModel
    @State var userIsAttending: Bool
    @State var usersAttendingID: [String] = []
    
    var eventLocationName : String {
        event.location?.name ?? ""
    }
    
    func getTimeSince(date: Date) -> String{
        let interval = (Date() - date)
        
        
        var seconds = interval.second ?? 0
        var minutes = (seconds / 60)
        var hours = (minutes / 60)
        var days = (hours / 24)
        var time = ""
        if seconds < 60{
            if seconds == 1 {
                time = "\(seconds) second ago"
            }else{
                time = "\(seconds) seconds ago"
            }
        }else if seconds < 3600  {
            if minutes == 1 {
                time = "\(minutes) minute ago"
            }else{
                time = "\(minutes) minutes ago"
            }
        }else if seconds < 86400 {
            if hours == 1 {
                time = "\(hours) hour ago"
            }else{
                time = "\(hours) hours ago"
            }
        }else if seconds < 604800 {
            if days == 1 {
                time = "\(days) day ago"
            }else{
                time = "\(days) days ago"
            }
        }
        if time == "0 seconds ago"{
            return "now"
        }else{
            return time
        }
        
    }
    
    func getDaysUntil(date: Date) -> Int{
        let calendar = Calendar.current
        let date1 = calendar.startOfDay(for: Date())
        let date2 = calendar.startOfDay(for: date.addingTimeInterval(86400))
        let components = calendar.dateComponents([.day], from: date1, to: date2)
        
        if let days = components.day {
            return days
        } else {
            return -1
        }
    }
    
    func getHoursUntil(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: Date(), to: date)
        
        if let hours = components.hour {
            return hours
        } else {
            return -1
        }
    }
    
    func getMinutesUntil(date: Date) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.minute], from: Date(), to: date)
        
        if let minutes = components.minute {
            return minutes
        } else {
            return -1
        }
    }
    
    var minutesUntil : Int {
        getMinutesUntil(date: event.eventStartTime?.dateValue() ?? Date())
    }
    
    var hoursUntil : Int {
        getHoursUntil(date: event.eventStartTime?.dateValue() ?? Date())
    }
    
    var daysUntil : Int {
        getDaysUntil(date: event.eventStartTime?.dateValue() ?? Date())
    }
    var body: some View {
        
    
        VStack(spacing: 0){
            if event.eventImage != "" {
                
                WebImage(url: URL(string: event.eventImage ?? " ")).resizable().frame(height: 225).scaledToFit()
                
            }else{
                Spacer()
                Text("No Image Provied").foregroundColor(Color.gray)
                Spacer()
            }

                HStack(alignment: .top){
                    VStack(alignment: .leading,spacing:5){
                        
                        HStack(){
                            Text(event.eventName ?? " ").lineLimit(1).font(.headline).foregroundColor(FOREGROUNDCOLOR)
                            Circle().frame(width: 5, height: 5).foregroundColor(Color.gray)
                            if let eventStartTime = event.eventStartTime?.dateValue() {
                                let minutesUntil = getMinutesUntil(date: eventStartTime)
                                
                                if minutesUntil >= 1440 {
                                    // 24 hours or more away from event
                                    let daysUntil = minutesUntil / 1440
                                    Text("\(daysUntil == 1 ? "1 day away" : "\(daysUntil) days away")").font(.footnote).foregroundColor(Color.gray).lineLimit(1)
                                } else if minutesUntil >= 60 {
                                    // at least 1 hour away from event
                                    let hoursUntil = minutesUntil / 60
                                    Text("\(hoursUntil == 1 ? "1 hour away" : "\(hoursUntil) hours away")").font(.footnote).foregroundColor(Color.gray).lineLimit(1)
                                } else {
                                    // less than 60 minutes away from event
                                    Text("\(minutesUntil == 0 || minutesUntil == 1 ? "1 minute away" : "\(minutesUntil) minutes away")").font(.footnote).foregroundColor(Color.gray).lineLimit(1)
                                }
                            }
                            Spacer()
                        }
                        if event.ended ?? false {
                            Text("Event ended \(getTimeSince(date: event.eventEndTime?.dateValue() ?? Date()))").foregroundColor(Color.red)
                        }else{
                            if event.eventStartTime?.dateValue() ?? Date() <= Date(){
                                Text("Event started \(getTimeSince(date: event.eventStartTime?.dateValue() ?? Date()))").foregroundColor(Color.green)
                            }else{
                                VStack(alignment: .leading){
                                    Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                    HStack{
                                        Text(event.eventStartTime?.dateValue() ?? Date(), style: .time).foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                        Text("-")
                                        Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .time)").foregroundColor(FOREGROUNDCOLOR).font(.subheadline)
                                    }.foregroundColor(FOREGROUNDCOLOR)
                                    
                                  
                                }
                            }
                        }
                       
                       
                        
                        Text("\(eventLocationName == "" ? "No Location Specified" : eventLocationName)").foregroundColor(Color.gray).font(.callout)

                       
                        if friendsAttending.count != 0 {
                            HStack{
                                HStack(spacing: -10){
                                    ForEach(friendsAttending.prefix(3)){ friend in
                                            WebImage(url: URL(string: friend.profilePicture ?? " ")).resizable().frame(width: 30, height: 30).clipShape(Circle())
                                        
                                       
                                    }
                                }
                                
                                if friendsAttending.count < 4 {
                                    Text("\(friendsAttending.count) friends attending").foregroundColor(Color.gray).font(.callout)

                                }else{
                                    Text("+\(friendsAttending.count - 3) friends attending").foregroundColor(Color.gray).font(.callout)

                                }
                               
                            }
                        }
                        
                        Button(action:{
                            eventsVM.showRSVPScreen = true
                        },label:{
                            Text("RSVP").foregroundColor(FOREGROUNDCOLOR).padding(.horizontal,10).padding(.vertical,5).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                        }).padding(5)
                        
                    }.padding(10)
                }.background(Rectangle().foregroundColor(Color("Color")))
            
           
            
            
        }.frame(width: (UIScreen.main.bounds.width/1.5)).clipShape(RoundedRectangle(cornerRadius: 16)).onAppear{
           
            friendsAttending = eventsVM.getFriendsAttending(event: event, user: userVM.user ?? User())
            if event.eventEndTime?.dateValue() ?? Date() < Date() && !(event.ended ?? false){
                eventsVM.endEvent(eventID: event.id, usersAttendingID: event.usersAttendingID ?? [])
            }
        }
    }
}



extension CLLocation {
    func distance(from location: EventModel.Location) -> CLLocationDistance {
        let eventLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        return distance(from: eventLocation)
    }
}

