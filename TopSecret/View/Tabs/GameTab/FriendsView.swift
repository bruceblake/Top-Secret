//
//  FriendsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendsView: View {
    
    
    //problem: must store each friends text field text in friendsview
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var searchVM = SearchRepository()
    @StateObject var personalChatVM : PersonalChatViewModel
    @State var openGroupChatView: Bool = false
    @State var openPersonalChatView: Bool = false
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    
    
    func sortPersonalChats(userID: String) -> [ChatModel]{
        let chats = userVM.personalChats 
        
        return chats.sorted(by: { !($0.usersThatHaveSeenLastMessage?.contains(userID) ?? false) &&  ($1.usersThatHaveSeenLastMessage?.contains(userID) ?? false)} )
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                VStack(alignment: .leading, spacing: 3){
                    HStack(spacing: 2){
                        Text("\(userVM.user?.friendsListID?.count ?? 0) \(userVM.user?.friendsListID?.count ?? 0 != 1 ? "friends" : "friend")").font(.body).bold().foregroundColor(Color.gray)
                        
                        Text(", \(userVM.groups.count) \(userVM.groups.count != 1 ? "groups" : "group")").font(.body).bold().foregroundColor(Color.gray)
                        
                        Spacer()
                    }
                    if (userVM.user?.incomingFriendInvitationID?.count ?? 0) != 0 {
                        Text("\((userVM.user?.incomingFriendInvitationID?.count ?? 0) != 1 ? "\(userVM.user?.incomingFriendInvitationID?.count ?? 0) friend requests" : "\(userVM.user?.incomingFriendInvitationID?.count ?? 0) friend request")").foregroundColor(FOREGROUNDCOLOR)
                    }
                      
                       
                    
                
                }.padding(.horizontal,30)
                ScrollView{
                    if !(userVM.connected ?? false) && userVM.personalChats.isEmpty {
                        VStack{
                            Spacer()
                            Text("Unable to fetch friends list").foregroundColor(Color.gray)
                        }
                    }
                    else if (userVM.personalChats.isEmpty && userVM.connected ?? false) {
                          
                                Button(action: {
                                    //todo
                                },label: {
                                    Text("Add Friends").foregroundColor(Color("Foreground"))
                                        .padding(.vertical)
                                        .frame(width: UIScreen.main.bounds.width/2.5).background(Color("AccentColor")).cornerRadius(15)
                                })
                               
                        }else{
                            VStack{
                                ForEach(self.sortPersonalChats(userID: userVM.user?.id ?? " "), id: \.id){ chat in
                                    if chat.chatType == "groupChat"{
                                        Button(action:{
                                            let dp = DispatchGroup()
                                            dp.enter()
                                            groupVM.changeCurrentGroup(groupID: chat.groupID ?? " ") { finishedFetching in
                                                dp.leave()
                                            }
                                            dp.notify(queue: .main, execute: {
                                                openGroupChatView.toggle()
                                            })
                                        },label:{
                                            GroupChatCell(chat: chat)
                                        })
                                        NavigationLink(destination:  HomeScreenView(chatID: groupVM.group.chatID ?? " ", groupID: chat.groupID ?? " ", selectedOptionIndex: 1), isActive: $openGroupChatView) {
                                            EmptyView()
                                        }
                                      
                                        
                                    }else{
                                        Button {
                                           let dp = DispatchGroup()
                                            dp.enter()
                                            personalChatVM.listenToChat(chatID: chat.id)
//                                            personalChatVM.fetchFirstMessages(chatID: chat.id, userID: USER_ID)
                                            dp.leave()
                                            dp.notify(queue: .main, execute: {
                                                openPersonalChatView = true
                                            })
                                            
                                        } label: {
                                            FriendCell(user: personalChatVM.getPersonalChatUser(chat: chat, userID: userVM.user?.id ?? " "), personalChatVM: personalChatVM, chat: chat)
                                        }
                                        NavigationLink(destination: PersonalChatView(personalChatVM: personalChatVM, chatID: chat.id), isActive: $openPersonalChatView) {
                                            EmptyView()
                                        }
                                        
                                    }
                                    
                                    

                                    }
                            }.padding(.bottom, UIScreen.main.bounds.height/4)
                         
                        }
                  
                    
                    
                }
            }
            
          


        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
}



struct GroupChatCell : View {
    @EnvironmentObject var userVM: UserViewModel
    
    
    func getTimeSinceMessage(lastMessageDate: Date) -> String{
        let interval = (Date() - lastMessageDate)
        
        
        let seconds = interval.second ?? 0
        let minutes = (seconds / 60)
        let hours = (minutes / 60)
        let days = (hours / 24)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
        }
        if time == "0s"{
            return "now"
        }else{
            return time
        }
        
    }
    var chat: ChatModel
    var body: some View {
        VStack(alignment: .leading){
            
            
            //Message indicator
            HStack(alignment: .center){
                
                if !((chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? " ") ?? false)){
                    
                    
                    Circle().frame(width: 12, height: 12).foregroundColor(Color("AccentColor"))
                }
                
                
                //Profile Picture
                ZStack(alignment: .bottomTrailing){
                    
                   
                    WebImage(url: URL(string: chat.profileImage ?? " "))
                        .resizable()
                        .scaledToFill()
                        .frame(width:48,height:48)
                        .clipShape(Circle())
                
                    
                 
                    WebImage(url: URL(string: chat.lastMessage?.profilePicture ?? " ")).resizable().frame(width: 25, height: 25).clipShape(Circle())
                    .offset(y: 2)
                    
                }
                
              
                
                HStack(alignment: .center){
                    
                    VStack(alignment: .leading, spacing: 0){
                        
                        VStack(alignment: .leading, spacing: 2){
                            Text("\(chat.name ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.headline)
                            
                            HStack{
                                
                                 if chat.lastMessage?.type == "eventMessage"{
                                    Text("\(chat.lastMessage?.name ?? "") sent an event")
                                }else if chat.lastMessage?.type == "pollMessage"{
                                    Text("\(chat.lastMessage?.name ?? "") sent a poll")
                                }else if chat.lastMessage?.type == "image"{
                                    Text("\(chat.lastMessage?.name ?? "") sent an image")
                                }else if chat.lastMessage?.type == "video"{
                                    Text("\(chat.lastMessage?.name ?? "") sent a video")
                                }else if chat.lastMessage?.type == "multipleImages"{
                                    Text("\(chat.lastMessage?.name ?? "") sent \(chat.lastMessage?.urls?.count ?? 0) images")
                                }else if chat.lastMessage?.type == "multipleVideos"{
                                    Text("\(chat.lastMessage?.name ?? "") sent \(chat.lastMessage?.urls?.count ?? 0) videos")
                                }
                                else{
                                    Text("\( (chat.lastMessage ?? Message() ).value ?? "")").lineLimit(1).foregroundColor(chat.lastMessage?.type == "delete" ? Color("AccentColor") : (chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? "") ?? false ) ? Color.gray : FOREGROUNDCOLOR).font(.subheadline)
                                }
                            }.foregroundColor(Color.gray)

                        }
   
                    }
                    
                }
                Spacer()
                
                
                
                VStack(alignment: .leading, spacing: 5){
                    Text("\(self.getTimeSinceMessage(lastMessageDate: chat.lastActionDate?.dateValue() ?? Date() ))").font(.subheadline).foregroundColor(Color.gray)
                    
                    if(chat.usersTypingID.contains(userVM.user?.id ?? " ")){
                        Image(systemName: "pencil.line").foregroundColor(Color("AccentColor"))
                    }
                }
                
            }.padding()
        }.padding(.horizontal,10).background(Rectangle().stroke(Color("Color")))
    }
}
