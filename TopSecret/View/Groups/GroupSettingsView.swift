//
//  GroupSettingsView.swift
//  TopSecret
//
//  Created by Bruce Blake on 12/16/21.
//

import SwiftUI

struct GroupSettingsView: View {
    @Environment(\.presentationMode) var dismiss
    @StateObject var groupVM = GroupViewModel()
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var navigationHelper : NavigationHelper
    var group: Group
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack(alignment: .center){
                    Button(action:{
                        dismiss.wrappedValue.dismiss()
                    },label:{
                        Text("<").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                    }).padding(.leading)
                    
                    Spacer()
                    
                    Text("Group Settings").fontWeight(.bold).font(.title)
                    
                    Spacer()
                }.padding(.top,50)
                
                ScrollView(){
                    VStack(alignment: .leading){
                        
                        VStack(alignment: .leading){
                            
                            Text("My Account").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
                            
                            VStack(alignment: .leading, spacing: 15){
                                SettingsButtonCell(text: "Blocked Accounts", includeDivider: true,  action:{
                                    //TODO
                                }).padding(.top,10)
                                SettingsButtonCell(text: "Color Preferences", includeDivider: true,  action:{
                                    //TODO
                                })
                                SettingsButtonCell(text: "Change Username", includeDivider: true,  action:{
                                    //TODO
                                })
                                
                                SettingsButtonCell(text: "Change Email", includeDivider: true,  action:{
                                    //TODO
                                })
                                
                                SettingsButtonCell(text: "Change Password", includeDivider: true,  action:{
                                    //TODO
                                })
                                SettingsButtonCell(text: "Two Factor Authentification", includeDivider: false,  action:{
                                    //TODO
                                }).padding(.bottom,15)
                                
                                
                                
                                
                            }.background(Color("Color")).cornerRadius(12).padding([.horizontal,.bottom])
                        }
                        
                    }
                    
                    
                    
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Support").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
                            
                            VStack{
                                SettingsButtonCell(text: "Contact Us", includeDivider: true,  action:{
                                    //TODO
                                }).padding(.top,10)
                                
                                SettingsButtonCell(text: "Contact Us", includeDivider: false,  action:{
                                    //TODO
                                })
                                .padding(.bottom,15)
                            }.background(Color("Color")).cornerRadius(12).padding([.horizontal,.bottom])
                        }
                        
                        
                        
                    }
                    
                    
                    
                    VStack(alignment: .leading){
                        VStack(alignment: .leading){
                            Text("Account Actions").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
                            
                            VStack{
                                SettingsButtonCell(text: "Switch Accounts", includeDivider: true,  action:{
                                    //TODO
                                }).padding(.top,10)
                                SettingsButtonCell(text: "Leave Group", includeDivider: false,  action:{
                                    
                                    self.navigationHelper.moveToDashboard = true
                                    groupVM.leaveGroup(groupID: group.id, userID: userVM.user?.id ?? "")
                                    
                                    
                                }).padding(.bottom,15)
                                
                            }.background(Color("Color")).cornerRadius(12).padding([.horizontal,.bottom])
                        }
                        
                        
                        
                    }
                    
                    
                }
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct GroupSettingsView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupSettingsView().colorScheme(.dark)
//    }
//}
