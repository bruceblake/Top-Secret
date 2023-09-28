//
//  InviteMembersToEventView.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/26/23.
//

import SDWebImageSwiftUI
import SwiftUI
import Contacts

struct InviteMembersToEventView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @Binding var selectedUsers : [User]
    @StateObject var searchVM = SearchRepository()
    @Binding var openInviteFriendsView: Bool
    @Binding var openAddContactsView: Bool
    var excludedMembers: [User]
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        
        
        ZStack{
            Color("Color")
            VStack{
                
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
                }.padding(.top,30)
                
                
                Button(action:{
                    withAnimation{
                        openInviteFriendsView = false
                        openAddContactsView = true
                    }
                    
                },label:{
                    HStack{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "plus").font(.system(size: 18)).foregroundColor(FOREGROUNDCOLOR)
                        }
                        Text("Add Contacts").foregroundColor(FOREGROUNDCOLOR)
                        
                        Spacer()
                    }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("Background")))
                }).padding(.top,5)
                
                ScrollView(){
                    VStack(){
                        VStack(alignment: .leading){
                            
                            if !selectedUsers.isEmpty{
                                Text("Invited Users").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                            }
                            ScrollView(.horizontal){
                                HStack{
                                    ForEach(selectedUsers, id: \.id){ user in
                                        if user.id != userVM.user?.id ?? "" {
                                            Button(action:{
                                                searchVM.searchText = user.nickName ?? ""
                                            },label:{
                                                HStack{
                                                    Text(user.nickName ?? "").foregroundColor(FOREGROUNDCOLOR)
                                                    Button(action:{
                                                        selectedUsers.removeAll(where: {$0 == user})
                                                    },label:{
                                                        Image(systemName: "x.circle.fill")
                                                    }).foregroundColor(FOREGROUNDCOLOR)
                                                }.padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                                                
                                            })
                                            
                                        }
                                    }
                                }
                            }
                        }.padding(.top)
                        
                        
                        
                        VStack(alignment: .leading){
                            
                            
                            
                            if searchVM.searchText == "" {
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
                                                    .resizable().placeholder{
                                                        ProgressView()
                                                    }
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
                            }else{
                                if !searchVM.userFriendsReturnedResults.isEmpty  {
                                    VStack(alignment: .leading){
                                        Text("\(searchVM.searchText)").fontWeight(.bold).foregroundColor(Color("Foreground"))
                                    }
                                    ForEach(searchVM.userFriendsReturnedResults, id: \.id){ friend in
                                        if !excludedMembers.contains(where: {$0.id == friend.id ?? " "}){
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
                                                        .resizable().placeholder{
                                                            ProgressView()
                                                        }
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
                                }else if searchVM.userFriendsReturnedResults.isEmpty  {
                                    Spacer()
                                    Text("There are no results for \(searchVM.searchText)").foregroundColor(Color.gray)
                                    Spacer()
                                }
                                
                            }
                            
                            
                            
                            
                            
                        }
                        
                    }
                    
                    
                }.gesture(DragGesture().onChanged { _ in
                    UIApplication.shared.keyWindow?.endEditing(true)
                })
                
                Button(action:{
                    
                    presentationMode.wrappedValue.dismiss()
                },label:{
                    Text("Add Members").foregroundColor(FOREGROUNDCOLOR)
                        .frame(width: UIScreen.main.bounds.width/1.5).padding(10).background(RoundedRectangle(cornerRadius: 16).fill(Color("AccentColor")))
                    
                }).padding(.vertical,10).padding(.bottom,30)
                
                Spacer()
                
                
                
                
            }.padding()
            
            
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            DispatchQueue.main.async{
                searchVM.startSearch(searchRequest: "allUserFriendsAndGroups", id: userVM.user?.id ?? " ")
            }
        }
        
        
        
        
    }
}


//
//struct ContactsView : View {
//    @StateObject var contactVM = ContactsViewModel()
//    @State private var searchText: String = ""
//    var body: some View {
//        ZStack{
//            Color("Background")
//            VStack{
//                HStack{
//                    Button(action:{
//                        
//                    },label:{
//                        ZStack{
//                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
//                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
//                        }
//                    })
//                    
//                    Spacer()
//                    
//                    Text("Contacts").font(.title2)
//                    Spacer()
//                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
//                }.padding(.top,50).padding(.horizontal)
//                SearchBarView(text: $searchText, placeholder: "search")
//                ForEach(contactVM.contacts.filter{self.searchText.isEmpty ? true : $0.givenName.lowercased().contains(self.searchText.lowercased())}, id: \.self.name){ (contact: CNContact) in
//                    VStack(alignment: .leading){
//                        Text(contact.name)
//                    }
//                }
//                Spacer()
//            }
//        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
//            DispatchQueue.main.async{
//                contactVM.fetch()
//            }
//        }
//    }
//}

struct SearchBarView : UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(text: $text)
    }
    
    func makeUIView(context: Context) -> UISearchBar{
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.placeholder = placeholder
        searchBar.searchBarStyle = .minimal
        searchBar.autocapitalizationType = .none
        searchBar.showsCancelButton = false
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: Context){
        uiView.text = text
    }
}

class Coordinator: NSObject, UISearchBarDelegate{
    @Binding var text: String
    
    init(text: Binding<String>) {
        _text = text
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        text = searchText
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
