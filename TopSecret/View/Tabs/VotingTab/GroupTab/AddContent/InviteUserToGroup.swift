//
//  InviteUserToGroup.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/23/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct InviteUserToGroup: View {
    
    @State var username : String = ""
    @EnvironmentObject var groupVM : SelectedGroupViewModel
    @StateObject var searchRepository = SearchRepository()
    @State var selectedUsers : [User] = []
    @EnvironmentObject var userVM : UserViewModel

    @State var keyboardHeight : CGFloat = 0

    @Environment(\.presentationMode) var presentationMode
    
    
    
    func initKeyboardGuardian(){
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification , object: nil, queue: .main) { data in
            let height1 = data.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
            withAnimation(.easeOut(duration: 0.25)){
                self.keyboardHeight = height1.cgRectValue.height - 20
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.25)){
                self.keyboardHeight = 0
            }
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
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    
                    Text("Invite Friend To Group").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline)
                    
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)

                }.padding(.top,50).padding(.horizontal)
                
                Spacer()
                VStack{
         
                    SearchBar(text: $searchRepository.searchText, placeholder: "invite friends", onSubmit: {
                        
                    })
                    
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(selectedUsers){ user in
                                HStack{
                                    Text("\(user.username ?? "")")
                                    Button(action:{
                                        selectedUsers.removeAll(where: {$0 == user})
                                    },label:{
                                        Image(systemName: "x.circle.fill")
                                    }).foregroundColor(FOREGROUNDCOLOR)
                                }.padding(10).background(RoundedRectangle(cornerRadius: 15).fill(Color("AccentColor")))
                            }
                        }
                    }.padding(10)
                    

                    
                    
                    
                    VStack{
                        if searchRepository.userReturnedResults.isEmpty && searchRepository.searchText != ""{
                            Text("No Users Found").foregroundColor(Color.gray)
                        }else{
                            ForEach(searchRepository.userReturnedResults){ user in
                                Button(action:{
                                    if selectedUsers.contains(user){
                                        selectedUsers.removeAll(where: {$0 == user})
                                    }else{
                                        selectedUsers.append(user)
                                    }
                                },label:{
                                    if user.id != userVM.user?.id{
                                   
                                    
                                    VStack(alignment: .leading){
                                        HStack{
                                            
                                            WebImage(url: URL(string: user.profilePicture ?? ""))
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width:40,height:40)
                                                .clipShape(Circle())
                                            
                                            Text("\(user.username ?? "")").foregroundColor(FOREGROUNDCOLOR)
                                            
                                            Spacer()
                                            
                                            Image(systemName: selectedUsers.contains(user) ? "checkmark.circle.fill" : "circle").font(.title).foregroundColor(FOREGROUNDCOLOR)
                                            
                                        }.padding(.horizontal,10)
                                        Divider()
                                    }
                                    }
                                })
                            }
                        }
                       
                        
                        
                    }
                    

                    
                    Button(action:{
                        
                        let dp = DispatchGroup()
                        
                        
                        for user in selectedUsers {
                            dp.enter()
                            groupVM.sendGroupInvitation(group: groupVM.group, friend: user, userID: self.userVM.user?.id ?? " ")
                            dp.leave()
                        }
                        
                    
                        
                        dp.notify(queue: .main) {
                            presentationMode.wrappedValue.dismiss()
                        }
                    },label:{
                        Text( selectedUsers.count <= 1 ? "Add User To Group!" : "Add Users To Group!").foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15).padding(.vertical).padding(.bottom,40)
                    })
                    Spacer()
                    
                }
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            initKeyboardGuardian()
            searchRepository.startSearch(searchRequest: "allUsers", id: "")
        }
    }
}

//struct InviteUserToGroup_Previews: PreviewProvider {
//    static var previews: some View {
//        InviteUserToGroup()
//    }
//}
