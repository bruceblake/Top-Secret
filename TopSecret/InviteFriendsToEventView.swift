//
//  InviteFriendsToEventView.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/14/23.
//

import SwiftUI
import SDWebImageSwiftUI

struct InviteFriendsToEventView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var searchVM = SearchRepository()
    @StateObject var eventVM = EventsTabViewModel()
    @State var selectedUsers: [User] = []
    var event: EventModel
    var body: some View {
        ZStack{
            BACKGROUNDCOLOR
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    
                    Text("Invite Friends To Event").font(.title2)
                    
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal)
                
                SearchBar(text: $searchVM.searchText, placeholder: "Invite Friends") {
                    //dick
                }
                VStack(alignment: .leading){
                    if selectedUsers.count > 0 {
                        Text("Invited Users").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                    }
                    ScrollView(.horizontal){
                        HStack{
                            ForEach(selectedUsers, id: \.id){ user in
                                if user.id != userVM.user?.id ?? "" {
                                    Button(action:{
                                        searchVM.searchText = user.nickName ?? ""
                                    },label:{
                                        HStack{
                                            Text(user.nickName ?? "").foregroundColor(FOREGROUNDCOLOR)
                                            Button(action:{
                                                selectedUsers.removeAll(where: {$0 == user})
                                            },label:{
                                                Image(systemName: "x.circle.fill")
                                            }).foregroundColor(FOREGROUNDCOLOR)
                                        }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                                        
                                    })
                                }
                                
                                
                            }
                        }
                    }
                }.padding(10)
                
                
                VStack(alignment: .leading){
                    ScrollView(){
                        if searchVM.searchText == "" {
                            if userVM.user?.friendsList?.count ?? 0 > 0 {
                                HStack{
                                    Text("Suggested Friends").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                                    Spacer()
                                }.padding(.leading,5)
                            }
                            ForEach(userVM.user?.friendsList ?? [], id: \.id){ friend in
                                Button(action:{
                                    if selectedUsers.contains(friend){
                                        selectedUsers.removeAll { user in
                                            user.id == friend.id ?? ""
                                        }
                                    }else{
                                        selectedUsers.append(friend)
                                    }
                                },label:{
                                    HStack{
                                        
                                        WebImage(url: URL(string: friend.profilePicture ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width:40,height:40)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading){
                                            Text("\(friend.nickName ?? "")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                            Text("@\(friend.username ?? "")").font(.footnote).foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        Circle().frame(width: 20, height: 20).foregroundColor(selectedUsers.contains(friend) ? Color("AccentColor") : FOREGROUNDCOLOR)
                                        
                                        
                                    }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background")))
                                })
                            }
                        }else{
                            ForEach(searchVM.userFriendsReturnedResults, id: \.id){ friend in
                                Button(action:{
                                    if selectedUsers.contains(friend){
                                        selectedUsers.removeAll { user in
                                            user.id == friend.id ?? ""
                                        }
                                    }else{
                                        selectedUsers.append(friend)
                                    }
                                },label:{
                                    HStack{
                                        
                                        WebImage(url: URL(string: friend.profilePicture ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width:40,height:40)
                                            .clipShape(Circle())
                                        
                                        VStack(alignment: .leading){
                                            Text("\(friend.nickName ?? "")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                            Text("@\(friend.username ?? "")").font(.footnote).foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        Circle().frame(width: 20, height: 20).foregroundColor(selectedUsers.contains(friend) ? Color("AccentColor") : FOREGROUNDCOLOR)
                                        
                                        
                                    }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background")))
                                })
                                
                                
                            }
                        }
                    }
                }.padding(10)
                
                Button(action:{
                    eventVM.inviteToEvent(userID: USER_ID, invitedIDS: selectedUsers, event: event)
                    presentationMode.wrappedValue.dismiss()
                },label:{
                    Text("Invite Friends").foregroundColor(FOREGROUNDCOLOR)
                    .frame(width: UIScreen.main.bounds.width/1.5).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                        
                }).padding(.vertical,10).padding(.bottom,30)
                
                Spacer()
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsersFriends", id: USER_ID)
        }
    }
}


