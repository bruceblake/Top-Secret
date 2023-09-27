//
//  AddContentView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/21/22.
//

import SwiftUI

struct AddContentView: View {
    
    @Binding var showAddContentView: Bool
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    
    var texts : [String] = ["Create Poll","Create Event","Send Group Invitation to Friend"]
    @State var showAddEventView : Bool = false
    
    var body: some View {
        ZStack(alignment: .top){
            Color("Color")
            VStack{
                HStack{
                    Spacer()
                    Text("Create").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                    Spacer()
                }
                VStack(alignment: .leading){
                    
                        
                      
                        NavigationLink {
                           InviteUserToGroup()
                        } label: {
                            VStack(spacing: 10){
                           
                                HStack(alignment: .center, spacing: 20){
                                Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                    Text("Invite Friends").foregroundColor(FOREGROUNDCOLOR)
                                
                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                                
                                Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(Color("Background"))

                            
                        }.padding(.bottom,5).frame(width: UIScreen.main.bounds.width).padding(.leading,30)
                            
                        }
                  
                    
                   
                    NavigationLink(destination: CreateEventView(selectedGroups: [selectedGroupVM.group], isGroup: true, showAddEventView: $showAddEventView), isActive: $showAddEventView) {
                        VStack(spacing: 10){
                       
                            HStack(alignment: .center, spacing: 20){
                                Image(systemName: "party.popper.fill").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                    Text("Create a Event").foregroundColor(FOREGROUNDCOLOR)
                                
                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                            Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(Color("Background"))

                        }.padding(.vertical,10).frame(width: UIScreen.main.bounds.width).padding(.leading,30)
                    }
                  
                    
                    
                    NavigationLink {
                        CreatePollView()
                    } label: {
                        
                        VStack(spacing: 10){
                        
                            HStack(alignment: .center, spacing: 20){
                                Image(systemName: "questionmark.bubble.fill").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                Text("Create a Poll").foregroundColor(FOREGROUNDCOLOR)

                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                            
                            Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(Color("Background"))
                        }.padding(.top,10).frame(maxWidth: UIScreen.main.bounds.width).padding(.leading,30)
                    }

                    
                    
                }
             
            
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
}



