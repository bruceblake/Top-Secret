//
//  GroupView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct GroupView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var tabVM : TabViewModel
    @StateObject var chatVM  = ChatViewModel()
    @StateObject var messageVM = MessageViewModel()
    @StateObject var groupVM = GroupViewModel()
    @ObservedObject var notificationRepository = NotificationRepository()

    
    @State var selectedIndex = 0
    @State private var options = ["Groups","Friends"]
    @State var showCreateGroupView : Bool = false
    private let gridItems = [GridItem(.flexible())]

    
 
    
    var body: some View {
        
      
        ZStack{
            
            Color("Background")
            
            VStack{
            VStack{
                VStack{
                    HStack{
                        Button(action:{
                            //TODO
                            userVM.fetchUserChats()
                        },label:{
                            Image(systemName: "gear").resizable().frame(width: 32, height:32).accentColor(Color("AccentColor"))
                        }).padding(.leading,20)
                        Spacer()
                        
                        Text("Groups").font(.largeTitle).fontWeight(.bold)
                        
                        Spacer()
                        
                        Button(action: {
                            showCreateGroupView.toggle()
                        }, label: {
                            ZStack{
                                Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                                Image(systemName: "person.3.fill")
                                    .resizable()
                                    .frame(width: 24, height: 16).foregroundColor(Color("Foreground"))
                                
                            }
                            
                            
                            
                        }).padding(.trailing)            .sheet(isPresented: $showCreateGroupView, content: {
                            CreateGroupView(goBack: $showCreateGroupView)
                        })
                       
                        
                    }.foregroundColor(FOREGROUNDCOLOR)
                }.padding(.top,50)
                
            }
            VStack{
                
          
                    
                    
                    
                    
                    //List of groups
                        ScrollView {
                            if !userVM.groups.isEmpty{
                                LazyVGrid(columns: gridItems, spacing: 20) {
                                    ForEach(userVM.groups) { group in
                                        
                                        
                                        NavigationLink(
                                            destination: GroupHomeScreenView(group: group),
                                            label: {
                                                ZStack{
                                                    
                                                    HomescreenGroupCell(group: group)

                                                    VStack{
                                                    HStack{
                                                        Spacer()
                                                        if notificationRepository.getGroupNotificationCount(group: group, maps: userVM.groupNotificationCount) != 0{
                                                            
                                                            ZStack{
                                                                Circle().foregroundColor(Color("AccentColor"))
                                                                Text("\(notificationRepository.getGroupNotificationCount(group: group, maps: userVM.groupNotificationCount))").foregroundColor(.yellow).font(.footnote)
                                                            }.frame(width: 25, height: 25).offset(y: -10)
                                                            
                                                        }
                                                    }.padding(.bottom)
                                                        Spacer()
                                                }
                                                
                                                    
                                                }
                                                
                                            }).isDetailLink(false)
                                        
                                        
                                    }
                                    
                                }.padding(.top,10)
                            }else{
                                Text("You are not in any groups!")
                            }
                        }.padding(.horizontal)
                    
                    
                    
                    
                   
                }
                .padding(.top)
            }
            
          
               

            
            }.frame(width: UIScreen.main.bounds.width).edgesIgnoringSafeArea(.all).navigationBarHidden(true)
            
        }
       
            
        }
        
        
        
    



//struct MessageListView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageListView().preferredColorScheme(.dark)
//    }
//}


struct OpenMessageView : View {
    
    
    var body: some View {
        ZStack{
            Color("Background")
            
            Text("Messages").font(.title).fontWeight(.bold).foregroundColor(Color("AccentColor"))
        }
    }
}
