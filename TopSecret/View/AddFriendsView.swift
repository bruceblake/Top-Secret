//
//  AddFriendsView.swift
//  Top Secret
//
//  Created by Bruce Blake on 12/6/22.
//
import SDWebImageSwiftUI
import SwiftUI
import Firebase

struct AddFriendsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var openChat: Bool = false
    @State var selectedChatID = ""
    @StateObject var searchVM = SearchRepository()
    @StateObject var personalChatVM = PersonalChatViewModel()
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack(alignment: .center){
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                    Text("Add Friends").foregroundColor(FOREGROUNDCOLOR).font(.title2)
                    Spacer()
                    
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.top,50).padding(.horizontal)
                
                SearchBar(text: $searchVM.searchText, placeholder: "search for users", onSubmit: {
                    //todo
                })
                 
                AddFriendsSearchList(searchVM: searchVM, openChat: $openChat, selectedChatID: $selectedChatID)
            }
            
            NavigationLink(destination: PersonalChatView(personalChatVM: personalChatVM, chatID: selectedChatID), isActive: $openChat, label: {
                EmptyView()
            })
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onAppear{
            searchVM.startSearch(searchRequest: "allUsers", id: "")
        }.onDisappear{
            searchVM.removeListener()
        }
    }
}


struct AddFriendsSearchList : View {
    @StateObject var searchVM : SearchRepository
    @EnvironmentObject var userVM: UserViewModel
    @Binding var openChat: Bool
    @Binding var selectedChatID: String
    
   
    var body: some View {
        ScrollView{
            VStack{
                VStack(alignment: .leading){
                    if !searchVM.searchText.isEmpty && !searchVM.userReturnedResults.isEmpty{
                        HStack{
                            Text("Users").bold().padding(.leading,10)
                            Spacer()
                        }
                    }
                   
                    VStack{
                        if searchVM.userReturnedResults.isEmpty && searchVM.searchText != ""{
                            Text("No Users Found").foregroundColor(.gray).padding(.top,20)
                        }
                        
                        ForEach(searchVM.userReturnedResults){ user in
                            if user.id ?? "" != userVM.user?.id ?? ""{
                                NavigationLink(destination: UserProfilePage(user: user)) {
                                    UserAddSearchCell(user: user, selectedChatID: $selectedChatID, openChat: $openChat)

                                }
                            }
                        }
                    }
                 
                }
            }
        }
    }
}

struct UserAddSearchCell : View {
    @State var user: User
    @EnvironmentObject var userVM: UserViewModel
    @State var isLoading: Bool = false
    @State var isFriends: Bool = false
    @State var isBlocked: Bool = false
    @State var isPendingFriendRequest : Bool = false
    @Binding var selectedChatID : String
    @Binding var openChat: Bool
    @StateObject var userAddVM = UserAddSearchViewModel()
    
    func getPersonalChatID(friendID: String) -> String {
        var chats = userVM.personalChats.filter({$0.usersID?.count ?? 0 == 2})
        return chats.first(where: {$0.usersID?.contains(friendID) ?? false})?.id ?? " "
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            HStack(alignment: .center){
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 0){
                    Text("\(user.nickName ?? "")").foregroundColor(Color("Foreground"))
                    Text("@\(user.username ?? "")").font(.subheadline).foregroundColor(.gray)
                }
                
                Spacer()
                
                
                
                //if you two are not friends
                if isFriends {
                    Button(action:{
                        let dp = DispatchGroup()
                        dp.enter()
                        self.selectedChatID = self.getPersonalChatID(friendID: user.id ?? "")
                        dp.leave()
                        dp.notify(queue: .main, execute:{
                            self.openChat.toggle()
                            print("id is: \(selectedChatID)")
                        })
                    },label:{
                        HStack{
                                Text("Chat")
                                Image(systemName: "message")
                        }.font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                    })
                
                }
                
                else if isPendingFriendRequest{
                    HStack{
                           
                                if isLoading{
                                    ProgressView().font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                                }else{
                                    Text("Pending Friend Request").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color.gray))
                                }
                            
                           
                 
                        
                       
                            Button(action:{
                                isLoading = true
                                userVM.unsendFriendRequest(friend: user) { finished in
                                }
                            },label:{
                                Image(systemName: "xmark").font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
                            }).disabled(isLoading)
                            
                    }
                    
                }else {
                    HStack{
                            Button(action:{
                                isLoading = true
                                userVM.sendFriendRequest(friend: user) { finished in
                                    if !finished {
                                        self.isBlocked = true
                                        self.isLoading = false
                                    }
                                }
                            },label:{
                                HStack(spacing: 5){
                                    if isLoading{
                                        ProgressView()
                                    }
                                    Text("\(self.isBlocked ? "You are blocked" : "Send Friend Request")")
                                }.font(.caption).foregroundColor(FOREGROUNDCOLOR).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                            
                                
                            }).disabled(isLoading)
                           
                 
                            
                    }
                  
                }
                
             
                
                
            }.padding(.horizontal,10)
            Divider()
            
        }

        .onAppear{
            userAddVM.listenToUser(userID: user.id ?? " ")
        }.onReceive(userAddVM.$user) { fetchedUser in
            if fetchedUser.friendsListID?.contains(userVM.user?.id ?? " ") ?? false {
                self.isFriends = true
                self.isPendingFriendRequest = false
            }else if (fetchedUser.incomingFriendInvitationID?.contains(userVM.user?.id ?? " ") ?? false) || (fetchedUser.outgoingFriendInvitationID?.contains(userVM.user?.id ?? " ") ?? false) {
                self.isPendingFriendRequest = true
                self.isFriends = false
            }else{
                self.isFriends = false
                self.isPendingFriendRequest = false
            }
            self.isLoading = false
        }.onDisappear{
            userAddVM.removeListener()
        }
    }
}




class UserAddSearchViewModel : ObservableObject {
    @Published var user: User = User()
    @Published var listener : ListenerRegistration?
    func listenToUser(userID: String){
        listener = COLLECTION_USER.document(userID).addSnapshotListener { snapshot, err in
            if err != nil {
                print("ERROR")
                return
            }
            
            let data = snapshot?.data() as? [String:Any] ?? [:]
            
            self.user = User(dictionary: data)
        }
    }
    
    func removeListener(){
        self.listener?.remove()
    }
}
