//
//  AddFriendsToEventView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/10/22.
//

import SwiftUI

struct AddFriendsToEventView: View {
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var searchVM = SearchRepository()
    @Binding var isOpen : Bool
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        self.isOpen.toggle()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,10)
                    
                    SearchBar(text: $searchVM.searchText, placeholder: "Invite Friends", onSubmit: {})
                    
                }.padding(.top,50)
                
                ScrollView(){
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            if !searchVM.searchText.isEmpty{
                                Text("Friends").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                            }
                            VStack{
                                ForEach(searchVM.userFriendsReturnedResults, id: \.id) { user in
                                    NavigationLink{
                                       
                                            UserProfilePage(user: user)
                                        
                                    }
                                        label: {
                                            UserSearchCell(user: user, showActivity: true)
                                        }
                                    
                                }
                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                        }
                    }
                }
             
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsersFriends", id: "\(userVM.user?.id ?? " ")")
        }
    }
    
}

