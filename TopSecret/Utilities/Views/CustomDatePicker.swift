//
//  CustomDatePicker.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI

struct CustomDatePicker: View {
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @ObservedObject var calendarVM: UserCalendarViewModel
    @Binding var currentDate: Date
    var isGroup : Bool = false
    var group: GroupModel = GroupModel()
    @State var currentMonth: Int = 0
    
    @State var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State var selectedDay: Int = Calendar.current.component(.day, from: Date())
    @State var selectedYear : Int = Calendar.current.component(.year, from: Date())
    @Binding var selectedDate: Date
    @Binding var showWeekView: Bool
    
    func convertComponentsToDate(year: Int, month: Int, day: Int) -> Date{
        let calendar = Calendar(identifier: .gregorian)
        let dateComponents = DateComponents(year: year, month: month, day: day)
        return calendar.date(from: dateComponents) ?? Date()
    }
    
    let days: [String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var body: some View {
        VStack(){
            
            VStack(spacing: 15){
            HStack(spacing: 20){
                
                HStack{

                    Text(extraDate()[1])
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                
            
                
                    Spacer(minLength: 0)
                    
                HStack{
                    Button(action:{
                        withAnimation{
                            currentMonth -= 1
                        
                        }
                    },label:{
                        Image(systemName: "chevron.left")
                            .font(.title2)
                    })
                    
                    Button(action:{
                        withAnimation{
                            currentMonth += 1
                      
                        }
                    },label:{
                        Image(systemName: "chevron.right")
                            .font(.title2)
                    })
                    
                    Button(action:{
                        UIDevice.vibrate()
                        withAnimation{
                            showWeekView = true
                        }
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Background")).frame(width: 30, height: 30)
                            Image(systemName: "pip.swap").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                }
                 
                
            }
            
            HStack(spacing: 0){
                ForEach(days,id:\.self){ day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        
                }
            }
            
        }
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 15){
                ForEach(extractDate()){ value in
                    CardView(eventList: calendarVM.eventsResults,value: value, selectedDay: selectedDay, completion: { day in
                        
                       
                        selectedDay = day
                        
                       
                     
                    })
                }
            }
        }.onChange(of: currentMonth) { newValue in
            currentDate = getCurrentMonth()
            selectedMonth = Calendar.current.dateComponents([.month], from: getCurrentMonth()).month ?? Calendar.current.component(.month, from: Date())
            selectedDate = convertComponentsToDate(year: selectedYear, month: selectedMonth, day: selectedDay)
            
        }.padding(10).background(Color("Color")).cornerRadius(20).onAppear{
            calendarVM.startSearch(eventsID: isGroup ? group.eventsID ?? [] : userVM.user?.eventsID ?? [])
        }
    }
    
    @ViewBuilder
    func CardView(eventList: [EventModel],value: DateValue, selectedDay: Int, completion: @escaping (Int) ->()) -> some View {
        
       
        
            if value.day != -1{
                Button(action:{
                    selectedDate = convertComponentsToDate(year: selectedYear, month: selectedMonth, day: value.day)
                    
                    return completion(value.day)
                },label:{
                    VStack(spacing: 3){
                        Text("\(value.day)")
                            .font(.title3)
                            .bold()
                            .foregroundColor(value.day == Calendar.current.component(.day, from: Date()) ? Color.yellow : selectedDay == value.day ? Color("AccentColor") : .white)
                        
                        
                        
                        if hasEvent(eventList: eventList, selectedDay: value.day, selectedMonth: selectedMonth, selectedYear: selectedYear){
                            
                            let eventDateComponents = Calendar.current.dateComponents([.month,.day,.year], from: convertComponentsToDate(year: selectedYear, month: selectedMonth, day: value.day))
                            let currentDateComponents = Calendar.current.dateComponents([.month,.day,.year], from: Date())
                            
                             let currentDate = Calendar.current.date(from: currentDateComponents)
                            let eventDate = Calendar.current.date(from: eventDateComponents)
                            
                            if currentDate ?? Date() <= eventDate ?? Date() {
                                Circle().foregroundColor(Color("AccentColor")).frame(width: 8, height: 8)
                            }else{
                                Circle().foregroundColor(Color.gray).frame(width: 8, height: 8)
                            }
                            
                            
                          
                            }else{
                                Circle().foregroundColor(Color.clear).frame(width: 8, height: 8)
                            }

                       
                        
                    }
                   
                })
                
            }
        
    }
    
    func getDateComponents(date: DateValue) -> [Int] //first is month, second is day, third is year
                    {
        let component = Calendar.current.dateComponents([.year,.month,.day], from: date.date)
        return [component.month ?? Calendar.current.component(.month, from: Date()),component.day ?? 0,component.year ?? 0]
    }
    
    func hasEvent(eventList: [EventModel], selectedDay: Int, selectedMonth: Int, selectedYear: Int) -> Bool{

        var hasEvent = false

        for event in eventList{
            let components = Calendar.current.dateComponents([.month,.day,.year], from: event.eventStartTime?.dateValue() ?? Date())
            let year = components.year ?? 0
            let month = components.month ?? 0
            let day = components.day ?? 0

            if selectedDay == day && selectedMonth == month && selectedYear == year{
                hasEvent = true
            }
          
        }
       
        return hasEvent


    }
    
    func extraDate()->[String]{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: selectedDate)
        
        return date.components(separatedBy: " ")
    }
    
    func getCurrentMonth()-> Date{
        let calendar = Calendar.current
        
        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
         
        }
        return currentMonth
    }
    
    func extractDate()-> [DateValue] {
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        
        var days =  currentMonth.getAllDates().compactMap { date -> DateValue in
        let day = calendar.component(.day, from: date)
            
            return DateValue(day: day, date: date)
        }
        
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }
}

//
//struct CustomDatePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomDatePicker()
//    }
//}


extension Date{
    
    func getAllDates()-> [Date] {
        
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: self)!
        return range.compactMap { (day) -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}
