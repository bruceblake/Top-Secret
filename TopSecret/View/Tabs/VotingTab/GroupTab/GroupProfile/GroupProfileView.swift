//
//  GroupProfileView.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/26/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupProfileView: View {
    
    var group : GroupModel
    var isInGroup : Bool
    @EnvironmentObject var userVM : UserViewModel
    @StateObject var groupProfileVM = GroupProfileViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State var selectedView = 0
    var options = ["Posts","Polls","Achievments","About Us"]
    let columns : [GridItem] = [
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0),
        GridItem(.flexible(), spacing: 0)
        
        
    ]
    
    
    
    var body: some View {
        
        ZStack{
            Color("Background")
            VStack{
                HStack(alignment: .top){
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    
                    
                    Text("\(group.groupName)").foregroundColor(FOREGROUNDCOLOR).font(.title3).bold()
                    Spacer()
                    
                    if isInGroup {
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "gear").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                    }else{
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                    }
                    
                }.padding(.top,50).padding(.horizontal)
                ScrollView{
                    
                
                    VStack(spacing: 0){
                    HStack{
                        
                        
                        WebImage(url: URL(string: group.groupProfileImage))
                            .resizable()
                            .scaledToFill()
                            .frame(width:80,height:80)
                            .clipShape(Circle())
                        
                        HStack(alignment: .center){
                            HStack{
                                
                                Spacer()
                                
                                VStack(spacing: 3){
                                    Text("\(groupProfileVM.posts.count)").foregroundColor(FOREGROUNDCOLOR).bold().font(.system(size: 20))
                                    Text("Posts").foregroundColor(Color.gray).font(.system(size: 16))
                                }
                                
                                Spacer()
                            }
                            HStack{
                                Divider().frame(width: 2, height: 30)
                                
                                Spacer()
                                VStack(spacing: 3){
                                    Text("\(group.users.count)").foregroundColor(FOREGROUNDCOLOR).bold().font(.system(size: 20))
                                    Text("Members").foregroundColor(Color.gray).font(.system(size: 16))
                                }
                                Spacer()
                                
                                Divider().frame(width: 2, height: 30)
                            }
                            
                            
                            HStack{
                                Divider().frame(width: 2, height: 30)
                                Spacer()
                                VStack(spacing: 3){
                                    Text("\(group.followersID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).bold().font(.system(size: 20))
                                    Text("Followers").foregroundColor(Color.gray).font(.system(size: 16))
                                }
                                
                                Spacer()
                            }
                            
                        }
                    }.padding(.horizontal)
                    
                    if isInGroup{
                        
                        Text("In Group").foregroundColor(Color.gray).font(.body)
                    }else{
                        
                        if group.followersID?.contains(userVM.user?.id ?? " ") ?? false{
                            Button(action:{
                                userVM.unfollowGroup(groupID: group.id, userID: userVM.user?.id ?? " ")
                            },label:{
                                Text("Unfollow").padding(10).foregroundColor(FOREGROUNDCOLOR).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                            }).padding(10)
                        }else{
                            Button(action:{
                                userVM.followGroup(groupID: group.id, userID: userVM.user?.id ?? " ")
                                
                            },label:{
                                Text("Follow").padding(10).foregroundColor(FOREGROUNDCOLOR).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                            }).padding(10)
                        }
                        
                        
                    }
                    Text("\(group.bio)").font(.body).foregroundColor(FOREGROUNDCOLOR)
                    
                }
                
                VStack{
                    ScrollView(.horizontal){
                        HStack(spacing: 30){
                            ForEach(0..<options.count){ i in
                                Button(action:{
                                    selectedView = i
                                },label:{
                                    Text(options[i]).foregroundColor(selectedView == i ? Color("AccentColor") : FOREGROUNDCOLOR).font(.system(size: 18))
                                })
                            }
                            
                        }
                    }.padding(.horizontal)
                  
                    switch selectedView{
                    case 0:
                        LazyVGrid(columns: columns, spacing: 1) {
                            ForEach(groupProfileVM.posts, id: \.id){ post in
                                Button(action:{
                                    
                                },label:{
                                    
                                    Image(uiImage: post.image ?? UIImage(named: "Icon")!)
                                        .resizable()
                                        .frame(width: UIScreen.main.bounds.width/3, height: 150)
                                        .aspectRatio(contentMode: .fit)
                                        .overlay(Rectangle().stroke(Color("Background"), lineWidth: 2))
                                })
                                
                                
                            }
                        }
                        
                    case 1:
                        Text("Hello World")
                    case 2:
                        Text("Hello World")
                    case 3:
                        Text("Hello World")
                    default:
                        Text("Hello World")
                    }
                    
                }
                
            }
                
            }
        
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            groupProfileVM.fetchPosts(userID: userVM.user?.id ?? " ", groupID: group.id)
        }
        
        
    }
}



