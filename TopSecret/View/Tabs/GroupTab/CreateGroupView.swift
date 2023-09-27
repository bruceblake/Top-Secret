//
//  CreateGroupView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct CreateGroupView: View {
    
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var searchVM = SearchRepository()
    @Environment(\.presentationMode) var presentationMode
    @State var isShowingPhotoPicker:Bool = false
    @State var avatarImage = UIImage(named: "AppIcon")!
    @State var pickedAnImage: Bool = false
    @State var groupName : String = ""
    @State var openInviteFriendsView: Bool = false
    @State var selectedUsers: [User] = []
    @Binding var showCreateGroupView: Bool
    var body: some View {
        ZStack(alignment: .topLeading){
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
                    }).padding(.leading)
                    
                    Spacer()
                    
                    Text("Create A Group").fontWeight(.bold).font(.title2).padding(.trailing,10)
                    
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)

                }.padding(.top,50).padding(.bottom,50)
                
                
                
               
            
                ScrollView{
                    VStack(spacing: 30){
                        
                        
                        
                        //group pfp
                        
                        HStack{
                            
                            Spacer()
                            
                            
                            ZStack(alignment: .bottomTrailing){
                                if pickedAnImage{
                                    Image(uiImage: avatarImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:UIScreen.main.bounds.width/1.5,height:220)
                                        .cornerRadius(12)
                                    
                                    Button(action:{
                                        isShowingPhotoPicker.toggle()
                                        
                                    }, label:{
                                        ZStack{
                                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                            Image(systemName: "photo").foregroundColor(FOREGROUNDCOLOR)
                                        }.offset(x: 5, y: 10)
                                    })
                                }else{
                                    Button(action:{
                                        isShowingPhotoPicker.toggle()
                                        
                                    },label:{
                                        ZStack{
                                            Circle().strokeBorder(FOREGROUNDCOLOR, lineWidth: 3).frame(width: 150, height: 150)
                                            
                                            Image(systemName: "person")
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .foregroundColor(FOREGROUNDCOLOR)
                                        }
                                        
                                    })
                                    
                                }
                                
                                
                                
                            }
                            
                            .fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                                ImagePicker(avatarImage: $avatarImage, allowsEditing: true)
                            })
                            
                            Spacer()
                        }
                        
                        
                        VStack{
                            
                            TextField("",text: $groupName).multilineTextAlignment(.center).font(.system(size: 25, weight: .bold))
                            Rectangle().frame(width: UIScreen.main.bounds.width-50, height: 2).foregroundColor(Color.gray)
                            Text("Enter a name for your new group!").foregroundColor(Color.gray).font(.subheadline)
                        }.padding()
                        
                        
                        
                        Spacer()
                        
                        
                        //                    VStack(alignment: .leading){
                        //                        Text("Selected Users").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        //                        ScrollView(.horizontal){
                        //                            HStack{
                        //                                ForEach(selectedUsers, id: \.id){ user in
                        //                                    if user.id == userVM.user?.id ?? "" {
                        //                                        Text("YOU").padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        //                                    }else{
                        //                                        Button(action:{
                        //                                            searchVM.searchText = user.nickName ?? ""
                        //                                        },label:{
                        //                                    Text(user.nickName ?? "").padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                        //                                        })
                        //                                    }
                        //                                }
                        //                            }
                        //                        }
                        //                    }.padding(.horizontal)
                        
                    }
                }
             
                

            Button(action:{
                self.openInviteFriendsView.toggle()
            },label:{
                HStack{
                    Spacer()
                    Text("Add Friends").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(Color("AccentColor")).font(.title)
                }
                .frame(width: UIScreen.main.bounds.width/1.5).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Color")))
                    
            }).padding(.vertical,10).padding(.bottom,30).disabled(groupName == "")
            

            Spacer()
        
            }
            
            NavigationLink(destination: InviteFriendsToGroupView(selectedUsers: $selectedUsers, avatarImage: $avatarImage, openInviteFriendsView: $openInviteFriendsView, groupName: $groupName, showCreateGroupView: $showCreateGroupView), isActive: $openInviteFriendsView) {
                EmptyView()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onChange(of: avatarImage) { newValue in
            self.pickedAnImage = true
        }.onAppear{
            self.selectedUsers.append(userVM.user ?? User())
        }
}
}



struct InviteFriendsToGroupView : View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var selectedUsers : [User]
    @StateObject var searchVM = SearchRepository()
    @Binding var avatarImage: UIImage
    @Binding var openInviteFriendsView: Bool
    @Binding var groupName: String
    @StateObject var groupVM = GroupViewModel()
    @Binding var showCreateGroupView: Bool
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack{
            Color("Color")
        VStack(spacing: 20){
            
            HStack{
                
                Button(action:{
                    self.openInviteFriendsView.toggle()
                },label:{
                    ZStack{
                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Background"))
                        Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                    }
                })
                SearchBar(text: $searchVM.searchText, placeholder: "search", onSubmit:{
                    searchVM.hasSearched = true
                }, backgroundColor: Color("Background"))
            }.padding(.top,50)
            
            
            VStack(alignment: .leading){
                Text("Selected Users").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                ScrollView(.horizontal){
                    HStack{
                        ForEach(selectedUsers, id: \.id){ user in
                            if user.id == userVM.user?.id ?? "" {
                                Text("YOU").padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background")))
                            }else{
                                Button(action:{
                                    searchVM.searchText = user.nickName ?? ""
                                },label:{
                                    Text(user.nickName ?? "").foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                                })
                            }
                        }
                    }
                }
            }.padding(.top)
            
                ScrollView(){
                    VStack(spacing: 10){
                        
                        
                           
                            VStack(alignment: .leading){
                                if !(userVM.user?.friendsList ?? []).isEmpty{
                                    VStack(alignment: .leading){
                                        Text("Friends").fontWeight(.bold).foregroundColor(Color("Foreground"))
                                    }
                                }
                            ForEach(userVM.user?.friendsList ?? [], id: \.id){ friend in
                                Button(action:{
                                    if selectedUsers.contains(friend){
                                        selectedUsers.removeAll { user in
                                            user.id == friend.id ?? ""
                                        }
                                    }else{
                                    selectedUsers.append(friend)
                                    }
                                },label:{
                                HStack{
                                    
                                    WebImage(url: URL(string: friend.profilePicture ?? ""))
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width:40,height:40)
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading){
                                        Text("\(friend.nickName ?? "")").font(.body).bold().foregroundColor(FOREGROUNDCOLOR)
                                        Text("@\(friend.username ?? "")").font(.footnote).foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    Circle().frame(width: 20, height: 20).foregroundColor(selectedUsers.contains(friend) ? Color("AccentColor") : FOREGROUNDCOLOR)
                                    
                               
                                }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background")))
                                })
                            
                                
                            }
                                
                                
                                
                                
                                
                            }

                    }
                        
                    
                }.gesture(DragGesture().onChanged { _ in
                    UIApplication.shared.keyWindow?.endEditing(true)
                })
            
         Spacer()
            
            Button(action:{
                let groupID = UUID().uuidString
                groupVM.createGroup(groupName: groupName, dateCreated: Date(), users: selectedUsers.map({ user in
                    return user.id ?? ""
                }) ,image: avatarImage, groupID: groupID)
                self.showCreateGroupView = false
            },label:{
                Text("Create Group").foregroundColor(FOREGROUNDCOLOR)
                .frame(width: UIScreen.main.bounds.width/1.5).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                    
            }).padding(.vertical,10).padding(.bottom,30)
           
          
        }.padding()
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsersFriends", id: userVM.user?.id ?? " ")
        }
    }
}
