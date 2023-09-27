//
//  BlockedAccountsView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/8/22.
//


import SDWebImageSwiftUI

import SwiftUI
import Firebase

struct BlockedAccountsView: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var openBlockedAccountsScreen : Bool
    @ObservedObject var settingsVM: UserSettingsViewModel
    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                HStack{
                  
                    Button(action:{
                        openBlockedAccountsScreen.toggle()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    
                    
                    Spacer()
                
                        
                    VStack{
                        Text("Blocked Accounts").fontWeight(.bold).font(.title)
                        Text("frick these people").foregroundColor(.gray).padding(.horizontal,10).font(.body)
                    }
                    
                    
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.leading,10)
                
                
               
           
                    
                ScrollView{
                    VStack{
                        ForEach(settingsVM.blockedAccounts, id: \.id){ blockedUser in
                            BlockedAccountsCell(user: blockedUser, settingsVM: settingsVM)
                            Divider()
                        }
                    }
                }
                
               Spacer()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
       
       
    }
}

struct BlockedAccountsCell : View {
    @State var user: User
    @EnvironmentObject  var userVM: UserViewModel
    @ObservedObject var settingsVM : UserSettingsViewModel
    var body: some View {
        HStack(){
            
            HStack(alignment: .top){
                WebImage(url: URL(string: user.profilePicture ?? " ")).resizable().frame(width: 40, height: 40).clipShape(Circle())
                VStack(alignment: .leading){
                    Text(user.nickName ?? " ")
                    Text("@\(user.username ?? " ")").foregroundColor(Color.gray)
                }
            }
            
            Spacer()
            
                Button(action:{
                    let dp = DispatchGroup()
                    dp.enter()
                    userVM.unblockUser(unblocker: userVM.user?.id ?? " ", blockee: user.id ?? " ")
                    dp.leave()
                    dp.notify(queue: .main, execute:{
                        settingsVM.fetchBlockedAccounts(blockedAccountIDS: userVM.user?.blockedAccountsID ?? [], completion: { fetched in
                           
                        })
                    })
                },label:{
                    if settingsVM.fetched {
                        Text("Unblock")
                    }else{
                        ProgressView()
                    }
                })
                
                
            
        }.padding(.horizontal)
    }
}


