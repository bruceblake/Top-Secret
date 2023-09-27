////
////  ChatInfoView.swift
////  TopSecret
////
////  Created by Bruce Blake on 9/22/21.
////
//
//import SwiftUI
//
//struct ChatInfoView: View {
//    var chat: ChatModel
//    @State var _user : User = User()
//    @StateObject var chatVM = ChatViewModel()
//    @StateObject var groupVM = GroupViewModel()
//    @Environment(\.presentationMode) var presentationMode
//    @State var messageNotificationsOn: Bool = false
//    @State var pinnedMessageNotifactionsOn: Bool = false
//    @State var goToUserProfilePage : Bool = false
//    @EnvironmentObject var userVM : UserViewModel
//    
//    var body: some View {
//        ZStack{
//            Color("Background")
//                VStack{
//                    VStack{
//                        Button("X"){
//                            presentationMode.wrappedValue.dismiss()
//                        }
//                        
//                        Text("\(chat.name!)")
//                        
//                    }.padding(.top,40)
//                    
//                    
//                    ScrollView(){
//                        VStack(alignment: .leading){
//                            VStack(alignment: .leading){
//                                    Text("Users").fontWeight(.bold).foregroundColor(Color("Foreground")).padding(.leading,25)
//                                        .padding(.bottom,2)
//                                
//                                VStack{
//                                    ForEach(chatVM.userList, id: \.id){ user in
//                                        Button(action:{
//                                           
//                                                self.goToUserProfilePage.toggle()
//                                            
//                                            
//                                        },label:{
//                                            GroupUsersListCell(user: user, isCurrentUser: user.id == userVM.user?.id, nameColor: chatVM.colors[chat.users.firstIndex(of: user.id ?? "") ?? 0])
//                                        }).fullScreenCover(isPresented: $goToUserProfilePage, content: {
//                                            if user.id == userVM.user?.id ?? "" {
//                                                CurrentUserProfilePage()
//                                            }else{
//                                                UserProfilePage(user: user)
//                                            }
//                                        })
//                                    }
//                                    
//                                }.background(Color("Color")).cornerRadius(12).padding(.horizontal)
//                            }
//                            
//                            
//
//                        }
//                        
//                        
//                    }
//                    
//                    
//                   
//                   
//                    
//                    
//                }.padding()
//            
//          
//            
//        }.edgesIgnoringSafeArea(.all)        .onAppear{
//            self.chatVM.getUsers(usersID: chat.users)
//        }
//        
//    }
//}
//
////struct ChatInfoView_Previews: PreviewProvider {
////    static var previews: some View {
////        ChatInfoView(chat: ChatModel())
////    }
////}
