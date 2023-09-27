import Foundation
import SwiftUI
import SDWebImageSwiftUI
import MapKit
import ScalingHeaderScrollView


struct ScheduleView : View {
    
    @State var calendar : Calendar
    @State var monthDayFormatter: DateFormatter = DateFormatter()
    @State var dayFormatter: DateFormatter = DateFormatter()
    @State var weekDayFormatter: DateFormatter = DateFormatter()
    @ObservedObject var calendarVM : UserCalendarViewModel
    @State var selectedDate = Self.now
    @State var showSelectedDay : Bool = false
    @State var showWeekView : Bool = false
    @State var currentDate: Date = Date()
    @EnvironmentObject var userVM: UserViewModel
    private static var now = Date()
    @State var showAddEventView: Bool = false
    @State var selectedEvent: EventModel = EventModel()
    
    func checkIfSelectedDateIsInPast(selectedDate: Date) -> Bool{
        let selectedDay = Calendar.current.dateComponents([.day], from: selectedDate).day ?? 0
        let currentDay = Calendar.current.dateComponents([.day], from: Date()).day ?? 0
        return selectedDay < currentDay && selectedDate < Date()
    }
    
    func getNumberOfEventsOfDay(events: [EventModel], date: Date) -> Int {
        var eventCount : Int = 0
        for event in events {
            if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
                eventCount = eventCount + 1
            }
        }
        
        return eventCount
    }
    
    var body: some View {
        
        
        
        
        
        
        ZStack{
            Color("Background")
            VStack{
                
                    if showWeekView{
                        UserCalendarWeekListView(calendar: calendar, calendarVM: calendarVM,
                                                 date: $selectedDate,
                                                 showSelectedDay: $showSelectedDay,
                                                 content: { date in
                            Button(action:{ selectedDate = date
                            },label:{
                                Text("00")
                                    .foregroundColor(.clear)
                                    .overlay(
                                        Text(dayFormatter.string(from: date))
                                            .foregroundColor(
                                                calendar.isDate(date, inSameDayAs: selectedDate)
                                                ? FOREGROUNDCOLOR
                                                : calendar.isDateInToday(date) ? Color("AccentColor")
                                                : .gray
                                            )
                                        
                                    )
                                
                            }).onTapGesture(count: 2) {
                                showSelectedDay.toggle()
                            }
                        }, header : { date in
                            Text("00")
                                .foregroundColor(.clear)
                                .overlay(
                                    Text(weekDayFormatter.string(from: date))
                                        .foregroundColor(FOREGROUNDCOLOR)
                                )
                        }, title: { date in
                            HStack{
                                Text(monthDayFormatter.string(from: selectedDate)).foregroundColor(FOREGROUNDCOLOR).bold()
                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                        }, weekSwitcher : { date in
                            Button(action:{
                                withAnimation{
                                    guard let newDate = calendar.date(
                                        byAdding: .weekOfMonth,
                                        value: -1,
                                        to: selectedDate
                                    ) else {
                                        return
                                    }
                                    selectedDate = newDate
                                }
                            },label:{
                                Label(
                                    title: {Text("Previous")},
                                    icon: {Image(systemName: "chevron.left")}
                                ).labelStyle(IconOnlyLabelStyle())
                            })
                            
                            Button(action:{
                                withAnimation{
                                    guard let newDate = calendar.date(
                                        byAdding: .weekOfMonth,
                                        value: 1,
                                        to: selectedDate
                                    ) else {
                                        return
                                    }
                                    selectedDate = newDate
                                }
                                
                            },label:{
                                Label(title: {Text("Next")},
                                      icon: {Image(systemName: "chevron.right")}
                                ).labelStyle(IconOnlyLabelStyle())
                            })
                        }, fullScreenButton: { date in
                            Button(action:{
                                withAnimation{
                                    showWeekView = false
                                }
                                UIDevice.vibrate()
                            }, label:{
                                ZStack{
                                    Circle().foregroundColor(Color("Background")).frame(width: 30, height: 30)
                                    Image(systemName: "pip.swap").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                                }
                            })
                        }
                                                 
                                                 
                        )
                    }else{
                        
                        CustomDatePicker(calendarVM: calendarVM, currentDate: $currentDate, selectedDate: $selectedDate, showWeekView: $showWeekView).padding(10)
                        
                    }
                ScrollView{
                    PullToRefreshView(){
                            UIDevice.vibrate()
                            calendarVM.startSearch(eventsID: userVM.user?.eventsID ?? [])
                    }
                    if calendarVM.isLoading{
                            ProgressView()
                    }else{
                        HStack{
                            
                            Text("You \(self.checkIfSelectedDateIsInPast(selectedDate: selectedDate) ? "had" : "have") \(getNumberOfEventsOfDay(events: calendarVM.eventsResults, date: selectedDate)) \(getNumberOfEventsOfDay(events:calendarVM.eventsResults, date:selectedDate) == 1 ? "event" : "events")").bold().font(.title3).foregroundColor(getNumberOfEventsOfDay(events:calendarVM.eventsResults, date:selectedDate) == 0 ? Color.white : Color.yellow)
                            
                            Spacer()
                            
                            
                            Text(selectedDate, style: .date).foregroundColor(getNumberOfEventsOfDay(events:calendarVM.eventsResults, date:selectedDate) == 0 ? Color.white : Color.yellow).lineLimit(1).font(.subheadline).padding(.leading)
                            
                            
                            
                            
                        } .padding(10).background(RoundedRectangle(cornerRadius: 12).fill(getNumberOfEventsOfDay(events: calendarVM.eventsResults, date: selectedDate) == 0 ? Color("Color") : Color("AccentColor").opacity(0.9))).padding(.horizontal)
                        if calendarVM.eventsResults.filter({Calendar.current.isDate($0.eventStartTime?.dateValue() ?? Date(), inSameDayAs: selectedDate)}).count == 0 && !calendarVM.isLoading {
                            VStack{
                                Text("You're free today, unless you wanna change that").foregroundColor(Color.gray)
                                NavigationLink {
                                    CreateEventView(eventStartTime: selectedDate, eventEndTime: selectedDate , isGroup: false, showAddEventView: $showAddEventView)
                                } label: {
                                    Text("Create Event").foregroundColor(Color("Foreground"))
                                        .padding(.vertical)
                                        .frame(width: UIScreen.main.bounds.width/2).background(Color("AccentColor")).cornerRadius(15)
                                }
                                
                                
                            }
                        }else{
                            
                            VStack(spacing: 40){
                                
                                VStack(spacing: 15){
                                    ForEach(calendarVM.eventsResults.sorted(by: {$0.eventStartTime?.dateValue() ?? Date() > $1.eventStartTime?.dateValue() ?? Date()})){ event in
                                        if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: selectedDate){
                                            Button(action:{
                                                self.selectedEvent = event
                                                self.showAddEventView.toggle()
                                            },label:{
                                                UserCalendarEventCell(event: event)
                                            })
                                            
                                            
                                            
                                        }
                                    }
                                }.padding(.top,5)
                                
                            }.padding(.bottom,UIScreen.main.bounds.height/4)
                            
                        }
                        
                        
                        
                    }
                    
                    
                }
                
                
                
                Spacer()
            }
            NavigationLink(destination: EventDetailView(eventID: selectedEvent.id, showAddEventView: $showAddEventView), isActive: $showAddEventView) {
                EmptyView()
            }
        }.frame(width: UIScreen.main.bounds.width).onChange(of: selectedDate) { newDate in
            
            UIDevice.vibrate()
            
        }.onAppear{
            self.monthDayFormatter = DateFormatter(dateFormat: "MMM, dd yyy", calendar: calendar)
            self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
            self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE",calendar: calendar)
        }
        
    }
}

struct UserCalendarWeekListView<Day: View, Header: View, Title: View, WeekSwitcher : View, FullScreenButton: View> : View {
    private var calendar: Calendar
    @Binding var showSelectedDay : Bool
    @Binding private var date: Date
    @ObservedObject var calendarVM : UserCalendarViewModel
    @EnvironmentObject var userVM : UserViewModel
    private let content : (Date) -> Day
    private let header : (Date) -> Header
    private let title: (Date) -> Title
    private let weekSwitcher : (Date) -> WeekSwitcher
    private let fullScreenButton : (Date) -> FullScreenButton
    @State var topHeaderOffset : CGFloat = 0
    
    private let daysInWeek = 7
    
    init(
        calendar: Calendar,
        calendarVM: UserCalendarViewModel,
        date: Binding<Date>,
        showSelectedDay: Binding<Bool>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title,
        @ViewBuilder weekSwitcher: @escaping (Date) -> WeekSwitcher,
        @ViewBuilder fullScreenButton: @escaping (Date) -> FullScreenButton
        
        
    ){
        self.calendar = calendar
        self._date = date
        self.content = content
        self.header = header
        self.title = title
        self.weekSwitcher = weekSwitcher
        self.fullScreenButton = fullScreenButton
        self._showSelectedDay = showSelectedDay
        self.calendarVM = calendarVM
    }
    
    func dayHasEvent(date: Date) -> Bool {
        for event in calendarVM.eventsResults {
            if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
                return true
            }
        }
        return false
    }
    
    func getNumberOfEventsOfDay(events: [EventModel], date: Date) -> Int {
        var eventCount : Int = 0
        for event in events {
            if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
                eventCount = eventCount + 1
            }
        }
        
        return eventCount
    }
    
    func checkIfSameDay(date1: Date, date2: Date) -> Bool {
        let dateComponents1 = Calendar.current.dateComponents([.day], from: date1)
        let dateComponents2 = Calendar.current.dateComponents([.day], from: date2)
        
        return dateComponents1.day ?? 0 == dateComponents2.day ?? 0
        
    }
    
    var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays(selectedDate: date)
        
        ZStack{
            
            
            
            
            VStack{
                HStack{
                    self.weekSwitcher(month)
                    self.title(month)
                    self.fullScreenButton(month)
                }.padding(5)
                
                Divider()
                HStack(spacing: 10){
                    ForEach(days.prefix(daysInWeek), id: \.self){ date in
                        
                        Button(action:{
                            
                            self.date = date
                        },label:{
                            VStack(spacing: 5){
                                
                                VStack(spacing: 1){
                                    header(date).foregroundColor(FOREGROUNDCOLOR)
                                    content(date)
                                }
                                
                                VStack(spacing: 3){
                                    ForEach(calendarVM.eventsResults){ event in
                                        if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
                                            Circle().foregroundColor(checkIfSameDay(date1: self.date, date2: date) ? Color("Color") : Color("AccentColor")).frame(width: 8, height: 8).opacity(1)
                                        }
                                    }
                                }
                                
                                
                                
                                Spacer()
                                
                                
                                
                            }.frame(width: UIScreen.main.bounds.width / 12).padding(5).background(RoundedRectangle(cornerRadius: 8).fill(calendar.isDate(date, inSameDayAs: self.date) ? Color("AccentColor") : Color("Background")))
                        })
                        
                        
                    }
                    
                }
                
                
                
            }.frame(height: UIScreen.main.bounds.height/3.5).padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
            
            
            
            
            
            
            
            NavigationLink(isActive: $showSelectedDay) {
                SelectedDayView(date: date, events: calendarVM.eventsResults)
            } label: {
                EmptyView()
            }
            
        }
        .onAppear{
            print(date)
        }
    }
}

struct EventDetailView : View {
    
    var eventID: String
    var event : EventModel {
        return eventVM.event
    }
    @Environment(\.presentationMode) var presentationMode
    @StateObject var eventVM = EventViewModel()
    @EnvironmentObject var userVM: UserViewModel
    var friendsAttending: [User] {
        (event.usersAttending ?? []).filter { user in
            return userVM.user?.friendsListID?.contains(where: {$0 == user.id ?? " "}) ?? false
        }
    }
    @State var showBackground: Bool = true
    @State var openAttendanceView: Bool = false
    @State var isUndecided: Bool = true
    @State var isAttending : Bool = true
    @State var finishedSetting: Bool = false
    @State var openEditView: Bool = false
    @Binding var showAddEventView : Bool
    @State var progress : CGFloat = 0.0
    @State var selectedOption = 0
    @State var fetched: Bool = false
    @State var imageHeight: CGFloat = 0
    let headerHeight: CGFloat = 200
    
    func isSameDay(start: Date, end: Date) -> Bool{
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year,.month,.day], from: start)
        let components2 = calendar.dateComponents([.year,.month,.day], from: end)
        return calendar.dateComponents([.day], from: components1, to: components2).day == 0
        
    }
    
    
    
    @State var region : MKCoordinateRegion = MKCoordinateRegion()
    var body: some View{
        
        ZStack{
            Color("Background")
            VStack{
                
                
                HStack{
                    Button(action:{
                        showBackground = false
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("\(event.eventName ?? " ")").foregroundColor(FOREGROUNDCOLOR).font(.title).fontWeight(.bold)
                    Spacer()
                    
                    Menu {
                        VStack{
                            if userVM.user?.id == event.creatorID ?? " "{
                                Button(action:{
                                    self.openEditView.toggle()
                                },label:{
                                    Text("Edit")
                                })
                                
                                Button(action:{
                                    eventVM.deleteEvent(eventID: event.id)
                                    presentationMode.wrappedValue.dismiss()
                                },label:{
                                    Text("Delete")
                                })
                            }else{
                                Button(action:{
                                    
                                },label:{
                                    Text("Share")
                                })
                            }
                            
                            
                            
                        }
                    } label: {
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }
                    
                }.padding(.top,50).padding(.horizontal)
                
                ScrollView{
                    LazyVStack(pinnedViews: [.sectionHeaders]){
                        Section{
                            VStack{
                                HStack{
                                    VStack(alignment: .leading){
                                        
                                        if isSameDay(start: event.eventStartTime?.dateValue() ?? Date(), end: event.eventEndTime?.dateValue() ?? Date()){
                                            VStack(alignment: .leading){
                                                Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.title2).fontWeight(.bold)
                                                HStack(spacing: 2){
                                                    Text("From:").font(.headline)
                                                    Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .time)").foregroundColor(FOREGROUNDCOLOR).font(.headline).fontWeight(.bold)
                                                }
                                                HStack(spacing: 2){
                                                    Text("To:").font(.headline)
                                                    Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .time)").foregroundColor(FOREGROUNDCOLOR).font(.headline).fontWeight(.bold)
                                                }
                                            }
                                        }else{
                                            HStack(spacing: 2){
                                                Text("From:").font(.headline)
                                                Text("\(event.eventStartTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.headline).fontWeight(.bold)
                                            }
                                            HStack(spacing: 2){
                                                Text("To:").font(.headline)
                                                Text("\(event.eventEndTime?.dateValue() ?? Date(), style: .date)").foregroundColor(FOREGROUNDCOLOR).font(.headline).fontWeight(.bold)
                                            }
                                        }
                                        
                                        
                                        
                                    }
                                    Spacer()
                                }.padding()
                                
                                Text(event.description ?? "")
                                
                                if event.location?.name != "" {
                                    VStack(spacing: 5){
                                        
                                        HStack{
                                            Image(systemName: "mappin").foregroundColor(Color.gray)
                                            Text("\(event.location?.name ?? " ")").foregroundColor(Color.gray).bold().lineLimit(1)
                                            Text("\(event.location?.address ?? " ")").foregroundColor(Color.gray).bold().lineLimit(1)
                                            
                                            
                                        }
                                        
                                        
                                        
                                        Map(coordinateRegion: $region, annotationItems: [event.location ?? EventModel.Location()]) { location in
                                            MapPin(coordinate: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
                                        }.frame(height: 150).cornerRadius(12).disabled(true)
                                        
                                        
                                    }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background"))).padding()
                                    
                                    
                                }
                                
                                VStack(alignment: .leading, spacing: 3){
                                    HStack(spacing: 3){
                                        Text("Hosted by").foregroundColor(Color.gray).bold()
                                        Text("\(event.creator?.username ?? " ")").foregroundColor(FOREGROUNDCOLOR).bold()
                                    }
                                    VStack(alignment: .leading, spacing: 0){
                                        
                                        Button(action:{
                                            self.openAttendanceView.toggle()
                                        },label:{
                                            HStack{
                                                HStack(spacing: 5){
                                                    HStack(spacing: -10){
                                                        ForEach(friendsAttending.prefix(3)){ friend in
                                                            WebImage(url: URL(string: friend.profilePicture ?? " ")).resizable().frame(width: 30, height: 30).clipShape(Circle())
                                                            
                                                            
                                                        }
                                                    }
                                                    if friendsAttending.count == 0 {
                                                        Text("No friends are attending this event").foregroundColor(Color.gray).font(.callout)
                                                    }else{
                                                        
                                                        if friendsAttending.count < 4 {
                                                            Text(" \(friendsAttending.count) \(friendsAttending.count == 1 ? "friend" : "friends") attending").foregroundColor(Color.gray).font(.callout)
                                                            
                                                        }else{
                                                            Text("+\(friendsAttending.count - 3) friends attending").foregroundColor(Color.gray).font(.callout)
                                                            
                                                        }
                                                    }
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right").foregroundColor(Color.gray)
                                            }.padding(10)
                                        })
                                        
                                        if event.membersCanInviteGuests ?? false || event.creatorID ?? " " == USER_ID{
                                            Divider()
                                            NavigationLink(destination: InviteFriendsToEventView(event: event)) {
                                                HStack{
                                                    
                                                    Image(systemName: "person.fill.badge.plus").font(.system(size: 18)).foregroundColor(FOREGROUNDCOLOR)
                                                    
                                                    Text("Invite Friends").foregroundColor(FOREGROUNDCOLOR)
                                                    
                                                    Spacer()
                                                }.padding(.vertical,10).padding(.leading,10)
                                            }
                                        }
                                      
                                        
                                    }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                                }.padding()
                                
                                if !(event.ended ?? false) {
                                    VStack(alignment: .leading){
                                        Text("RSVP").foregroundColor(Color.gray).bold()
                                        VStack(alignment: .leading){
                                            
                                            Toggle("I don't know yet", isOn: $isUndecided)
                                            
                                            
                                            if !isUndecided{
                                                Button(action:{
                                                    selectedOption = 0
                                                },label:{
                                                    HStack{
                                                        
                                                        Text("I Will Be Attending").foregroundColor(FOREGROUNDCOLOR).bold()
                                                        Spacer()
                                                        if selectedOption == 0 {
                                                            Image(systemName: "checkmark")
                                                        }
                                                    }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color.green)).foregroundColor(FOREGROUNDCOLOR).opacity(selectedOption == 1 ? 0.5 : 1)
                                                })
                                                
                                                Button(action:{
                                                    selectedOption = 1
                                                },label:{
                                                    HStack{
                                                        
                                                        Text("I Will Not Be Attending").foregroundColor(FOREGROUNDCOLOR).bold()
                                                        Spacer()
                                                        if selectedOption == 1 {
                                                            Image(systemName: "checkmark")
                                                        }
                                                        
                                                    }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color.red)).foregroundColor(FOREGROUNDCOLOR).opacity(selectedOption == 0 ? 0.5 : 1)
                                                })
                                            }
                                            
                                            HStack{
                                                Spacer()
                                                Button(action:{
                                                    if isUndecided {
                                                        eventVM.chooseUndecidedOnEvent(userID: USER_ID)
                                                    }else{
                                                        if selectedOption == 0 {
                                                            eventVM.attendEvent()
                                                        }else{
                                                            eventVM.declineEventInvitation()
                                                            presentationMode.wrappedValue.dismiss()
                                                        }
                                                    }
                                                  
                                                },label:{
                                                    Text("Save Changes")
                                                })
                                                Spacer()
                                            }
                                            
                                            
                                        }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                                    }.padding(.horizontal)
                                    
                                    if event.creatorID == USER_ID && (event.ended ?? false)  {
                                        Button(action:{
                                            eventVM.endEvent(eventID: event.id, usersAttendingID: event.usersAttendingID ?? [])
                                            presentationMode.wrappedValue.dismiss()
                                        },label:{
                                            Text("End \(event.eventName ?? " ")").foregroundColor(Color.red).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                                        })
                                    }else if !isUndecided && isAttending{
                                        Button(action:{
                                            if event.usersAttending?.count ?? 0 == 1 {
                                                eventVM.endEvent(eventID: event.id, usersAttendingID: event.usersAttendingID ?? [])
                                            }else{
                                                eventVM.leaveEvent(eventID: event.id)
                                            }
                                        },label:{
                                            Text("Leave \(event.eventName ?? " ")").foregroundColor(Color.red).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                                        })
                                        
                                    }
                                }else{
                                    Text("Event has ended")
                                }
                            }
                        } header : {
                            GeometryReader {
                                                    // detect current position of header bottom edge
                                                    Color.clear.preference(key: ViewOffsetKey.self,
                                                        value: $0.frame(in: .named("area")).maxY)
                                                }
                                                .frame(height: headerHeight)
                                                .onPreferenceChange(ViewOffsetKey.self) {
                                                    // prevent image illegal if header is not pinned
                                                    imageHeight = $0 < 0 ? 0.001 : $0
                                                }
                        }
                    } .padding(.bottom, UIScreen.main.bounds.height/4)
                }
                .coordinateSpace(name: "area")
                .overlay(
                 
                
                    WebImage(url: URL(string: event.eventImage ?? " ")).resizable().scaledToFill().frame(height: imageHeight).allowsHitTesting(false).cornerRadius(16)
                    
                    , alignment: .top).clipped()
                   
          
                
            }
            NavigationLink(destination: EventAttendanceView(event: event), isActive: $openAttendanceView) {
                EmptyView()
            }
            
            NavigationLink(destination: CreateEventView(eventName: event.eventName ?? " ", eventStartTime: event.eventStartTime?.dateValue() ?? Date(), eventEndTime: event.eventEndTime?.dateValue() ?? Date(), image: event.image ?? UIImage(), isGroup: false, event: event, showAddEventView: $showAddEventView ), isActive: $openEditView) {
                EmptyView()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            eventVM.listenToEvent(eventID: eventID)
        }.onDisappear{
            eventVM.removeListener()
        }.onReceive(eventVM.$event) { fetchedEvent in
                self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: fetchedEvent.location?.latitude ?? 0.0 , longitude: fetchedEvent.location?.longitude ?? 0.0), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                isAttending = fetchedEvent.usersAttendingID?.contains(USER_ID) ?? false
                isUndecided = fetchedEvent.usersUndecidedID?.contains(USER_ID) ?? false
            if isAttending {
                selectedOption = 0
            }else{
                selectedOption = 1
            }
        }
        
    }
}

struct UserCalendarEventCell : View{
    @State var event : EventModel
    @StateObject var calendarVM = UserCalendarViewModel()
    var body: some View {
        HStack{
            RoundedRectangle(cornerRadius: 12).frame(width: 5).foregroundColor(Color.gray)
            VStack(alignment: .leading, spacing: 5){
                Text(event.eventName ?? "").font(.title2).bold().foregroundColor(FOREGROUNDCOLOR)
                HStack(alignment: .center){
                    Text(event.eventStartTime?.dateValue() ?? Date(), style: .time).font(.headline)
                    Text("-").font(.headline)
                    Text(event.eventEndTime?.dateValue() ?? Date(), style: .time).font(.headline)
                }.foregroundColor(FOREGROUNDCOLOR)
                
                HStack{
                    Text("\(event.location?.name ?? "" == "" ? "No Location Specified" : event.location?.name ?? "")").font(.footnote)
                    
                    Text("|")
                    Text("\(event.usersAttendingID?.count ?? 0) attending").font(.footnote)
                }.foregroundColor(FOREGROUNDCOLOR.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right").foregroundColor(.gray)
        }.padding(.horizontal).onAppear{
            calendarVM.fetchEvent(eventID: event.id) { fetchedEvent in
                withAnimation{
                    if let fetchedEvent = fetchedEvent {
                        event = fetchedEvent
                    }
                }
            }
        }
    }
}

private extension UserCalendarWeekListView {
    func makeDays(selectedDate: Date) -> [Date]{
        guard let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: selectedDate),
              let lastWeek = calendar.dateInterval(of: .weekOfMonth, for: firstWeek.end - 1)
        else{
            return []
        }
        
        let dateInterval = DateInterval(start: firstWeek.start, end: lastWeek.end)
        
        return calendar.generateDays(for: dateInterval)
    }
}


private extension Calendar{
    func generateDays(for dateInterval: DateInterval,
                      matching components: DateComponents) -> [Date] {
        var dates = [dateInterval.start]
        
        enumerateDates(startingAfter: dateInterval.start,
                       matching: components,
                       matchingPolicy: .nextTime
        ){ date, _, stop in
            guard let date = date else {return}
            
            guard date < dateInterval.end else {
                stop = true
                return
            }
            
            dates.append(date)
        }
        
        return dates
    }
    
    func generateDays(for dateInterval: DateInterval) -> [Date]{
        generateDays(for: dateInterval, matching: dateComponents([.hour, .minute, .second], from: dateInterval.start))
    }
}





struct ViewOffsetKey : PreferenceKey{
    static var defaultValue = CGFloat()
     static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
         value = nextValue()
     }
}
