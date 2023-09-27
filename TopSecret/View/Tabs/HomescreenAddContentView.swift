//
//  HomescreenAddContentView.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/9/22.
//

import SwiftUI
import SDWebImageSwiftUI
struct HomescreenAddContentView: View {
    
    var texts : [String] = ["Create a Group","Create Poll","Create Event"]
    @EnvironmentObject var userVM: UserViewModel
    @State var showAddEventView : Bool = false
    @State var showCreateGroupView: Bool = false
    
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
                    
                    
                    Button(action:{
                        self.showCreateGroupView.toggle()
                    },label:{
                        VStack(spacing: 10){
                            
                            HStack(alignment: .center, spacing: 20){
                                Image(systemName: "person.3.fill").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                Text("Create a Group").foregroundColor(FOREGROUNDCOLOR)
                                
                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                            Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(Color.gray)
                            
                            
                        }.padding(.vertical,10).frame(width: UIScreen.main.bounds.width).padding(.leading,30)
                    })
                    
                    
                    
                    
                    NavigationLink(destination:  AddGroupsToEventView(showAddEventView: $showAddEventView, showCreateGroupView: $showCreateGroupView), isActive: $showAddEventView) {
                        VStack(spacing: 10){
                            
                            HStack(alignment: .center, spacing: 20){
                                Image(systemName: "party.popper.fill").foregroundColor(FOREGROUNDCOLOR).frame(width: 15, height: 15)
                                Text("Create a Event").foregroundColor(FOREGROUNDCOLOR)
                                
                                Spacer()
                            }.foregroundColor(FOREGROUNDCOLOR)
                            Rectangle().frame(width: UIScreen.main.bounds.width, height: 1).foregroundColor(Color.gray)
                            
                        }.padding(.vertical,10).frame(width: UIScreen.main.bounds.width).padding(.leading,30)
                    }
  
                }
                
                
                
                
            }
            
            NavigationLink(destination:                             CreateGroupView(showCreateGroupView: $showCreateGroupView)
                           , isActive: $showCreateGroupView) {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).resizeToScreenSize()
    }
}

struct AddGroupsToEventView : View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var openCreateEventView: Bool = false
    @State var selectedGroups: [GroupModel] = []
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var searchVM = SearchRepository()
    @Binding var showAddEventView : Bool
    @Binding var showCreateGroupView: Bool
    
    var groupsToShow: [GroupModel] {
        if searchVM.searchText == ""{
            return userVM.groups
        }else{
            return searchVM.userGroupReturnedResults
        }
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Select a Group").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                    Spacer()
                    
                    Button {
                        self.openCreateEventView.toggle()
                    } label: {
                        Text("Skip")
                    }
                    
                }.padding(.top,50).padding(.horizontal)
                
                SearchBar(text: $searchVM.searchText, placeholder: "your groups..", onSubmit: {}).padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(selectedGroups){ group in
                            HStack{
                                Text("\(group.groupName)")
                                Button(action:{
                                    selectedGroups.removeAll(where: {$0.id == group.id})
                                },label:{
                                    Image(systemName: "x.circle.fill")
                                }).foregroundColor(FOREGROUNDCOLOR)
                            }.padding(10).background(RoundedRectangle(cornerRadius: 15).fill(Color("AccentColor")))
                        }
                    }
                }.padding(.horizontal)
                
                VStack(){
                    ScrollView{
                        
                        NavigationLink(destination: CreateGroupView(showCreateGroupView: $showCreateGroupView)) {
                            HStack{
                                ZStack{
                                    Circle().frame(width: 48, height: 48).foregroundColor(Color("Color"))
                                    Image(systemName: "person.3.fill").font(.system(size: 18)).foregroundColor(FOREGROUNDCOLOR)
                                }
                                Text("Create a new Group").foregroundColor(FOREGROUNDCOLOR)
                                
                                Spacer()
                            }.padding(.vertical,10)
                        }
                        
                        
                        Divider()
                        ForEach(groupsToShow, id: \.id) { group in
                            Button {
                                if selectedGroups.contains(where: {$0.id == group.id}){
                                    selectedGroups.removeAll(where: {$0.id == group.id})
                                }else{
                                    selectedGroups.append(group)
                                }
                            } label: {
                                HStack(alignment: .center){
                                    WebImage(url: URL(string: group.groupProfileImage))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:48,height:48)
                                        .clipShape(Circle())
                                    
                                    
                                    VStack(alignment: .leading){
                                        
                                        Text("\(group.groupName)").foregroundColor(Color("Foreground"))
                                        Text("\(group.users.count) \(group.users.count > 1 ? "members" : "member")").foregroundColor(.gray)
                                        
                                        
                                    }
                                    Spacer()
                                    
                                    Image(systemName: selectedGroups.contains(where: {$0.id == group.id}) ? "checkmark.circle.fill" : "circle").font(.title).foregroundColor(FOREGROUNDCOLOR)
                                    
                                }
                            }
                            
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                }.padding(10)
                
                Button(action:{
                    openCreateEventView.toggle()
                },label:{
                    Text("Add Groups").foregroundColor(FOREGROUNDCOLOR)
                        .frame(width: UIScreen.main.bounds.width/1.5).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(selectedGroups.count > 0 ? Color("AccentColor") : Color("Color")))
                }).disabled(selectedGroups.count == 0).padding(.bottom,30)
                
                Spacer()
                
            }
            
            
            //nav link
            NavigationLink(destination:  CreateEventView(selectedGroups: selectedGroups, isGroup: false, showAddEventView: $showAddEventView)
                           , isActive: $openCreateEventView) {
                EmptyView()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUserGroups", id: userVM.user?.id ?? " ")
        }
    }
}


