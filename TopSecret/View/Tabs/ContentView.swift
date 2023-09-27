//
//  HomeScreenView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/30/21.
//

import SwiftUI
import UIKit
import SCSDKLoginKit
import SDWebImageSwiftUI
import CoreData




struct ContentView: View {
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var tabVM : TabViewModel
    @StateObject var pollVM = PollViewModel()
    @State var tabIndex : Tab = .calendar
    @State var showNotification : Bool = false
    @State var selectedGroup : GroupModel = GroupModel()
    
    init() {
        UITextView.appearance().backgroundColor = .clear
    }
    
    @Environment(\.scenePhase) var scenePhase
    
    @Environment(\.managedObjectContext) private var viewContext
    
    
    
    
    var body: some View {
        
        //if there is a user signed in then go to the Tab View else go to the register view
        
        
        ZStack(alignment: .top){
            if userVM.userSession != nil {
                NavigationView{
                    Tabs(tabIndex: $tabIndex, selectedGroup: $selectedGroup)
                }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).navigationViewStyle(.stack)
                
            }else {
                LoginView()
            }
            
        }
        .edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                if userVM.userSession != nil{
                    userVM.checkConnection()
                    userVM.setUserActivity(isActive: true, userID: userVM.user?.id ?? " ", completion: { fetchedUser in
                    })
                }
            }else if newPhase == .background{
                if userVM.userSession != nil{
                    userVM.endConnection()
                    userVM.setUserActivity(isActive: false, userID: userVM.user?.id ?? " ", completion: { fetchedUser in
                    })
                }
            }
        }
        .onReceive(userVM.$connected){ connected in
            userVM.beginListening()
            print("connecte: \(connected)")
        }
    }
}










enum Tab {
    case events, friends, calendar, groups, notifications
}


struct Tabs : View {
    @Binding var tabIndex : Tab
    @Binding var selectedGroup : GroupModel
    @State var showTabButtons : Bool = true
    @State var showSearch: Bool = false
    @StateObject var personalChatVM = PersonalChatViewModel()
    @StateObject var calendarVM = UserCalendarViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var shareVM: ShareViewModel
    @State var selectedPost: GroupPostModel = GroupPostModel()
    @State var selectedPoll: PollModel = PollModel()
    @State var selectedEvent: EventModel = EventModel()
    @State var shareType : String = ""
    @State private var notSeenNotifications: [UserNotificationModel] = []
    var body: some View {
        ZStack{
            if showSearch {
                ExplorePage(showSearch: $showSearch)
            } else {
                ZStack{
                    Color("Background")
                    VStack(){
                        VStack(spacing: 0){
                            TopBar(showSearch: $showSearch, tabIndex: tabIndex)
                            if !(userVM.connected ?? true) {
                                HStack{
                                    Spacer()
                                    Text("Disconnected from internet, data may fail to load").font(.subheadline).fontWeight(.bold).foregroundColor(FOREGROUNDCOLOR)
                                    Spacer()
                                }.padding(5).background(Color.red)
                            }
                        }
                        
                        if tabIndex == .calendar{
                            ScheduleView(calendar: Calendar(identifier: .gregorian), calendarVM: calendarVM)
                            
                        }else if tabIndex == .friends{
                            FriendsView(personalChatVM: personalChatVM)
                        }else if tabIndex == .groups{
                            GroupsView()
                        }else if tabIndex == .notifications{
                            UserNotificationView()
                        }else if tabIndex == .events {
                            DiscoverView()
                        }
                    }
                }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).opacity(userVM.hideBackground ? 0.2 : 1).disabled(userVM.hideBackground)
                
                    .onTapGesture {
                        
                        if userVM.hideBackground{
                            withAnimation{
                                userVM.hideBackground.toggle()
                                if userVM.hideTabButtons{
                                    userVM.hideTabButtons.toggle()
                                }
                            }
                            
                        }
                        if shareVM.showShareMenu{
                            withAnimation{
                                shareVM.showShareMenu.toggle()
                            }
                        }
                        if userVM.showAddContent{
                            self.userVM.showAddContent.toggle()
                        }
                    }
                
            }
            
            
            
            
            
            VStack{
                Spacer()
                
                HStack(alignment: .center){
                    
                    
                    
                    
                    Button(action:{
                        UIDevice.vibrate()
                        
                        self.tabIndex = .events
                    },label:{
                        VStack(spacing: 5){
                            
                            
                            Image(systemName: self.tabIndex == .events ?  "party.popper.fill" : "party.popper").font(.system(size: 20))
                            
                            Text("Events").font(.system(size: 10)).foregroundColor(.gray)
                            
                        }
                        
                        
                    }).foregroundColor(self.tabIndex == .events ? Color("AccentColor") : .white).padding(.horizontal,10)
                    
                    
                    
                    
                    Button(action:{
                        UIDevice.vibrate()
                        
                        self.tabIndex = .friends
                    },label:{
                        
                        VStack(spacing: 5){
                            
                            
                            ZStack{
                                Image(systemName: self.tabIndex == .friends ? "message.fill" : "message").font(.system(size: 20))
                                
                                if userVM.unreadChatsCount >= 1{
                                    ZStack{
                                        Circle().foregroundColor(Color.red).frame(width: 18, height: 18)
                                        Text("\(userVM.getUnreadChatCount(chats: userVM.personalChats))").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                                    }
                                    
                                    .offset(x: 13, y: -10)
                                }
                                
                                
                                
                                
                            }
                            Text("Friends").font(.system(size: 10)).foregroundColor(.gray)
                            
                        }
                        
                        
                        
                        
                    }).foregroundColor(self.tabIndex == .friends ? Color("AccentColor") : .white).padding(.horizontal,10).buttonStyle(.plain)
                    
                    
                    
                    
                    Button(action:{
                        UIDevice.vibrate()
                        
                        self.tabIndex = .calendar
                    },label:{
                        VStack(spacing: 5){
                            
                            
                            Image(systemName: "calendar").font(.system(size: 20))
                            
                            Text("Calendar").font(.system(size: 10)).foregroundColor(.gray).lineLimit(1)
                            
                        }
                        
                    }).foregroundColor(self.tabIndex == .calendar ? Color("AccentColor") : .white).padding(.horizontal)
                    
                    
                    
                    
                    
                    
                    
                    Button(action:{
                        UIDevice.vibrate()
                        
                        self.tabIndex = .groups
                    },label:{
                        VStack(spacing: 5){
                            
                            Image(systemName: self.tabIndex == .groups ?  "person.3.fill" : "person.3").font(.system(size: 20))
                            Text("Groups").foregroundColor(.gray).font(.system(size: 10))
                        }
                        
                        
                    }).foregroundColor(self.tabIndex == .groups ? Color("AccentColor") : .white).padding(.horizontal,10)
                    
                    
                    
                    
                    
                    
                    Button(action:{
                        UIDevice.vibrate()
                        
                        self.tabIndex = .notifications
                    },label:{
                        VStack(spacing: 5){
                            ZStack{
                                Image(systemName: self.tabIndex == .notifications ?  "envelope.fill" : "envelope").font(.system(size: 20))
                                if userVM.unreadNotificationsCount >= 1{
                                    ZStack{
                                        Circle().foregroundColor(Color.red).frame(width: 18, height: 18)
                                        Text("\(userVM.unreadNotificationsCount)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                                    }
                                    
                                    .offset(x: 13, y: -10)
                                }
                            }
                            
                            Text("Notifications").foregroundColor(.gray).font(.system(size: 10))
                        }
                        
                        
                    }).foregroundColor(self.tabIndex == .notifications ? Color("AccentColor") : .white).padding(.horizontal,10)
                    
                    
                    
                    
                }.frame(width: UIScreen.main.bounds.width).padding().padding(.bottom).background(Color("Color"))
            }.opacity(userVM.hideTabButtons ? 0 : 1)
            
            
            
            BottomSheetView(isOpen: Binding(get: {userVM.showAddContent}, set: {userVM.showAddContent = $0}), maxHeight: UIScreen.main.bounds.height / 4){
                HomescreenAddContentView()
            }
            
            
        }.edgesIgnoringSafeArea(.all).onReceive(userVM.$showAddContent) { output in
            if !output && userVM.hideBackground{
                userVM.hideBackground.toggle()
                userVM.hideTabButtons.toggle()
            }
        }.onChange(of: userVM.user?.eventsID) { eventsID in
            if !(eventsID?.isEmpty ?? false){
                calendarVM.startSearch(eventsID: userVM.user?.eventsID ?? [])
            }
        }
    }
}

