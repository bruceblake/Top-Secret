//
//  GroupsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/2/22.
//

import SwiftUI

struct GroupsView: View {
    @State var openGroupHomescreen : Bool = false
    @EnvironmentObject var userVM: UserViewModel
    @State var selectedGroup : GroupModel = GroupModel()
    @State var users: [User] = []
    @State var showCreateGroupView: Bool = false
    
    var body: some View {
        
        ZStack{
            
            
            if userVM.groups.isEmpty{
                
                VStack{
                    Spacer()
                    VStack{
                        Text("You are in 0 groups :(").foregroundColor(Color.gray)
                        Button {
                            self.showCreateGroupView = true
                        } label: {
                            Text("Create A Group").foregroundColor(Color("Foreground"))
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width/2.5).background(Color("AccentColor")).cornerRadius(15)
                        }
                        
                    }
                    Spacer()
                }
                
                
            }else{
                ShowGroups(selectedGroup: $selectedGroup, users: $users, openGroupHomescreen: $openGroupHomescreen)
            }
            
            NavigationLink(destination: HomeScreenView(chatID: selectedGroup.chatID ?? " ", groupID: selectedGroup.id), isActive: $openGroupHomescreen) {
                EmptyView()
            }.environment(\.modalMode, self.$openGroupHomescreen)
            
            NavigationLink(destination:                             CreateGroupView(showCreateGroupView: $showCreateGroupView)
                           , isActive: $showCreateGroupView) {
                EmptyView()
            }
        }
        
        
        
    }
}

