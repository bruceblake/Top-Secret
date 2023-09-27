////
////  ChatView.swift
////  TopSecret
////
////  Created by Bruce Blake on 8/31/21.
////
//
//import SwiftUI
//import Firebase
//import SDWebImageSwiftUI
//struct ChatView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var userVM : UserViewModel
//    
//    @StateObject var chatVM = ChatViewModel()
//    @StateObject var messageVM = MessageViewModel()
//    @StateObject var groupVM = GroupViewModel()
//    @StateObject var imagePickerVM = ImagePickerViewModel()
//    @StateObject private var keyboardHandler = KeyboardGuardian()
//    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
//    
//    @State var value: CGFloat = 0
//    @State var text = ""
//    @State var infoScreen: Bool = false
//    @State var isShowingPhotoPicker:Bool = false
//    @State var showImageSendView : Bool = false
//    @State var avatarImage = UIImage(named: "Icon")!
//    @State var replyToMessage: Bool = false
//    @State var editMessage: Bool = false
//    @State var currentMessage : Message = Message()
//    @State var showMenu: Bool = false
//    @State var userIDList: [String] = []
//    @State var images : [UIImage] = []
//    @Binding var group: Group
//    @State var pushText : Bool = false
//    var columns3Fixed: [GridItem] = [
//        GridItem(.fixed(115), spacing: 10),
//        GridItem(.fixed(115), spacing: 10),
//        GridItem(.fixed(115), spacing: 10)
//    ]
//    
//    var uid: String
//    @State var startPos : CGPoint = .zero
//    @State var isSwipping = true
//    
//    
  
//    
//    func sortChatUsersIdle(users: [User]) -> [User]{
//        
//        let users = users.sorted(by: { checkIfUserIsIdling(userID: $0.id ?? " ") && !checkIfUserIsIdling(userID: $1.id ?? " ") })
//        
//        return users
//    }
//    
//    func checkIfUserIsIdling(userID: String) -> Bool {
//        for user in chatVM.usersIdlingList {
//            let id = user.id ?? " "
//            if id == userID{
//                return true
//            }
//        }
//        return false
//    }
//    
//    
//    var body: some View {
//        
//        
//        
//        
//        ZStack(alignment: .top){
//            Color("Background")
//            
//            VStack{
//                
//                
//                ScrollView(showsIndicators: false){
//                    ScrollViewReader{ scrollViewProxy in
//                        
//                        
//                        VStack{
//                            
//                            
//                            
//                            
//                            ForEach(messageVM.messages){ message in
//                                MessageCell(replyToMessage: $replyToMessage, messageToReplyTo: $currentMessage, showMenu: $showMenu,message: message, chatID: selectedGroupVM.group?.chat?.id ?? " ").padding(.horizontal,10).padding(.vertical,-4)
//                            }
//                            
//                            
//                            VStack{
//                                ForEach(chatVM.usersTypingList){ user in
//                                    
//                                    if user.id == userVM.user?.id ?? ""{
//                                        HStack(spacing: 4){
//                                            Text("YOU").foregroundColor(Color("AccentColor")).fontWeight(.bold)
//                                            Text("are typing...").foregroundColor(.gray)
//                                            Spacer()
//                                        }
//                                    }else{
//                                        HStack(spacing: 4){
//                                            Text("\(user.nickName ?? "USER_NICKNAME")").foregroundColor(Color.red)
//                                            Text("is typing...").foregroundColor(.gray)
//                                            Spacer()
//                                        }
//                                    }
//                                    
//                                    
//                                }
//                            }.padding(.horizontal,10).padding(.vertical,7)
//                            
//                            
//                            
//                            
//                            HStack{Spacer()}.padding(0).id("Empty")
//                            
//                            
//                            
//                            
//                            
//                        }.padding(.top,UIScreen.main.bounds.height/4).padding(.bottom, keyboardHandler.keyboardHeight).animation(.default).padding(.bottom,30).onReceive(messageVM.$scrollToBottom, perform: { _ in
//                            withAnimation(.easeOut(duration: 0.5)) {
//                                scrollViewProxy.scrollTo("Empty", anchor: .bottom)
//                            }
//                        }).navigationBarHidden(true)
//                        
//                    }
//                    
//                    
//                }
//                
//                
//                
//                VStack(spacing: 0){
//                    
//                    
//                    Divider()
//                    
//                    
//                    VStack(spacing: 0){
//                        
//                        HStack{
//                            Button(action:{
//                                
//                                
//                                imagePickerVM.openImagePicker()
//                            },label:{
//                                ZStack{
//                                    Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
//                                    Image(systemName: imagePickerVM.showImagePicker ? "xmark" :  "photo.on.rectangle")
//                                }
//                            })
//                            
//                            
//                            CustomChatTextField(text: $text, isShowingPhotoPicker: $isShowingPhotoPicker, avatarImage: $avatarImage, sendAction : {
//                                messageVM.sendGroupChatTextMessage(text: text, user: userVM.user ?? User(), timeStamp: Timestamp(), nameColor: chatVM.colors[selectedGroupVM.group?.chat?.users.firstIndex(of: uid) ?? 0], messageID: UUID().uuidString, messageType: messageVM.readLastMessage().name ?? " " == userVM.user?.nickName ?? " " ? "followUpUserText" : "text", chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", chatType: "groupChat", groupID: selectedGroupVM.group?.id ?? " ")
//                            }, textChange: {
//                                
//                                
//                                if text == ""{
//                                    chatVM.stopTyping(userID: uid, chatID: selectedGroupVM.group?.chat?.id ?? " ", chatType: "groupChat", groupID: group.id)
//                                }else{
//                                    chatVM.startTyping(userID: uid, chatID: selectedGroupVM.group?.chat?.id ?? " ", chatType: "groupChat", groupID: group.id)
//                                }
//                                
//                            }, editingChange: {
//                                if imagePickerVM.showImagePicker{
//                                    withAnimation{imagePickerVM.showImagePicker.toggle()}
//                                }
//                                pushText.toggle()
//                                
//                            })
//                            
//                            
//                            
//                                .sheet(isPresented: $showImageSendView, content: {
//                                    ImageSendView(message: Message(dictionary: ["id":UUID().uuidString,"nameColor":chatVM.colors[selectedGroupVM.group?.chat?.users.firstIndex(of: uid) ?? 0],"timeStamp":Timestamp(),"name":userVM.user?.nickName ?? "","profilePicture":userVM.user?.profilePicture ?? "","messageType":"image"]), imageURL: avatarImage, chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", groupID: selectedGroupVM.group?.id ?? " " , messageVM: messageVM)
//                                }).fullScreenCover(isPresented: $isShowingPhotoPicker, onDismiss: {
//                                    self.showImageSendView.toggle()
//                                }, content: {
//                                    ImagePicker(avatarImage: $avatarImage, images: $images, allowsEditing: false)
//                                })
//                            
//                        }.padding(.leading,5)
//                        
//                        ScrollView(.vertical){
//                            VStack{
//                                
//                                
//                                
//                                LazyVGrid(
//                                    columns: columns3Fixed,
//                                    alignment: .center,
//                                    spacing: 10,
//                                    pinnedViews: []
//                                ) {
//                                    
//                                    ForEach(imagePickerVM.fetchedPhotos){ photo in
//                                        
//                                        ThumbnailView(photo: photo).onTapGesture {
//                                            imagePickerVM.extractPreviewData(asset: photo.asset)
//                                            imagePickerVM.showPreview.toggle()
//                                        }
//                                        
//                                        
//                                        
//                                        
//                                        
//                                    }
//                                    
//                                }
//                                
//                                
//                                
//                                
//                                if imagePickerVM.libraryStatus == .denied || imagePickerVM.libraryStatus == .limited {
//                                    VStack(spacing: 10){
//                                        Text(imagePickerVM.libraryStatus == .denied ? "Allow Access for Photos" : "Select More Photos").foregroundColor(.gray)
//                                        
//                                        Button(action:{
//                                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
//                                        },label:{
//                                            Text(imagePickerVM.libraryStatus == .denied ?  "Allow Acces" : "Select More").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).padding(.vertical,10).padding(.horizontal).background(Color("AccentColor")).cornerRadius(5)
//                                        })
//                                    }.frame(width: 150)
//                                }
//                            }
//                        }.frame(height: imagePickerVM.showImagePicker ? 150 : 0).background(Color("Color")).opacity(imagePickerVM.showImagePicker ? 1 : 0)
//                        
//                        
//                    }
//                    
//                    
//                    
//                    
//                }.background(Color("Background")).offset(y: -self.value).navigationBarHidden(true)
//                    .animation(.spring())
//                    .onAppear {
//                        
//                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
//                            let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
//                            let height = value.height
//                            self.value = height
//                        }
//                        
//                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
//                            
//                            self.value = 0
//                        }
//                    }
//                
//            }
//            
//            VStack{
//                
//                HStack{
//                    
//                    Button(action:{
//                        presentationMode.wrappedValue.dismiss()
//                    },label:{
//                        ZStack{
//                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
//                            
//                            Image(systemName: "chevron.left")
//                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
//                        }
//                    })
//                    
//                    
//                    
//                    Button(action:{
//                        
//                    },label:{
//                        ZStack{
//                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
//                            
//                            Image(systemName: "info")
//                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
//                        }
//                    })
//                    
//                    Spacer()
//                    
//                    Text("\(group.groupName)").foregroundColor(FOREGROUNDCOLOR).font(.largeTitle)
//                    
//                    Spacer()
//                    
//                    Button(action:{
//                        
//                    },label:{
//                        ZStack{
//                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
//                            
//                            Image(systemName: "video.fill")
//                                .font(.headline).foregroundColor(FOREGROUNDCOLOR)
//                        }
//                    })
//                    
//                    
//                    Button(action:{
//                        
//                    },label:{
//                        ZStack{
//                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
//                            
//                            Image(systemName: "gear")
//                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
//                        }
//                    })
//                }.padding(.horizontal).padding(.top,40)
//                
//                
//                ScrollView(.horizontal){
//                    HStack(spacing: 0){
//                        ForEach(sortChatUsersIdle(users: chatVM.userList)){ user in
//                            
//                            NavigationLink(destination: UserProfilePage(user: user), label:{
//                                
//                                VStack(spacing: 5){
//                                    WebImage(url: URL(string: user.profilePicture ?? ""))
//                                        .resizable()
//                                        .scaledToFill()
//                                        .frame(width:40,height:40)
//                                        .clipShape(Circle())
//                                        .overlay(Circle().stroke(selectedGroupVM.group?.chat?.usersIdling.contains(user.id ?? " ") ?? false ? Color(getColor(userID: user.id ?? "", groupChat: selectedGroupVM.group?.chat ?? ChatModel())) : Color.gray,lineWidth: 2))
//                                    
//                                    Text("\(user.nickName ?? "TOP SECRET USER")").foregroundColor(FOREGROUNDCOLOR)
//                                }
//                                
//                                
//                                
//                            }).padding(.leading,5).padding(.top,5)
//                            
//                            
//                            
//                            
//                            
//                        }
//                    }
//                    
//                    
//                }
//                
//                Divider()
//            }.padding(.top,10).background(Color("Background"))
//            
//            
//            
//            
//            
//            if replyToMessage{
//                GeometryReader{ _ in
//                    ReplyOverlay(replyToMessage: $replyToMessage, message: currentMessage, chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", groupID: selectedGroupVM.group?.id ?? " ")
//                }.padding(.horizontal,40).padding(.top,350).background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all)
//            }
//            
//            if editMessage{
//                GeometryReader{ _ in
//                    
//                    
//                    EditMessageOverlay(message: currentMessage, chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", groupID: selectedGroupVM.group?.id ?? " ", editMessage: $editMessage)
//                }.padding(.horizontal,40).padding(.top,350).background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all)
//                
//            }
//            
//            
//            
//            if showMenu {
//                
//                GeometryReader { geometry in
//                    
//                    VStack{
//                        //message
//                        
//                        VStack(alignment: .leading){
//                            HStack{
//                                WebImage(url: URL(string: currentMessage.profilePicture ?? ""))
//                                    .resizable()
//                                    .scaledToFill()
//                                    .frame(width:50,height:50)
//                                    .clipShape(Circle())
//                                    .padding([.trailing,.top,.bottom],7)
//                                
//                                VStack(alignment: .leading, spacing: 5){
//                                    HStack{
//                                        Text("\(currentMessage.name ?? "")").foregroundColor(Color(currentMessage.nameColor ?? ""))
//                                        
//                                        Spacer()
//                                        
//                                        Text("\(currentMessage.timeStamp?.dateValue() ?? Date(), style: .time)")
//                                    }
//                                    
//                                    
//                                    HStack{
//                                        Text("\(currentMessage.messageValue ?? "")")
//                                        if currentMessage.edited ?? false{
//                                            Text("(edited)").foregroundColor(.gray).font(.footnote)
//                                        }
//                                    }
//                                }
//                                
//                                Spacer()
//                                
//                                
//                                
//                                
//                                
//                                
//                                
//                            }
//                        }.padding(.horizontal).background(Color("Color")).cornerRadius(16)
//                        
//                        VStack{
//                            
//                            if currentMessage.name == userVM.user?.nickName{
//                                Button(action:{
//                                    withAnimation(.easeIn(duration: 0.2)){
//                                        self.showMenu.toggle()
//                                    }
//                                    
//                                    messageVM.deleteMessage(chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", message: currentMessage, groupID: selectedGroupVM.group?.id ?? " ")
//                                },label:{
//                                    Text("Delete").foregroundColor(FOREGROUNDCOLOR)
//                                }).padding()
//                                
//                                
//                                Divider()
//                                
//                                
//                            }
//                            
//                            Button(action:{
//                                withAnimation(.easeIn(duration: 0.2)){
//                                    
//                                    
//                                    self.showMenu.toggle()
//                                }
//                                
//                                
//                                messageVM.pinMessage(chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", messageID: currentMessage.id, userID: userVM.user?.id ?? "", groupID: selectedGroupVM.group?.id ?? " ")
//                            },label:{
//                                Text("Pin").foregroundColor(FOREGROUNDCOLOR)
//                            }).padding(10)
//                            
//                            Divider()
//                            
//                            if currentMessage.name == userVM.user?.nickName{
//                                
//                                Button(action:{
//                                    //EDIT MESSAGE
//                                    withAnimation(.easeIn(duration: 0.2)){
//                                        self.showMenu.toggle()
//                                        self.editMessage.toggle()
//                                    }
//                                    
//                                    
//                                },label:{
//                                    Text("Edit").foregroundColor(FOREGROUNDCOLOR)
//                                }).padding(10)
//                                
//                                Divider()
//                            }
//                            Button(action:{
//                                withAnimation(.easeIn(duration: 0.2)){
//                                    self.showMenu.toggle()
//                                    replyToMessage.toggle()
//                                }
//                                
//                            },label:{
//                                Text("Reply").foregroundColor(FOREGROUNDCOLOR)
//                            }).padding(10)
//                            
//                        }.background(Color("Color")).cornerRadius(12)
//                        
//                    }
//                    
//                    
//                }.padding(.horizontal,60).padding(.top,300).background(Color.black.opacity(0.45)).edgesIgnoringSafeArea(.all).onTapGesture {
//                    withAnimation(.easeIn(duration: 1)){
//                        self.showMenu.toggle()
//                    }
//                }
//            }
//            
//            
//        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).gesture(DragGesture()
//                                                                            .onChanged { gesture in
//            if self.isSwipping {
//                self.startPos = gesture.location
//                self.isSwipping.toggle()
//            }
//            
//        }
//                                                                        
//                                                                            .onEnded({ gesture in
//            let xDist = abs(gesture.location.x - self.startPos.x)
//            
//            if self.startPos.x < gesture.location.x {
//                presentationMode.wrappedValue.dismiss()
//            }
//            
//            self.isSwipping.toggle()
//        })
//        
//        )
//            .onDisappear{
//                for listener in selectedGroupVM.listeners{
//                    listener.remove()
//                }
//            }
//            .onAppear{
//                imagePickerVM.setUp()
//                
//                let groupD = DispatchGroup()
//                
//                groupD.enter()
//                
//                selectedGroupVM.listenToGroup(userID: userVM.user?.id ?? " ", groupID: group.id) { fetched in
//                    
//                    
//                }
//                groupD.leave()
//                
//                groupD.notify(queue: .main, execute:{
//                    messageVM.getPinnedMessage(chatID: selectedGroupVM.group?.chatID ?? "CHAT_ID", groupID: selectedGroupVM.group?.id ?? " ")
//                    
//                    
//                    
//                    chatVM.openChat(userID: uid, chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID" , chatType: "groupChat", groupID: selectedGroupVM.group?.id ?? " ")
//                    chatVM.getUsers(usersID: group.users ?? [])
//                    chatVM.getUsersIdlingList(chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", groupID: group.id)
//                    chatVM.getUsersTypingList(chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", groupID: group.id)
//                    messageVM.readAllMessages(chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", userID: userVM.user?.id ?? " ", chatType: "groupChat", groupID: selectedGroupVM.group?.id ?? " ")
//                    
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                        messageVM.scrollToBottom += 1
//                        chatVM.getUsersIDList(users: chatVM.usersIdlingList) { users in
//                            self.userIDList = users
//                        }
//                        
//                    }
//                    
//                })
//                
//                
//                
//                
//                
//                
//            }
//        
//        
//        
//        
//            .onDisappear{
//                chatVM.exitChat(userID: uid, chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", chatType: "groupChat", groupID: selectedGroupVM.group?.id ?? " ")
//                chatVM.stopTyping(userID: uid, chatID: selectedGroupVM.group?.chat?.id ?? "CHAT_ID", chatType: "groupChat", groupID: selectedGroupVM.group?.id ?? " ")
//            }
//        
//    }
//}
//
//
//
//struct ThumbnailView: View {
//    
//    var photo: AssetModel
//    var body: some View {
//        ZStack(alignment: .bottomTrailing){
//            Image(uiImage: photo.image)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .frame(width: 115, height: 115)
//            
//            if photo.asset.mediaType == .video{
//                Image(systemName: "video.fill").font(.title2).foregroundColor(FOREGROUNDCOLOR)
//            }
//        }
//    }
//}
//
//
//struct CustomChatTextField : View {
//    
//    
//    
//    
//    
//    
//    @State var showSend : Bool = false
//    @State var value: CGFloat = 0
//    @Binding var text : String
//    @Binding var isShowingPhotoPicker : Bool
//    @Binding var avatarImage : UIImage
//    @State var showImageSendView : Bool = false
//    
//    var sendAction : () -> (Void)
//    var textChange : () -> (Void)
//    var editingChange: () -> (Void)
//    
//    var body: some View {
//        HStack{
//            
//            
//            TextField("Message", text: $text, onEditingChanged: { editingChanged in
//                editingChange()
//            }).onChange(of: text) { message in
//                showSend = message != ""
//                textChange()
//            }.padding(.leading,5)
//            
//            Spacer()
//            
//            if !showSend{
//                HStack{
//                    
//                    Button(action:{
//                        
//                    },label:{
//                        ZStack{
//                            Image("Poll Icon").resizable().frame(width: 30, height: 30)
//                        }
//                    }).padding(.leading)
//                    
//                    
//                }
//            }else{
//                Button(action:{
//                    
//                    sendAction()
//                    
//                    
//                    text = ""
//                    
//                    
//                    
//                },label:{
//                    Text("Send")
//                }).disabled(text == "").frame(width: 40, height: 40).padding(.trailing,5)
//            }
//        }.padding(.vertical,5).background(Color("Color")).cornerRadius(12).padding()
//    }
//}
//
//
//
////struct ChatView_Previews: PreviewProvider {
////    static var previews: some View {
////        ChatView(uid: "", chat: ChatModel())
////    }
////}
//
//
//
//
