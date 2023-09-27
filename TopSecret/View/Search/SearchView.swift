//
//  SearchView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/1/22.
//

import SwiftUI
import Combine

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject var searchRepository = SearchRepository()
    @EnvironmentObject var userVM : UserViewModel
    @State var openGroupProfile : Bool = false
    @State var selectedGroup : GroupModel = GroupModel()
    
    func convertToBinding(users: [User]) -> Binding<[User]>{
        
        
        return Binding(get: {users}, set: {_ in})
    }

    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack(alignment: .center){
                    SearchBar(text: $searchRepository.searchText, placeholder: "friends and groups", onSubmit: {
                        
                    })
                        .padding(.top)
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        Text("Cancel").foregroundColor(.gray).fontWeight(.bold)
                    }).padding([.trailing,.top])
                }.padding(.top,40)
                
                
                ScrollView(){
                    VStack(alignment: .leading){
                      
                        
                        VStack(alignment: .leading){
                            if !searchRepository.searchText.isEmpty && !searchRepository.userGroupReturnedResults.isEmpty{
                                Text("Your Groups").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                            }
                            VStack{
                                ForEach(searchRepository.userGroupReturnedResults , id: \.id) { group in
                                    
                                    Button(action:{
                                        selectedGroup = group
                                        openGroupProfile.toggle()
                                    },label:{
                                        GroupSearchCell(group: group)
                                    })
                                    
                                   
                                
                                }
                            }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
                        }
                        
                        VStack(alignment: .leading){
                            if !searchRepository.searchText.isEmpty && !searchRepository.userFriendsReturnedResults.isEmpty{
                                Text("Your Friends").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading)
                            }
                            ForEach(searchRepository.userFriendsReturnedResults, id: \.id){ user in
                                    NavigationLink {
                                        if user.id == userVM.user?.id ?? ""{
                                            CurrentUserProfilePage()
                                        }else{
                                            UserProfilePage(user: user)
                                        }
                                    } label: {
                                        UserSearchCell(user: user, showActivity: false)
                                    }

                                 
                                

                             
                            }
                        }
                        

                    }
                    
                    
                }
                Spacer()
            }
            
            
            NavigationLink(destination: GroupProfileView(group: selectedGroup, isInGroup: selectedGroup.usersID.contains(userVM.user?.id ?? " ")), isActive: $openGroupProfile){
                EmptyView()
            }

        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchRepository.startSearch(searchRequest: "allUserFriendsAndGroups", id: "\(userVM.user?.id ?? " ")")
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}

//struct SearchView_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchView()
//    }
//}
