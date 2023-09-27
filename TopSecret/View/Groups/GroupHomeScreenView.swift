//
//  GroupProfileView.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/23/21.
//

import SwiftUI
import Firebase

struct GroupHomeScreenView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    @StateObject var groupVM = GroupViewModel()
    @StateObject var messageVM = MessageViewModel()
    @StateObject var searchRepository = SearchRepository()
    @State var _user: User = User()
    @State var goToUserProfile: Bool = false
    @State var text: String = ""
    @State var countdownName: String = ""
    
    
    @State var group : Group
    
    @Environment(\.presentationMode) var dismiss

    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        dismiss.wrappedValue.dismiss()
                    },label:{
                        Text("Back")
                    }).padding(.leading)
                    
                    Spacer()
                    Text("\(group.groupName)")
                        .fontWeight(.bold)
                        .font(.title).lineLimit(1)
                    
                    Spacer()
                    
                
                    
                    NavigationLink(
                        destination: GroupProfileView(group: group),
                        label: {
                            Image(systemName: "person.3.fill")
                        }).padding(.trailing)
                    
                }.padding(.top,50)
                
                Divider()
                
                Countdowns(group: group, action: {
                    //TODO
                })
                
                Divider()
                
              
                    
                    
                    NavigationLink(destination: ChatView(uid: userVM.user?.id ?? " ", chat: groupVM.groupChat), label: {
                        GroupChatCell(message: messageVM.readLastMessage(), chat: groupVM.groupChat)

                    })
                    
                   
                   
                
//
//
//                SearchBar(text: $searchRepository.searchText, placeholder: "Search").padding()
//
//                ScrollView(){
//                    VStack(alignment: .leading){
//                        VStack(alignment: .leading){
//                            if !searchRepository.searchText.isEmpty{
//                                Text("Users").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
//                            }
//                            VStack{
//                                ForEach(searchRepository.userReturnedResults) { user in
//                                    Button(action: {
//                                        _user = user
//                                    },label:{
//                                        UserSearchCell(user: user)
//                                    })
//
//                                }
//                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
//                        }
//
//
//
//                    }
//
//
//                }
//
//                Button(action:{
//
//                    groupVM.inviteToGroup(user1: userVM.user ?? User(), user2: _user, group: group)
//                },label:{
//                    Text("Add User")
//                }).padding(.bottom,50)
                
                
                VStack{
                    TextField("CountdownName",text: $countdownName)
                    
                    Button(action:{
                        groupVM.createCountdown(group: group, countdownName: countdownName, startDate: Timestamp(), endDate: Timestamp())
                    },label:{
                        Text("Create Countdown")
                    })
                }
//
                Spacer()
                
            
                
                
                
            }
          
            
            
           
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            groupVM.getChat(chatID: group.chatID ?? "")
            messageVM.readAllMessages(chatID: group.chatID ?? "", userID: userVM.user?.id ?? "", chatType: "groupChat")
            
        }
    }
}

struct Countdowns : View {
    
    
    @State var index = 0
    @State var isChanging: Bool = true
    @State var group: Group
    @State var countdowns : [CountdownModel] = []
    @State var timer : Timer? = nil
    @StateObject var groupVM = GroupViewModel()
    var action : () -> Void
    
    func getCountdown(index: Int, countdowns: [CountdownModel]) -> Text{
        if countdowns.isEmpty{
            return Text("Countdowns!")
        }else{
            return Text(countdowns[index].countdownName ?? "")
        }
    }
    
    
   
    
    var body: some View {
            
            Button(action:{
                //TODO
            },label:{
                getCountdown(index: index, countdowns: countdowns).fontWeight(.bold)
            }).foregroundColor(FOREGROUNDCOLOR)

        .onAppear{
            groupVM.loadGroupCountdowns(group: group)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                countdowns = groupVM.countdowns
            }


            timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true){ tempTimer in
                if index != countdowns.count - 1 {
                    withAnimation(.easeOut){
                        index = index + 1
                    }
                }else{
                    withAnimation(.easeOut){
                        index = 0
                    }
                }
        
            }
            
            

        }.onDisappear{
            timer?.invalidate()
            timer = nil
        }
    }
}

//struct GroupHomeScreenView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupHomeScreenView(group: Group())
//    }
//}
