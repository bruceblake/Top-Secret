import Foundation
import SwiftUI

struct GroupCalendarView : View {
    
    private let calendar : Calendar
    private let monthDayFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @ObservedObject var calendarVM = UserCalendarViewModel()

    @State var showMonthView: Bool = false
    @State private var selectedDate = Self.now
    @State var showSelectedDay : Bool = false
    @State var currentDate: Date = Date()
    private static var now = Date()
    
    init(calendar: Calendar){
        self.calendar = calendar
        self.monthDayFormatter = DateFormatter(dateFormat: "MMM, dd yyy", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE",calendar: calendar)
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
           
                CalendarWeekListView(calendar: calendar,
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
                                        calendar.isDate(date, inSameDayAs: Date())
                                        ? FOREGROUNDCOLOR
                                        : calendar.isDateInToday(date) ? Color.yellow
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
                        )
                }, title: { date in
                    HStack{
                        Text(monthDayFormatter.string(from: selectedDate))
                        Spacer()
                    }
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
                        self.showMonthView.toggle()
                    }, label:{
                        ZStack{
                            Circle().foregroundColor(Color("Background")).frame(width: 30, height: 30)
                            Image(systemName: "arrow.down.right.and.arrow.up.left").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).sheet(isPresented: $showMonthView) {
                        CustomDatePicker(calendarVM: calendarVM, currentDate: $currentDate, isGroup: true, group: selectedGroupVM.group, selectedDate: $selectedDate, showWeekView: $showMonthView)
                    }
                }
                
                )
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}


struct CalendarWeekListView<Day: View, Header: View, Title: View, WeekSwitcher: View, FullScreenButton: View> : View {
    
    @StateObject var calendarVM = GroupCalendarViewModel()
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @EnvironmentObject var userVM: UserViewModel
    private var calendar: Calendar
    @Binding var showSelectedDay : Bool
    @Binding private var date: Date
    private let content : (Date) -> Day
    private let header : (Date) -> Header
    private let title: (Date) -> Title
    private let weekSwitcher : (Date) -> WeekSwitcher
    private let fullScreenButton : (Date) -> FullScreenButton
    
    private let daysInWeek = 7
    
    
    func dayHasEvent(date: Date) -> Bool {
        for event in calendarVM.eventsResults {
            if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date){
                return true
            }
        }
       return false
    }
    
    init(
        calendar: Calendar,
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
    }
    
    var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays(selectedDate: date)
        
        ZStack{
            VStack{
                
                VStack{
                    HStack{
                        self.weekSwitcher(month)
                        self.title(month)
                        self.fullScreenButton(month)
                    }.padding(5)
                    
                    Divider()
                    HStack(spacing: 22){
                        ForEach(days.prefix(daysInWeek), id: \.self){ date in
                            VStack(spacing: 5){
                                
                                VStack(spacing: 1){
                                    header(date)
                                    content(date)
                                }
                               

                                if dayHasEvent(date: date){
                                    Circle().frame(width: 5, height: 5).foregroundColor(calendar.isDate(date, inSameDayAs: self.date) ? Color("Color") : Color("AccentColor")).opacity(1)
                                }else{
                                    Circle().frame(width: 5, height: 5).foregroundColor(Color("AccentColor")).opacity(0)
                                }
                               
                                
                            }.padding(5).background(RoundedRectangle(cornerRadius: 8).fill(calendar.isDate(date, inSameDayAs: self.date) ? Color("AccentColor") : Color("Background")))
                        }
                        
                    }
                  
                   
                }.padding(5).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).padding(10)
                
                ScrollView(){
                    VStack(spacing: 20){
                        ForEach(days.prefix(daysInWeek), id: \.self){ date in
                            
                            Button(action:{
                                self.showSelectedDay.toggle()
                                self.date = date
                            },label:{
                                HStack(alignment: .center){
                                        Circle().frame(width: 10, height: 10).foregroundColor(.green)
                                    
                                    HStack(spacing: 20){
                                        VStack{
                                            header(date).font(.title2).foregroundColor(FOREGROUNDCOLOR)
                                            content(date).font(.headline).foregroundColor(FOREGROUNDCOLOR)
                                        }
                                    
                                       
                                       
                                        VStack(spacing: 7){

                                            
                                            ForEach(calendarVM.eventsResults, id: \.id){ event in
                                              
                                                    if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date)
                                                      {
                                                        HStack{
                                                            VStack(alignment: .leading, spacing: 5){
                                                                Text(event.eventName ?? "").font(.title2).bold().foregroundColor(FOREGROUNDCOLOR)
                                                                HStack(alignment: .center){
                                                                    Image(systemName: "clock").font(.footnote).foregroundColor(Color.gray)
                                                                    Text(event.eventStartTime?.dateValue() ?? Date(), style: .time).font(.headline)
                                                                    Text("-").font(.headline)
                                                                    Text(event.eventEndTime?.dateValue() ?? Date(), style: .time).font(.headline)
                                                                }.foregroundColor(FOREGROUNDCOLOR)
                                                               
                                                                HStack{
                                                                    HStack(alignment: .center){
                                                                        Image(systemName: "mappin.and.ellipse").foregroundColor(Color.gray).font(.footnote)
                                                                        Text("\(event.location?.name ?? "" == "" ? "No Location Specified" : event.location?.name ?? "")").font(.footnote)
                                                                    }
                                                                    Text("|")
                                                                Text("\(event.usersAttendingID?.count ?? 0) attending").font(.footnote)
                                                                }.foregroundColor(FOREGROUNDCOLOR.opacity(0.7))
                                                            }
                                                            
                                                         
                                                        }
                                                    }
                                                
                                            
                                               
                                            }
                                        }
                                        
                                            
                                       
                                            
                                        
                                        
                                   
                                    }
                                       
                                    Spacer()
                                }
                            })
                            
                          
                         
                            
                            Divider()
                        }
                        
                    }
                }.padding(.horizontal)
          
                
            }
            
            NavigationLink(isActive: $showSelectedDay) {
                SelectedDayView(date: date, events: calendarVM.eventsResults)
            } label: {
                EmptyView()
            }

        }
        .onReceive(selectedGroupVM.$group, perform: { groupID in
            calendarVM.startSearch(group: selectedGroupVM.group, startDay: makeDays(selectedDate: date).prefix(daysInWeek)[0], endDay: makeDays(selectedDate: date).prefix(daysInWeek)[6])
        })
        .onChange(of: date) { newDate in
                                            

            calendarVM.startSearch(group: selectedGroupVM.group, startDay: makeDays(selectedDate: newDate).prefix(daysInWeek)[0], endDay: makeDays(selectedDate: newDate).prefix(daysInWeek)[6])

            
        }
     
        
    }
}


struct SelectedDayView : View {
    var date : Date
    var events: [EventModel]
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,10)
                    Text(date, style: .date)
                    Spacer()
                }.padding(.top,50)
                
                Spacer()
                VStack(spacing: 7){
                    ForEach(events, id: \.id){ event in
                      
                            if Calendar.current.isDate(event.eventStartTime?.dateValue() ?? Date(), inSameDayAs: date)
                              {
                                HStack{
                                    VStack(alignment: .leading, spacing: 5){
                                        Text(event.eventName ?? "").font(.title2).bold().foregroundColor(FOREGROUNDCOLOR)
                                        HStack(alignment: .center){
                                            Image(systemName: "clock").font(.footnote).foregroundColor(Color.gray)
                                            Text(event.eventStartTime?.dateValue() ?? Date(), style: .time).font(.headline)
                                            Text("-").font(.headline)
                                            Text(event.eventEndTime?.dateValue() ?? Date(), style: .time).font(.headline)
                                        }.foregroundColor(FOREGROUNDCOLOR)
                                       
                                        HStack{
                                            HStack(alignment: .center){
                                                Image(systemName: "mappin.and.ellipse").foregroundColor(Color.gray).font(.footnote)
                                                Text(event.location?.name ?? " ").font(.footnote)
                                            }
                                            Text("|")
                                            Text("\(event.usersAttendingID?.count ?? 0) attending").font(.footnote)
                                        }.foregroundColor(FOREGROUNDCOLOR.opacity(0.7))
                                    }
                                    
                                 
                                }
                            }
                        
                        
                    
                       
                    }
                }
                
                    
                Spacer()
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}


private extension CalendarWeekListView {
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

 extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(from: calendar.dateComponents([.year,.month], from: self)
        ) ?? self
    }
    
}


 extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar){
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
        self.locale = Locale(identifier: "en_US")
    }
}
