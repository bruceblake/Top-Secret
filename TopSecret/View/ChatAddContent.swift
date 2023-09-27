//
//  ChatAddContent.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/22/23.
//

import SwiftUI

struct ChatAddContent: View {
    @Binding var showAddContentView: Bool
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    @Binding var showAddEventView: Bool
    var texts : [String] = ["Create Poll","Create Event","Send Group Invitation to Friend"]
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

                    Button {
                        //todo
                    } label: {
                        VStack(spacing: 10){
                        
                            HStack(alignment: .center, spacing: 20){
                                Image(systemName: "mappin").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                Text("Send your current location").foregroundColor(FOREGROUNDCOLOR)

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

