//
//  UserNotificationCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/24/22.
//

import SwiftUI
import SDWebImageSwiftUI




struct UserNotificationCell: View {
    var userNotification : UserNotificationModel
    @EnvironmentObject var userVM: UserViewModel
    @ObservedObject var notificationVM = UserNotificationViewModel()
    @State var showAddEventView: Bool = false
    var body: some View {
        ZStack{
            
            
            switch userNotification.type ?? ""{
            
                //friend requests
                case "sentFriendRequest":
                    UserSentFriendRequestNotificationCell(userNotification: userNotification)
                case "acceptedFriendRequest":
                    UserAcceptedFriendRequestNotificationCell(userNotification: userNotification)
                case "deniedFriendRequest":
                    UserDeniedFriendRequestNotificationCell(userNotification: userNotification)
                case "rescindFriendRequest":
                    UserRescindedFriendRequestNotificationCell(userNotification: userNotification)
                case "removedFriend":
                    UserRemovedFriendNotificationCell(userNotification: userNotification)
                    
                //group
                case "sentGroupInvitation":
                    UserSentGroupInvitationNotificationCell(userNotification: userNotification)
                case "acceptedGroupInvitation":
                    UserAcceptedGroupInvitationNotificationCell(userNotification: userNotification)
                case "acceptedEventInvitation":
                    UserAcceptedEventInvitationNotificationCell(userNotification: userNotification)
                case "deniedGroupInvitation":
                    UserDeniedGroupInvitationNotificationCell(userNotification: userNotification)
                    
                //events
                case "eventEnded":
                    UserEventEndedNotificationCell(userNotification: userNotification, showAddEventView: $showAddEventView)
                case "eventCreated":
                    UserEventCreatedNotificationCell(userNotification: userNotification, showAddEventView: $showAddEventView)
                case "invitedToEvent":
                    UserInvitedToEventNotificationCell(userNotification: userNotification, showAddEventView: $showAddEventView)
                case "uninvitedToEvent":
                    UserUninvitedToEventNotificationCell(userNotification: userNotification, showAddEventView: $showAddEventView)
                case "leftEvent":
                    UserLeftEventNotificationCell(userNotification: userNotification, showAddEventView: $showAddEventView)
             
          
                //block
                case "blockedUser":
                    UserBlockedNotificationCell(userNotification: userNotification)
                case "unblockedUser":
                    UserUnblockedNotificationCell(userNotification: userNotification)
                default:
                    Text("Notification")
            }
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            notificationVM.readNotification(notification: userNotification)
        }
    }
}

struct UserAcceptedEventInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }
    
    var body: some View {
        HStack{
            
            
            NavigationLink {
                
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "party.popper").foregroundColor(Color("AccentColor"))
                        }.padding(.leading,5)
                        
                        VStack(alignment: .leading){
                            HStack{
                                Text("\((userNotification.event ?? EventModel()).eventName ?? " ")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            if sender.id == USER_ID{
                                Text("you accepted the invitation to \(event.eventName ?? " ") " ).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text(" \(sender.nickName ?? " ") accepted the invitation to \(event.eventName ?? " ") " ).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                         
                            
                            
                        }
                        Spacer()
                    }
                    
                }
            }
            
            
            
        }
    }
}




struct UserAcceptedGroupInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var group: GroupModel {
        return userNotification.group ?? GroupModel()
    }
    
    var body: some View {
                        
            NavigationLink {
                GroupProfileView(group: userNotification.group ?? GroupModel(), isInGroup: (userNotification.group ?? GroupModel()).usersID.contains(userVM.user?.id ?? " "))
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.group ?? GroupModel()).groupProfileImage ))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading, 5)
                        
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.group ?? GroupModel()).groupName )").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            if sender.id == USER_ID{
                                Text("You accepted the invitation to \(group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text("\(sender.nickName ?? " ") accepted the invitation to \(group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                       
                            
                        }
                        
                        Spacer()
                        
                    }
                    
                }
            }
            
            
            
        
    }
}


struct UserDeniedGroupInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var group: GroupModel {
        return userNotification.group ?? GroupModel()
    }
    
    var body: some View {
                        
            NavigationLink {
                GroupProfileView(group: userNotification.group ?? GroupModel(), isInGroup: (userNotification.group ?? GroupModel()).usersID.contains(userVM.user?.id ?? " "))
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.group ?? GroupModel()).groupProfileImage ))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading, 5)
                        
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.group ?? GroupModel()).groupName )").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            if sender.id == USER_ID{
                                Text("You denied the invitation to \(group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text("\(sender.nickName ?? " ") denied the invitation to \(group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                       
                            
                        }
                        
                        Spacer()
                        
                    }
                    
                }
            }
            
            
            
        
    }
}







struct UserSentGroupInvitationNotificationCell : View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var groupVM = GroupViewModel()
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var group: GroupModel {
        return userNotification.group ?? GroupModel()
    }
    
    var body: some View {
        HStack{
            
            
            NavigationLink {
                GroupProfileView(group: userNotification.group ?? GroupModel(), isInGroup: (userNotification.group ?? GroupModel()).usersID.contains(userVM.user?.id ?? " "))
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        WebImage(url: URL(string: (userNotification.group ?? GroupModel()).groupProfileImage ))
                            .resizable()
                            .scaledToFill()
                            .frame(width:40,height:40)
                            .clipShape(Circle())
                            .padding(.leading,5)
                        
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.group ?? GroupModel()).groupName )").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                                
                                if sender.id ?? " " == USER_ID {
                                    Text("You sent a group invitation to \(receiver.nickName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                }else{
                                    Text("\(sender.nickName ?? " ") sent you an invitation to \(group.groupName) ").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                }
                            
                            
                        }
                        
                    }
                    
                }
            }
            
            
            
            Spacer()
            
            if userNotification.requiresAction ?? false == false {
                Text("Expired").foregroundColor(Color.gray).font(.footnote)
            }else{
                if (userVM.user?.pendingGroupInvitationID?.contains((userNotification.group ?? GroupModel()).id ) ?? false) {
                    
                    HStack{
                        Button(action:{
                            groupVM.acceptGroupInvitation(group: userNotification.group ?? GroupModel(), user: self.userVM.user ?? User())
                            userNotificationVM.setRequiresAction(usersID: [USER_ID], notificationID: userNotification.id)
                        },label:{
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.green)
                                
                                Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                            }             })
                        
                        
                        Button(action:{
                            groupVM.denyGroupInvitation(group: userNotification.group ?? GroupModel(), user: self.userVM.user ?? User())
                            userNotificationVM.setRequiresAction(usersID: [USER_ID], notificationID: userNotification.id)
                        },label:{
                            ZStack{
                                RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.red)
                                
                                Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                            }
                            
                            
                        })
                    }.padding(.trailing)
                }
            }
            
           
            
            
            
            
            
            
        }
    }
}

struct UserRescindedFriendRequestNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                if USER_ID == sender.id ?? " " {
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                } else {
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                }
                              
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                            }
                            
                            if USER_ID == sender.id ?? " " {
                                Text("rescinded your friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text("You rescinded their friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                               
                            
                        }
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }
        
        
        
        
    }
}

struct UserAcceptedFriendRequestNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            //current user is sender
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        VStack(alignment: .leading){
                            if sender.id ?? " " == USER_ID {
                                HStack(spacing: 5){
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("You accepted their friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                
                            }else{
                                HStack(spacing: 5){
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)

                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("accepted your friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                  
                                
                            }
                            
                            
                            
                        }
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }
        
        
        
        
    }
}

struct UserDeniedFriendRequestNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        if receiver.id ?? " " != USER_ID {
                       
                            
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("You denied their friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                   
                                
                            }
                        }else {
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("denied your friend request.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                        }
                        
                        
                        
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }
        
        
        
        
    }
}

struct UserSentFriendRequestNotificationCell : View {
    
    @EnvironmentObject var userVM : UserViewModel
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        HStack{
            
            
            NavigationLink {
                //current user is the sender
                if USER_ID == sender.id ?? " "{
                    UserProfilePage(user: (receiver) )
                }else{
                    //current user is the receiver
                    UserProfilePage(user: (sender) )
                }
            } label: {
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .center, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (receiver.id ?? " " != USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        VStack(alignment: .leading){
                            HStack(alignment: .top, spacing: 5){
                                    //current user is sender
                                if receiver.id ?? " " != USER_ID {
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                }else{
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                }
                                
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)

                                
                            }
                                //current user is sener
                                if receiver.id ?? " " != USER_ID {
                                  
                                    Text("You sent a friend request").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                }else{
                                    //current user is receiver
                                    Text("sent you a friend request").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                   
                                }
                                
                               
                                
                                
                            
                            
                            
                            
                            
                            
                        }
                        
                        Spacer()
                        
                        
                        if(userNotification.requiresAction == false){
                            Text("Expired").foregroundColor(Color.gray).padding(.trailing,10).font(.subheadline)
                        }else{
                            
                            if (userVM.user?.incomingFriendInvitationID?.contains(sender.id ?? " ") ?? false) && userNotification.requiresAction ?? false {
                                
                                HStack{
                                    Button(action:{
                                        userVM.acceptFriendRequest(friend: sender)
                                        userNotificationVM.setRequiresAction(usersID: [sender.id ?? " ", receiver.id ?? " "], notificationID: userNotification.id)
                                    },label:{
                                        
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.green)
                                            
                                            Image(systemName: "checkmark").foregroundColor(FOREGROUNDCOLOR)
                                        }            })
                                    
                                    
                                    Button(action:{
                                        userVM.denyFriendRequest(friend: sender)
                                        userNotificationVM.setRequiresAction(usersID: [sender.id ?? " ", receiver.id ?? " "], notificationID: userNotification.id)
                                    },label:{
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 12).frame(width: 30, height: 30).foregroundColor(Color.red)
                                            
                                            Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                                        }
                                        
                                        
                                    })
                                }.padding(.trailing)
                            }
                            
                            else if  (userVM.user?.friendsListID?.contains(receiver.id ?? " ") ?? false){
                                Text("Friends").foregroundColor(.gray).font(.subheadline).padding(.trailing,10)
                            }
                            
                        }
                        
                    }
                }
                
                
                
                
                
            }
            
            
            
            
            
        }
    }
}

struct UserEventCreatedNotificationCell : View {
    
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    
    @Binding var showAddEventView: Bool
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }
    
    var body: some View {
        
        Button(action:{
            showAddEventView.toggle()
        },label:{
            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 5){
                    
                    ZStack{
                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                        Image(systemName: "party.popper").foregroundColor(FOREGROUNDCOLOR)
                    }.padding(.leading,5)
                    
                    
                    VStack(alignment: .leading){
                        HStack(spacing: 5){
                            Text("\((userNotification.event ?? EventModel()).eventName ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                            Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                        }
                        Text("you created \((userNotification.event ?? EventModel()).eventName ?? "")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                        
                    }
                    
                    Spacer()
                }
                
            }
        })
        
       
        NavigationLink(destination:   EventDetailView(eventID: userNotification.event?.id ?? " ", showAddEventView: $showAddEventView), isActive: $showAddEventView) {
            EmptyView()
        }
    }
    
}

struct UserEventEndedNotificationCell : View {
    
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    
    @Binding var showAddEventView: Bool
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }

    
    var body: some View {
        
        Button(action:{
            showAddEventView.toggle()
        },label:{
            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 5){
                    
                    ZStack{
                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                        Image(systemName: "party.popper").foregroundColor(FOREGROUNDCOLOR)
                    }.padding(.leading,5)
                    
                    
                    VStack(alignment: .leading){
                        HStack(spacing: 5){
                            Text("\((userNotification.event ?? EventModel()).eventName ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                            Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                        }
                        Text("ended on \((userNotification.event ?? EventModel()).eventEndTime?.dateValue() ?? Date(), style: .date)").font(.subheadline).foregroundColor(FOREGROUNDCOLOR)
                        
                    }
                    
                    Spacer()
                }
                
            }
        })
        
       
        NavigationLink(destination:   EventDetailView(eventID: userNotification.event?.id ?? "", showAddEventView: $showAddEventView), isActive: $showAddEventView) {
            EmptyView()
        }
    }
    
}



struct UserInvitedToEventNotificationCell : View {
    
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var eventVM = EventViewModel()
    @State var userIsAttending: Bool = false
    func userIsAttending(event: EventModel) -> Bool{
        return event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false
    }
    @Binding var showAddEventView: Bool
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }
    
    var invitedToEvent : Bool {
        var event = eventVM.event
        return (event.usersInvitedID?.contains(where: {$0 == USER_ID}) ?? false)
    }
    
    var body: some View {
        
        NavigationLink {
            UserProfilePage(user: sender)
        } label : {
            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(spacing: 5){
                    
                    ZStack{
                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                        Image(systemName: "party.popper").foregroundColor(FOREGROUNDCOLOR)
                    }.padding(.leading,5)
                    
                    HStack{
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.event ?? EventModel()).eventName ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            
                            if sender.id ?? "" != USER_ID{
                                Text("\((userNotification.event ?? EventModel()).creator?.nickName ?? " ") invited you to \((userNotification.event ?? EventModel()).eventName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text("\((userNotification.event ?? EventModel()).creator?.nickName ?? " ") invited you to \((userNotification.event ?? EventModel()).eventName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                           
                            
                        }
                        
                        Spacer()
                        if invitedToEvent{
                            Button(action:{
                                self.showAddEventView.toggle()
                            },label:{
                                Text("See Details").padding(.trailing)
                            })
                        }else{
                            Text("Uninvited").foregroundColor(Color.gray).padding(.trailing)
                        }
                      
                        
                    }
                }
                
            }
            NavigationLink(destination:   EventDetailView(eventID: userNotification.event?.id ?? "", showAddEventView: $showAddEventView), isActive: $showAddEventView) {
                EmptyView()
            }
        }
        
        .onAppear{
            eventVM.fetchEvent(eventID: userNotification.eventID ?? " ")
        }
        
        
    }
}



struct UserUninvitedToEventNotificationCell : View {
    
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @State var userIsAttending: Bool = false
    func userIsAttending(event: EventModel) -> Bool{
        return event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false
    }
    @Binding var showAddEventView: Bool
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }
    
    
    var body: some View {
        
        NavigationLink {
            UserProfilePage(user: sender)
        } label : {
            VStack(alignment: .leading, spacing: 8){
                
                
                HStack(alignment: .top, spacing: 5){
                    
                    ZStack{
                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                        Image(systemName: "party.popper").foregroundColor(FOREGROUNDCOLOR)
                    }.padding(.leading,5)
                    
                    HStack{
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.event ?? EventModel()).eventName ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.footnote)
                            }
                            
                            if sender.id ?? "" != USER_ID{
                                Text("you were uninvited from \((userNotification.event ?? EventModel()).eventName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }else{
                                Text("you uninvited \((userNotification.receiver ?? User()).username ?? "") from \((userNotification.event ?? EventModel()).eventName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                           
                            
                        }
                        
                        Spacer()
                    
                      
                        
                    }
                 
                    
                    
                    
                    
                    
                }
                
            }
            NavigationLink(destination:   EventDetailView(eventID: userNotification.event?.id ?? "", showAddEventView: $showAddEventView), isActive: $showAddEventView) {
                EmptyView()
            }
        }
        
        
        
    }
}


struct UserLeftEventNotificationCell : View {
    
    var userNotification : UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    @EnvironmentObject var userVM: UserViewModel
    @State var userIsAttending: Bool = false
    func userIsAttending(event: EventModel) -> Bool{
        return event.usersAttendingID?.contains(userVM.user?.id ?? " ") ?? false
    }
    @Binding var showAddEventView: Bool
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var event : EventModel {
        return userNotification.event ?? EventModel()
    }
    
    
    var body: some View {
        
        NavigationLink {
            UserProfilePage(user: sender)
        } label : {
            VStack(alignment: .leading, spacing: 8){
                
                 
                HStack(alignment: .top, spacing: 5){
                    
                    ZStack{
                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                        Image(systemName: "party.popper").foregroundColor(FOREGROUNDCOLOR)
                    }.padding(.leading,5)
                    
                    HStack{
                        VStack(alignment: .leading){
                            HStack(spacing: 5){
                                Text("\((userNotification.event ?? EventModel()).eventName ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                            }
                            if sender.id ?? " " == USER_ID{
                                Text("you left \((userNotification.event ?? EventModel()).eventName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)

                            }else{
                                Text("\( (userNotification.event ?? EventModel()).creator?.username ?? " ") left \((userNotification.event ?? EventModel()).eventName ?? " ")").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)

                            }
                            
                        }
                        
                        Spacer()
                    
                      
                        
                    }
                 
                    
                    
                    
                    
                    
                }
                
            }
            NavigationLink(destination:   EventDetailView(eventID: userNotification.event?.id ?? "", showAddEventView: $showAddEventView), isActive: $showAddEventView) {
                EmptyView()
            }
        }
        
        
        
    }
}


struct UserRemovedFriendNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        if receiver.id ?? " " != USER_ID {
                       
                            
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("You removed them as a friend.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                   
                                
                            }
                        }else {
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("removed you as a friend.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                        }
                        
                        
                        
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }
        
        
        
        
    }
}


struct UserBlockedNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        if receiver.id ?? " " != USER_ID {
                       
                            
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("You blocked them.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                   
                                
                            }
                        }else {
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("blocked you.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                        }
                        
                        
                        
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }
        
        
        
        
    }
}

struct UserUnblockedNotificationCell : View {
    
    var userNotification: UserNotificationModel
    var userNotificationVM = UserNotificationViewModel()
    
    var sender : User {
        return userNotification.sender ?? User()
    }
    
    var receiver : User {
        return userNotification.receiver ?? User()
    }
    
    var body: some View {
        
        NavigationLink {
            if USER_ID == sender.id ?? " "{
                UserProfilePage(user: (receiver) )
            }else{
                UserProfilePage(user: (sender) )
            }
        } label: {
            HStack{
                
                
                
                VStack(alignment: .leading, spacing: 8){
                    
                    
                    HStack(alignment: .top, spacing: 5){
                        
                        ZStack(alignment: .bottomTrailing){
                            WebImage(url: URL(string: (sender.id ?? " " == USER_ID ) ?  receiver.profilePicture ?? "" : sender.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:40,height:40)
                                .clipShape(Circle())
                                .padding(.leading,5)
                    
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 20, height: 20)
                                
                                
                                    
                               
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.caption)


                            }.offset(y: 2)
                        }
                           
                        
                        
                        if receiver.id ?? " " != USER_ID {
                       
                            
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(receiver.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("You unblocked them.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                                   
                                
                            }
                        }else {
                            VStack(alignment: .leading){
                                HStack(spacing: 5){
                                    Text("\(sender.username ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.subheadline)
                                    Text("\(userNotificationVM.getTimeSinceNotification(date: userNotification.timeStamp?.dateValue() ?? Date()))").foregroundColor(.gray).font(.subheadline)
                                }
                                    Text("unblocked you.").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                            }
                        }
                        
                        
                        
                        
                    }
                    
                }
                
                Spacer()
                
                
                
                
            }
        }
        
        
        
        
    }
}
