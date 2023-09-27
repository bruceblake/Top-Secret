//
//  CreateGroupPostView.swift
//  Top Secret
//
//  Created by Bruce Blake on 9/6/22.
//

import SwiftUI

struct CreateGroupPostView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var createPostVM = CreateGroupPostViewModel()
    var group: GroupModel = GroupModel()
    @EnvironmentObject var userVM: UserViewModel
    @State var openImagePicker: Bool = false
    @State var post = UIImage(named: "topbarlogo")!
    @State var showOverlay : Bool = false
    @State var showTaggedUsersView: Bool = false
    @State var selectedUsers: [User] = []
    @State var description : String = ""
    @State var selectedGroups: [GroupModel] = []
    
    func makeSelection(groups: [GroupModel], selectedGroup: GroupModel) -> [GroupModel]{
        var groupsToReturn = groups
        if groups.contains(where: {$0.id == selectedGroup.id}){
            groupsToReturn.removeAll(where: {$0.id == selectedGroup.id})
        }else{
            groupsToReturn.append(selectedGroup)
        }
        return groupsToReturn
    }
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                //top bar
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Create Post").font(.headline).bold()
                    
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)

                }.padding(.top,50).padding(.horizontal,10)
                
                
//                Button(action:{
//                    self.showTaggedUsersView.toggle()
//                },label:{
//
//                Text("Add Tagged Users")
//                }).fullScreenCover(isPresented: $showTaggedUsersView) {
//
//                } content: {
//                    VStack{
//                        ForEach(userVM.user?.friendsList ?? [], id: \.id){ friend in
//
//                            Button(action:{
//                                self.selectedUsers.append(friend)
//                            },label:{
//                                UserSearchCell(user: friend, showActivity: false)
//                            })
//                        }
//                        ScrollView(.horizontal){
//                            HStack{
//                                ForEach(selectedUsers){ user in
//                                    Button(action:{
//                                        self.selectedUsers.removeAll { removedUser in
//                                            user.id == removedUser.id
//                                        }
//                                    },label:{
//                                    Text("\(user.nickName ?? " ")")
//                                    })
//                                }
//                            }
//                        }
//                    }
//                }

                
                VStack{
                    Button(action:{
                        self.openImagePicker.toggle()
                    },label:{
                        Image(uiImage: post)
                            .resizable()
                            .scaledToFit().frame(width: UIScreen.main.bounds.width - 20).cornerRadius(12)
                    }).fullScreenCover(isPresented: $openImagePicker, content: {
                        ImagePicker(avatarImage: $post, allowsEditing: true)
                    })
                    
                    VStack{
                        HStack{
                            Text("Write a description").padding(.leading,10)
                            Spacer()
                        }
                   
                        TextField("description", text: $description).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).padding(.horizontal,10)
                        
                    }
                    
                    ScrollView{
                        HStack{
                            ForEach(selectedGroups){ group in
                                Button(action:{
                                    self.makeSelection(groups: selectedGroups, selectedGroup: group)
                                },label:{
                                    Text("\(group.groupName)")
                                })
                            }
                        }
                    }
                }
               
                
                Spacer()
                Button(action:{
                    createPostVM.createPost(image: post, userID: userVM.user?.id ?? " ", group: group, description: description)
                },label:{
                    Text(createPostVM.uploadStatus == .startedUpload ? "Uploading Post" : "Create Post").foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding(.bottom,30).disabled(createPostVM.uploadStatus == .startedUpload)
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onReceive(createPostVM.$uploadStatus) { uploadStatus in
            if uploadStatus == .finishedUpload{
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
}
