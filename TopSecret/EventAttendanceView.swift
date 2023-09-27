//
//  EventAttendanceView.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/9/23.
//

import SwiftUI

struct EventAttendanceView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var selectedOptionIndex : Int = 0
    var event : EventModel
    @StateObject var attendanceVM = EventAttendanceViewModel()
    
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            Image(systemName: "chevron.left").font(.headline).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Attendance")
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal)
                
                HStack{
                    
                    
                    Spacer()
                    
                    Button {
                        
                        selectedOptionIndex = 0
                    } label: {
                        VStack{
                            Text("\(attendanceVM.event.usersAttending?.count ?? 0) Attending").foregroundColor(selectedOptionIndex == 0 ? Color("AccentColor") : FOREGROUNDCOLOR)
                        }
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedOptionIndex = 1
                    } label: {
                        Text("\(attendanceVM.event.usersUndecided?.count ?? 0) Undecided").foregroundColor(selectedOptionIndex == 1 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    }
                    
                    Spacer()
                    
                    Button {
                        selectedOptionIndex = 2
                    } label: {
                        Text("\(attendanceVM.event.usersDeclined?.count ?? 0) Declined").foregroundColor(selectedOptionIndex == 2 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    }
                    
                    Spacer()
                    
                }.padding(5)
                
                
                NavigationLink(destination: InviteFriendsToEventView(event: event)) {
                    HStack{
                        
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "person.fill.badge.plus").font(.system(size: 18)).foregroundColor(FOREGROUNDCOLOR)
                        }
                        
                        
                        Text("Invite Friends").foregroundColor(FOREGROUNDCOLOR)
                        
                        Spacer()
                    }.padding(.vertical,10).padding(.leading,10)
                }
                
                
                Divider()
                
                TabView(selection: $selectedOptionIndex){
                    AttendingAttendanceView(attendanceVM: attendanceVM).tag(0)
                    UndecidedAttendanceView(attendanceVM: attendanceVM).tag(1)
                    DeclinedAttendanceView(attendanceVM: attendanceVM).tag(2)
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            attendanceVM.listenToEvent(eventID: event.id)
        }.onDisappear{
            attendanceVM.removeListener()
        }
    }
}

struct AttendingAttendanceView: View {
    
    @StateObject var attendanceVM : EventAttendanceViewModel

    var body: some View {
        VStack{
            ScrollView{
                ForEach(attendanceVM.event.usersAttending ?? [], id: \.id) { user in
                    NavigationLink {
                        if user.id != USER_ID{
                            UserProfilePage(user: user)
                        }
                    } label: {
                        UserSearchCell(user: user, showActivity: false, showUninviteButton: true, attendanceVM: attendanceVM)
                    }

                }
            }
        }
    }
}

struct UndecidedAttendanceView: View {
    
    @StateObject var attendanceVM : EventAttendanceViewModel


    var body: some View {
        VStack{
            ScrollView{
                ForEach(attendanceVM.event.usersUndecided ?? [], id: \.id) { user in
                    NavigationLink {
                        if user.id != USER_ID{
                            UserProfilePage(user: user)
                        }
                    } label: {
                        UserSearchCell(user: user, showActivity: false, showUninviteButton: true, attendanceVM: attendanceVM)
                    }

                }
            }
        }
    }
}

struct DeclinedAttendanceView: View {
    
    @StateObject var attendanceVM : EventAttendanceViewModel

    var body: some View {
        VStack{
            ScrollView{
                ForEach(attendanceVM.event.usersDeclined ?? [], id: \.id) { user in
                    NavigationLink {
                        if user.id != USER_ID{
                            UserProfilePage(user: user)
                        }
                    } label: {
                        UserSearchCell(user: user, showActivity: false)
                    }
                }
            }
        }
    }
}



