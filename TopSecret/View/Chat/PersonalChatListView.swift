////
////  PersonalChatListView.swift
////  TopSecret
////
////  Created by Bruce Blake on 2/19/22.
////
//
//
//import SDWebImageSwiftUI
//import SwiftUI
//
//struct PersonalChatListView: View {
//    
//    
//    
//    @EnvironmentObject var userVM: UserViewModel
//    @State var friend: User = User()
//    @State var currentChat: ChatModel = ChatModel()
//    @State var show: Bool = false
//    @Environment(\.presentationMode) var presentationMode
//
//    
//    
//    
//    
//    var body: some View {
//        ZStack(alignment: .top){
//            Color("Background")
//            
//            VStack{
//                
//                ScrollView{
//                    
//                    if userVM.personalChats.isEmpty{
//                        Text("You have no chats!")
//                    }else{
//                        ForEach(userVM.personalChats){ chat in
//                            Button(action:{
//                                self.currentChat = chat
//                                
//                                userVM.fetchUser(userID: self.currentChat.users[0] == userVM.user?.id ?? "" ? self.currentChat.users[1] : self.currentChat.users[0]) { fetchedUser in
//                                    self.friend = fetchedUser
//                                }
//                                self.show.toggle()
//                                
//                            },label:{
//                                PersonalChatCell(chat: chat)
//                            })
//                          
//                        }
//                    }
//                   
//                    
//                    
//                }
//            }.padding(.top,100)
//            
//            HStack{
//                Button(action:{
//                    presentationMode.wrappedValue.dismiss()
//                },label:{
//                    Text("Back")
//                }).padding(.leading,10)
//                Spacer()
//                
//                Text("Messages").fontWeight(.bold).font(.title)
//                
//                Spacer()
//                
//              
//                NavigationLink(destination: AddChatView()) {
//                    Image(systemName: "plus.message")
//                }.padding(.trailing, 10)
//                
//            }.padding(.top,50)
//         
//            NavigationLink(isActive: $show) {
//                PersonalChatView(friend: $friend, chat: $currentChat)
//            } label: {
//                EmptyView()
//            }
//
//            
//        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
//    }
//}
//
//
//struct PersonalChatCell : View {
//    
//    @State var chat: ChatModel = ChatModel()
//    @EnvironmentObject var userVM: UserViewModel
//    @StateObject var messageVM = MessageViewModel()
//    @State var friend: User = User()
//    @State var lastMessage: Message = Message()
//    
//    func getFriendID(currentUser: String, usersID: [String]) -> String{
//        
//        var friendID = ""
//        
//        for userID in usersID{
//            if userID != currentUser {
//                friendID = userID
//            }
//        }
//        
//        print("friendID: \(friendID)")
//        return friendID
//    }
//    
//    
//    var body: some View{
//        VStack(alignment: .leading){
//            HStack(alignment: .center){
//                WebImage(url: URL(string: friend.profilePicture ?? ""))
//                    .resizable()
//                    .scaledToFill()
//                    .frame(width:48,height:48)
//                    .clipShape(Circle())
//                    
//                
//                HStack{
//                    Text("\(friend.nickName ?? "")").foregroundColor(Color("Foreground")).fontWeight(.bold)
//                    Spacer()
//                    
//                    HStack{
//                        Text(lastMessage.messageValue ?? "").foregroundColor(FOREGROUNDCOLOR).padding(.trailing,10)
//                        
//                        Text("\(lastMessage.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
//                    }
//                }
//                    
//
//                
//                Spacer()
//            }.padding([.leading,.vertical])
//            Divider()
//        }.onAppear{
//            userVM.fetchUser(userID: getFriendID(currentUser: userVM.user?.id ?? "", usersID: chat.users)) { fetchedFriend in
//                self.friend = fetchedFriend
//            }
//            
//            messageVM.readAllMessages(chatID: chat.id, userID: userVM.user?.id ?? "", chatType: "personal", groupID: " ")
//            
//                    
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                self.lastMessage = messageVM.readLastMessage()
//            }
//            
//         
//        }
//    }
//}
//
//struct PersonalChatListView_Previews: PreviewProvider {
//    static var previews: some View {
//        PersonalChatListView()
//    }
//}
