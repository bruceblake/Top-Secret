//
//  UserFriendsListView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/4/22.
//

import SwiftUI

struct UserFriendsListView: View {
    var user: User
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var searchVM = SearchRepository()
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,10)
                    
                    
                       
                    
                    SearchBar(text: $searchVM.searchText, placeholder: "friends", onSubmit: {
                        
                    })
                    
                    
                }.padding(.top,50)
                
                //show all friends
                if searchVM.searchText == "" {
                    ScrollView{
                        VStack(alignment: .leading){
                            Text("Friends").font(.body).bold().padding([.leading,.top],10)

                            ForEach(user.friendsList ?? []){ friend in
                                NavigationLink {
                                    if friend.id == userVM.user?.id ?? ""{
                                        
                                    CurrentUserProfilePage()
                                    }else{
                                        UserProfilePage(user: friend)
                                    }
                                } label: {
                                    UserSearchCell(user: friend, showActivity: false)
                                }

                             
                            }
                        }
                    }
                }else{
                    //show search
                    ScrollView{
                        VStack(alignment: .leading){
                            Text("Friends")

                            ForEach(searchVM.userFriendsReturnedResults, id: \.id){ friend in
                                NavigationLink {
                                    if friend.id == userVM.user?.id ?? " "{
                                    CurrentUserProfilePage()
                                    }else{
                                        UserProfilePage(user: friend)
                                    }
                                } label: {
                                    UserSearchCell(user: friend, showActivity: false)
                                }

                             
                            }
                        }
                      
                    }
                }
            
                
             
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUserFriends", id: user.id ?? " ")
        }
    }
}



struct UserGroupListView : View {
    var user: User
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var searchVM = SearchRepository()
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,10)
                    
                    
                       
                    
                    SearchBar(text: $searchVM.searchText, placeholder: "groups", onSubmit: {
                        
                    })
                    
                    
                }.padding(.top,50)
            }
        }
    }
}
