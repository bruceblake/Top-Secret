//
//  GroupProfileView.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/26/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupProfileView: View {
    
    var group: Group
    @EnvironmentObject var userVM : UserViewModel
    @ObservedObject var groupVM = GroupViewModel()
    @Environment(\.presentationMode) var dismiss

    
    
    @State var selectedIndex = 0
    @State var isFollowing = false
    @State var isInGroup = false
    @State private var options = ["Gallery","Polls","Achievements","Plans"]
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(){
                    Button(action:{
                        dismiss.wrappedValue.dismiss()
                    },label:{
                        Text("<")
                    }).padding(.leading)
                   
                    VStack{
                        WebImage(url: URL(string: group.groupProfileImage ?? ""))
                            .resizable()
                            .scaledToFill()
                            .frame(width:45,height:45)
                            .clipShape(Circle())
                            .padding()
                    Text("\(group.groupName)'s Profile").fontWeight(.bold).font(.headline)
                        
                        
                        if isInGroup{
                            Text("In Group!")
                        }else{
                            
                            if !isFollowing{
                                Button(action:{
                                    userVM.followGroup(group: group, user: userVM.user ?? User())
                                },label:{
                                    Text("Follow Group")
                                })
                                
                            }else{
                                HStack{
                                    Text("Following")
                                    
                                    Button(action:{
                                        userVM.unFollowGroup(group: group, user: userVM.user ?? User())
                                    },label:{
                                        Text("Unfollow!")
                                    })
                                }
                            }
                        }
                        
                        
                        
                       
                        
                    }
                    
                    
                  
                    NavigationLink(destination: GroupSettingsView(group: group)){
                        Image(systemName: "gear")
                    }.padding(.trailing)
                  
                    
          
                }.padding(.top,50).padding(.bottom,20)
                //GALLERY
                //POLLS
                //ACHIEVEMENTS
                //PLANS
                Picker("Options",selection: $selectedIndex){
                    ForEach(0..<options.count){ index in
                        Text(self.options[index]).tag(index)
                    }
                }.pickerStyle(SegmentedPickerStyle()).padding(10)
                if selectedIndex == 0{
                    GroupGalleryView(group: group)
                }else if selectedIndex == 1{
                    Text("Hello World 1")
                }else if selectedIndex == 2{
                    Text("Hello World 2")
                }else{
                    Text("Hello World 3")
                }
            
                Spacer()
            }
            
           
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            
            groupVM.isInGroup(user1: userVM.user ?? User(), group: group) { userIsInGroup in
                self.isInGroup = userIsInGroup
            }
            
            
            userVM.isFollowingGroup(user: userVM.user ?? User(), group: group) { isFollowingGroup in
                self.isFollowing = isFollowingGroup
            }
        }.onReceive(userVM.$user) { user in
            groupVM.isInGroup(user1: userVM.user ?? User(), group: group) { userIsInGroup in
                self.isInGroup = userIsInGroup
                print("1")
            }
            
            
            userVM.isFollowingGroup(user: userVM.user ?? User(), group: group) { isFollowingGroup in
                self.isFollowing = isFollowingGroup
                print("2")
        }
    }
    }
}

//struct GroupProfileView_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupProfileView(group: Group()).colorScheme(.dark)
//    }
//}
