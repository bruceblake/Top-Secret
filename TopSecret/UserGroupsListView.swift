//
//  UserGroupsListView.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/8/23.
//

import SwiftUI

struct UserGroupsListView: View {
    var user: User
    @State var groups : [GroupModel] = []
    @State var isLoading: Bool = false
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    
    func fetchGroups(){
        let dp = DispatchGroup()
        dp.enter()
        isLoading = true
        var groupsToReturn : [GroupModel] = []
        for groupID in user.groupsID ?? [] {
            dp.enter()
            COLLECTION_GROUP.document(groupID).getDocument { snapshot, err in
                if err != nil {
                    print("ERROR")
                    isLoading = false
                    return
                }
                
                let data = snapshot?.data() as? [String:Any] ?? [:]
                groupsToReturn.append(GroupModel(dictionary: data))
            }
            dp.leave()
        }
        dp.leave()
        dp.notify(queue: .main, execute: {
            isLoading = false
            self.groups = groupsToReturn
        })
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
                 
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                    
                }.padding(.top,50).padding(.horizontal)
                
                
                ScrollView{
                    VStack(alignment: .leading){
                        Text("Groups").font(.body).bold().padding([.leading,.top],10)
                        
                        if groups.isEmpty && !isLoading{
                            Text("User has no groups").foregroundColor(Color.gray)
                        }else if isLoading{
                            ProgressView()
                        }else {
                            ForEach(groups){ group in
                                NavigationLink {
                                    GroupChatView(chatID: group.chatID ?? "", groupID: group.id)
                                } label: {
                                    GroupSearchCell(group: group)
                                }
                            }
                        }
                      
                        
                    }.padding(.top,10)
                }
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            self.fetchGroups()
        }
    }
}


