//
//  TopBar.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/14/22.
//

import SDWebImageSwiftUI
import SwiftUI


struct TopBar : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var user : User = User()
    @State var selectedColorIndex : Int = 0
    @Binding var showSearch : Bool
    @EnvironmentObject var shareVM: ShareViewModel
    var tabIndex : Tab

    var body : some View {

        HStack(alignment: .top){
            
            HStack(alignment: .top, spacing: 5){
                
                
                
                NavigationLink(destination: CurrentUserProfilePage()) {
                    WebImage(url: URL(string: userVM.user?.profilePicture ?? " "))
                        .resizable()
                        .placeholder{
                            ProgressView()
                        }
                        .scaledToFill()
                        .frame(width:35,height:35)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("AccentColor"), lineWidth: 1))
                }
                
                NavigationLink(destination: AddFriendsView()) {
                     ZStack{
                         Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                         
                         
                             
                        
                         Image(systemName: "person.fill.badge.plus").foregroundColor(FOREGROUNDCOLOR).font(.title3)


                     }
                }

                
              
            }.padding(.leading)
            
            
          
            
            
            Spacer()
            
            if tabIndex == .calendar {
                Button {
                    print("user_id: \(USER_ID)")
                } label: {
                    Text("Calendar").bold().font(.title2).foregroundColor(FOREGROUNDCOLOR)
                }

            }
            else if tabIndex == .friends{
                Text("Friends").bold().font(.title2)
            }
            else if  tabIndex == .groups {
                Text("Groups").bold().font(.title2)
            }
            else if tabIndex == .notifications {
                Text("Notifications").bold().font(.title2)
            }
            else if tabIndex == .events {
                Text("Events").bold().font(.title2)
            }
            
          
            
            
            Spacer()
             
             
            HStack(alignment: .top){
                
                Button(action: {
                  //todo
                    userVM.hideTabButtons.toggle()
                    userVM.showAddContent.toggle()
                    userVM.hideBackground.toggle()
                 },label:{
                     
                     ZStack{
                         Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                         
                         
                             
                        
                         Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                         

                     }
       
                 })
                
                Button(action:{
                    withAnimation(.easeIn){
                        
                        showSearch.toggle()
                    }
                    
                },label:{
                    
                    ZStack{
                        Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                        
                        
                        Image(systemName: "magnifyingglass").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                        
                    }
                })
                
               
            }
            .padding(.trailing)
              
                
            
            
            
            
            
            
        }.frame(width: UIScreen.main.bounds.width).padding(.top,50).onChange(of: userVM.user ?? User()) { newValue in
            self.user = newValue
        }
    }
}
