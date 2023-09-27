//
//  SearchedView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/16/22.
//

import SwiftUI
struct SearchedView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var searchVM: SearchRepository
    @State var selectedGroup : GroupModel = GroupModel()
    @State var openGroupProfile : Bool = false
    @EnvironmentObject var userVM : UserViewModel
    @State var selectedOptionIndex : Int = 0
    var options = ["Top","Users","Groups","Friends","Favorites"]

    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(spacing: 5){
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,5)
                    
                    SearchBar(text: $searchVM.searchText, placeholder: searchVM.searchText, onSubmit: {
                        
                    })
                }.padding(.top,50)
                
                HStack{
                    
                    Spacer()
                    
                    Button(action:{
                        withAnimation{
                            selectedOptionIndex = 0
                        }
                    },label:{
                        Text("Top").foregroundColor(selectedOptionIndex == 0 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    })
                    
                    Spacer()
                    
                    Button(action:{
                        withAnimation{
                            selectedOptionIndex = 1
                        }
                    },label:{
                        Text("Users").foregroundColor(selectedOptionIndex == 1 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    })
                    
                    Spacer()
                    
                    Button(action:{
                        withAnimation{
                            selectedOptionIndex = 2
                        }
                    },label:{
                        Text("Groups").foregroundColor(selectedOptionIndex == 2 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    })
                    
                    Spacer()
                    
                    Button(action:{
                        withAnimation{
                            selectedOptionIndex = 3
                        }
                    },label:{
                        Text("Friends").foregroundColor(selectedOptionIndex == 3 ? Color("AccentColor") : FOREGROUNDCOLOR)
                    })
                    
                    Spacer()
                }
                
                TabView(selection: $selectedOptionIndex){
                    TopResults(searchVM: searchVM).tag(0)
                    UserResults(searchVM: searchVM).tag(1)
                    GroupResults(searchVM: searchVM).tag(2)
                    FriendResults(searchVM: searchVM).tag(3)
                }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))


                
           
                
                
                
                
               Spacer()
            }
        }.navigationBarHidden(true).edgesIgnoringSafeArea(.all)
    }
}



struct FriendResults : View {
    @ObservedObject var searchVM: SearchRepository
    @State var selectedGroup : GroupModel = GroupModel()
    @State var openGroupProfile : Bool = false
    @EnvironmentObject var userVM : UserViewModel
    
    var body: some View {
        
        ZStack{
            Color("Background")
            ScrollView(){
                if !searchVM.searchText.isEmpty && searchVM.userFriendsReturnedResults.isEmpty{
                    Text("There are no friend results for \(searchVM.searchText)")
                }
                VStack(alignment: .leading){
                  
       
                    VStack(alignment: .leading, spacing: 0){
                        if !searchVM.searchText.isEmpty && !searchVM.userFriendsReturnedResults.isEmpty{
                            Text("Friends").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                        }
                        ForEach(searchVM.userFriendsReturnedResults, id: \.id){ user in
                                NavigationLink {
                                
                                        UserProfilePage(user: user)
                                    
                                } label: {
                                    UserSearchCell(user: user, showActivity: false)
                                }

                             
                            

                         
                        }
                    }
                    

                }
                
                
            }.padding(.top,10)
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
      
    }
}




struct GroupResults : View {
    @ObservedObject var searchVM: SearchRepository
    @State var selectedGroup : GroupModel = GroupModel()
    @State var openGroupProfile : Bool = false
    @EnvironmentObject var userVM : UserViewModel
    
    var body: some View {
        
        ZStack{
            Color("Background")
            ScrollView(){
                if !searchVM.searchText.isEmpty && searchVM.groupReturnedResults.isEmpty{
                    Text("There are no group results for \(searchVM.searchText)")
                }
                VStack(alignment: .leading){
                  
                    
                    VStack(alignment: .leading, spacing: 2){
                        if !searchVM.searchText.isEmpty && !searchVM.groupReturnedResults.isEmpty{
                            Text("Groups").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                        }
                        VStack{
                            ForEach(searchVM.groupReturnedResults, id: \.id){ group in
                                    NavigationLink {
                                        GroupProfileView(group: selectedGroup, isInGroup: selectedGroup.usersID.contains(userVM.user?.id ?? " "))
                                    } label: {
                                        GroupSearchCell(group: group)
                                    }

                                 
                                

                             
                            }
                        }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                    }
                
                    

                }
                
                
            }.padding(.top,10)
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
      
    }
}

struct UserResults : View {
    @ObservedObject var searchVM: SearchRepository
    @State var selectedGroup : GroupModel = GroupModel()
    @State var openGroupProfile : Bool = false
    @EnvironmentObject var userVM : UserViewModel
    
    var body: some View {
        
        ZStack{
            Color("Background")
            ScrollView(){
                if !searchVM.searchText.isEmpty && searchVM.userReturnedResults.isEmpty{
                    Text("There are no user results for \(searchVM.searchText)")
                }
                VStack(alignment: .leading){
                  
                
                    
                    VStack(alignment: .leading, spacing: 0){
                        if !searchVM.searchText.isEmpty && !searchVM.userReturnedResults.isEmpty{
                            Text("Users").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                        }
                        ForEach(searchVM.userReturnedResults, id: \.id){ user in
                            
                          
                                NavigationLink {
                                   
                                        UserProfilePage(user: user)
                                    
                                } label: {
                                    UserSearchCell(user: user, showActivity: false)
                                }
                            
                            
                              

                             
                            

                         
                        }
                    }
               
                    

                }
                
                
            }.padding(.top,10)
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
      
    }
}


struct TopResults : View {
    @ObservedObject var searchVM: SearchRepository
    @State var selectedGroup : GroupModel = GroupModel()
    @State var openGroupProfile : Bool = false
    @EnvironmentObject var userVM : UserViewModel
    
    var body: some View {
        
        ZStack{
            Color("Background")
            ScrollView(){
                if !searchVM.searchText.isEmpty && searchVM.groupReturnedResults.isEmpty && searchVM.userReturnedResults.isEmpty && searchVM.userFriendsReturnedResults.isEmpty{
                    Text("There are no results for \(searchVM.searchText)")
                }
                VStack(alignment: .leading){
                  
                    
                    VStack(alignment: .leading, spacing: 2){
                        if !searchVM.searchText.isEmpty && !searchVM.groupReturnedResults.isEmpty{
                            Text("Groups").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                        }
                        VStack{
                            ForEach(searchVM.groupReturnedResults, id: \.id){ group in
                                    NavigationLink {
                                        GroupProfileView(group: selectedGroup, isInGroup: selectedGroup.usersID.contains(userVM.user?.id ?? " "))
                                    } label: {
                                        GroupSearchCell(group: group)
                                    }

                                 
                                

                             
                            }
                        }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        if !searchVM.searchText.isEmpty && !searchVM.userReturnedResults.isEmpty{
                            Text("Users").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                        }
                        ForEach(searchVM.userReturnedResults, id: \.id){ user in
                            

                                NavigationLink {
                                   
                                        UserProfilePage(user: user)
                                    
                                } label: {
                                    UserSearchCell(user: user, showActivity: false)
                                }

                            
                            

                         
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 0){
                        if !searchVM.searchText.isEmpty && !searchVM.userFriendsReturnedResults.isEmpty{
                            Text("Friends").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                        }
                        ForEach(searchVM.userFriendsReturnedResults, id: \.id){ user in
                                NavigationLink {
                                
                                        UserProfilePage(user: user)
                                    
                                } label: {
                                    UserSearchCell(user: user, showActivity: false)
                                }

                             
                            

                         
                        }
                    }
                    

                }
                
                
            }.padding(.top,10)
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
      
    }
}

