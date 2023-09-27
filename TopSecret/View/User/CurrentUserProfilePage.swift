//
//  UserProfilePage.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/3/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct CurrentUserProfilePage: View {
    
    @State var settingsOpen: Bool = false
    @State var showEditPage: Bool = false
    @State var isLoading: Bool = false
    @State var switchAccounts : Bool = false
    @State var selectedIndex : Int = 0
    @State var seeProfilePicture : Bool = false
    
    @StateObject var chatVM = ChatViewModel()
    @EnvironmentObject var userVM : UserViewModel
    
    @Environment(\.presentationMode) var presentationMode
    
    
    
    
    var body: some View {
        
        ZStack{
            Color("Background").zIndex(0)
                VStack{
                    HStack(alignment: .top){
                        
                            
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 35, height: 35).foregroundColor(Color("Color"))
                                Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                          
                        
                        Spacer()

                            
                            NavigationLink(destination:{
                               SettingsMenuView()
                            },label:{
                            ZStack{
                                Circle().frame(width: 35, height: 35).foregroundColor(Color("Color"))
                                Image(systemName: "gear").foregroundColor(FOREGROUNDCOLOR)
                            }
                            })
                        
                        
                        
                    }.padding(.top,60).padding(.horizontal).zIndex(1)

                    ScrollView{
                        
                        //pfp username nickname
                                
                             
                                
                                
                                VStack(alignment: .leading){
                                    
                                    Button(action:{
                                        self.seeProfilePicture.toggle()
                                    },label:{
                                        WebImage(url: URL(string: userVM.user?.profilePicture ?? ""))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width:60,height:60)
                                            .clipShape(Circle())
                                    }).fullScreenCover(isPresented: $seeProfilePicture) {
                                        
                                    } content: {
                                        WebImage(url: URL(string: userVM.user?.profilePicture ?? ""))
                                                .resizable().placeholder{
                                                    ProgressView()
                                                }
                                                .scaledToFit()
                                    .onTapGesture{
                                            self.seeProfilePicture.toggle()
                                        }
                                    }
                                    
                                    Text("\(userVM.user?.nickName ?? "") ").fontWeight(.bold).font(.headline).lineLimit(1).foregroundColor(FOREGROUNDCOLOR)
                                    
                                    
                                    Text("@\(userVM.user?.username ?? "")").font(.footnote).foregroundColor(.gray)
                                }
                                    
                                
                                
                                
                                
                            

                    
                    HStack{
      
                        Spacer()

                        Button(action:{
                            self.showEditPage.toggle()
                        },label:{
                            Text("Edit Profile").font(.body).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color"))).foregroundColor(FOREGROUNDCOLOR)
                        }).frame(maxWidth: .infinity)

                        Spacer()
    
                    }

                    //User Info
                    HStack(spacing: 25){
                        
                        
                        Spacer()
                        
                        NavigationLink(destination: UserGroupsListView(user: userVM.user ?? User())){
                            
                            VStack{
                                Text("\(userVM.groups.count)").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                Text("Groups").font(.callout).foregroundColor(.gray)
                            }
                        }
                        
                        
                        
                        Spacer()
                        
                        NavigationLink(destination: UserFriendsListView(user: userVM.user ?? User())) {
                            VStack{
                                Text("\(userVM.user?.friendsList?.count ?? 0)").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                Text("Friends").font(.callout).foregroundColor(.gray)
                            }
                        }
                        
                        
                        
                        
                        Spacer()
                        
                        
                    }.padding(.vertical)
                    
                        
                        Text("\(userVM.user?.bio ?? "")").frame(width: UIScreen.main.bounds.width - 20).multilineTextAlignment(.center)
                        
                        
                        
                        
                        
                    Text("You joined Top Secret on \(userVM.user?.dateCreated?.dateValue() ?? Date(), style: .date)").font(.footnote).foregroundColor(.gray).padding()
                        
                    }.zIndex(2)
            
                    
                    
                }.zIndex(3).opacity(switchAccounts ? 0.2 : 1)
            
            
            ZStack{
                Color.clear
            }.zIndex(4).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height).onTapGesture {
                
                userVM.hideTabButtons.toggle()
                switchAccounts.toggle()
                
            }
            
            
            
            
            
            
            
            BottomSheetView(isOpen: $switchAccounts, maxHeight: UIScreen.main.bounds.height * 0.40) {
                SwitchAccountsView()
            }.zIndex(5)
            
            NavigationLink(destination:  UserEditProfilePageView(showEditPage: $showEditPage), isActive: $showEditPage) {
                EmptyView()
            }

        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        
        
    }
}



