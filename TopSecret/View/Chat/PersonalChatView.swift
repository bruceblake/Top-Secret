import SwiftUI
import SDWebImageSwiftUI
import Foundation
import Firebase
import FirebaseStorage
import OmenTextField
import MediaPicker
import AVFoundation
import AVKit
import FirebaseFirestoreSwift


fileprivate var initialY : CGFloat? = nil

struct PersonalChatView : View {
    
    @EnvironmentObject var userVM: UserViewModel
    @Environment(\.presentationMode) var presentationMode
    @StateObject var personalChatVM : PersonalChatViewModel
    @State var showOverlay : Bool = false
    @State var selectedMessage: Message = Message()
    @State var showEditView: Bool = false
    @State var showReplyView: Bool = false
    @State var height: CGFloat = 20
    @State var editText: String = ""
    @State var keyboardHeight : CGFloat = 0
    @State var text = ""
    @State var focused: Bool = false
    @State var showAddContent: Bool = false
    @State var showAddEventView: Bool = false
    let notificationSender = PushNotificationSender()
    @Environment(\.scenePhase) var scenePhase
    @State private var scrollViewOffset = CGFloat.zero
    @State var canAddAnotherLine : Bool = true
    @State var chatID: String
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var reachedHalfway : Bool = false
    @State var isShowingMediaPicker : Bool = false
    @State var urls : [URL] = []
    @State var images: [UIImage] = []
    @State var videos: [URL] = []
    @State var isLoadingMedia : Bool = false
    @State var isLeavingChat: Bool = false
    @State var selectedThumbnailImages: [UIImage] = []
    @State var selectedThumbnailUrls: [URL] = []
    @State var limit: Int = 5
    @State var showSettingsView: Bool = false
    
   
   
                          
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
    
    func getPersonalChatUser() -> User{
        
        for user in personalChatVM.chat.users ?? [] {
            if user.id ?? "" != userVM.user?.id ?? " "{
                return user
            }
        }
        
        return User()
    }
    
    func checkIfUserIsActive() -> Bool {
        if personalChatVM.chat.usersIdlingID.contains(self.getPersonalChatUser().id ?? "") {
            return true
        }else{
            return false
        }
    }
    
    
    func scrollToBottom(scrollViewProxy: ScrollViewProxy){
        scrollViewProxy.scrollTo("Empty", anchor: .bottom)
    }
    
    func getThumbnailUrl(thumbnail: UIImage, chatID: String, completion: @escaping (String?, URL?) -> ()) {
        let dp = DispatchGroup()
        dp.enter()
        let fileName = "\(chatID)/VideoThumbnails/\(UUID().uuidString).mp4"
        let ref = Storage.storage().reference(withPath: fileName)
        guard let imageData = thumbnail.jpegData(compressionQuality: 0.5) else {return completion(nil, nil)}
        ref.putData(imageData, metadata: nil) { (metadata, err) in
            if err != nil{
                print("ERROR")
                return completion(nil, nil)
            }
            ref.downloadURL { (url, err) in
                if err != nil{
                    print("ERROR: Failed to retreive download URL")
                    return completion(nil, nil)
                }
                print("Successfully stored image in database")
                let imageURL = url?.absoluteString ?? ""
                let url =  URL(string: url?.absoluteString ?? "")
                dp.leave()
                dp.notify(queue: .main, execute: {
                    return completion(imageURL, url)
                })
            }
            
        }
    }
    
    func getThumbnailImageFromVideoRemoteUrl(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        }
        catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    func getChatColor(userID: String) -> String{
        var color = ""
        var nameColors = personalChatVM.chat.nameColors
        
        for index in nameColors{
            var keys = index.map{$0.key}
            var values = index.map{$0.value}
            
            for i in keys.indices {
                if keys[i] == userID{
                    color = values[i]
                }
            }
        }
        
        return color
    }
    @State private var offset: CGFloat = 0
    
  
    
    
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack{
                Color("Background")
                VStack{
                    HStack(alignment: .top){
                        //top bar
                        
                        
                        Button(action:{
                            presentationMode.wrappedValue.dismiss()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                            }
                        })
                        
                        
                        
                        
                        
                        Spacer()
                        
                        NavigationLink {
                            UserProfilePage(user: getPersonalChatUser())
                        } label: {
                            VStack{
                                WebImage(url: URL(string: getPersonalChatUser().profilePicture ?? ""))
                                    .resizable().placeholder{
                                        ProgressView()
                                    }
                                    .scaledToFill()
                                    .frame(width:50,height:50)
                                    .clipShape(Circle())
                                    .overlay{
                                        
                                        
                                        if  self.checkIfUserIsActive(){
                                            Circle().stroke(Color("AccentColor"), lineWidth: 3)
                                            
                                            
                                            
                                        }else{
                                            Circle().stroke(Color.gray, lineWidth: 3)
                                        }
                                        
                                        
                                    }
                                
                                Text("\(getPersonalChatUser().nickName ?? "")").bold().font(.headline)
                            }
                        }.foregroundColor(FOREGROUNDCOLOR)
                        
                        
                        Spacer()
                        
                        
                        Button(action:{
                            self.showSettingsView.toggle()
                        },label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR)
                            }
                        }).sheet(isPresented: $showSettingsView) {
                            
                        } content: {
                            PersonalChatSettingsView()
                        }

                       
                        
                        
                        
                    }.padding(.top,50).padding(.horizontal)
                    
                    
                    ZStack(alignment: .bottomTrailing){
                        
                        Color("Background")
                        ScrollViewReader{ scrollViewProxy in
                        ScrollView
                        {
                            PullToRefreshView() {
//                                if  personalChatVM.documentsLeftToFetch > 0 && personalChatVM.lastDocument != nil {
//                                    DispatchQueue.main.async{
//                                        personalChatVM.fetchMoreMessages(chatID: chatID)
//                                    }
//                                }
                                personalChatVM.increasePageSize(chatID: chatID)
                            }
                                VStack(spacing: 0){
                                    if personalChatVM.isLoading{
                                        ProgressView()
                                    }
                                    
                                    ForEach(personalChatVM.messages.indices, id: \.self){ index in
                                        MessageCell(previousMessage: index != 0 ? personalChatVM.messages[index-1] : nil,message: personalChatVM.messages[index], selectedMessage: $selectedMessage,
                                                        showOverlay: $showOverlay, personalChatVM: personalChatVM).disabled(isLeavingChat).environmentObject(userVM)
                                        }
                                    
                                    
                                    VStack{
                                        ForEach(personalChatVM.chat.usersTyping){ user in
                                            HStack{
                                                if user.id == userVM.user?.id ?? " "{
                                                    Text("You are typing").foregroundColor(Color("AccentColor")).bold()
                                                }else{
                                                    Text("\(user.nickName ?? "") is typing...").foregroundColor(Color("AccentColor")).bold()
                                                }
                                                Spacer()
                                            }.padding(5)
                                        }
                                    }
                                    Spacer()
                                    HStack{Spacer()}.padding(0).id("Empty")
                                }.background(GeometryReader{ proxy -> Color in
                                    DispatchQueue.main.async{
                                        scrollViewOffset = -proxy.frame(in: .named("scroll")).origin.y
                                    }
                                    return Color.clear
                                    
                                }).padding(5).onReceive(personalChatVM.$scrollToBottom, perform: { _ in
                                    withAnimation(.easeOut(duration: 0.5)){
                                        self.scrollToBottom(scrollViewProxy: scrollViewProxy)
                                    }
                                }).offset(y: -keyboardHeight)
                            }
                        
                        }.coordinateSpace(name: "scroll")
                        
                        
                        
                        
                        
                        
                        
                        Button(action:{
                            personalChatVM.scrollToBottom += 1
                        },label:{
                            ZStack{
                                Circle().frame(width: 30, height: 30).foregroundColor(Color("AccentColor"))
                                Image(systemName: "chevron.down").foregroundColor(FOREGROUNDCOLOR)
                            }
                        }).padding(10).offset(y: -keyboardHeight)
                        
                    }.edgesIgnoringSafeArea(.all)
                    
                    
                    
                    
                    
                    Spacer()
                    
                    
                    VStack{
                        if showReplyView {
                            HStack{
                                VStack(alignment: .leading, spacing: 3){
                                    HStack(spacing: 3){
                                        if selectedMessage.userID == userVM.user?.id ?? ""{
                                            Image(systemName: "chevron.left").foregroundColor(Color("AccentColor")).frame(width:2).padding(.horizontal,5)
                                            Text("Me").foregroundColor(Color("AccentColor"))
                                        }else{
                                            Image(systemName: "chevron.left").foregroundColor(Color("blue")).frame(width:2).padding(.horizontal,5)
                                            Text("\(selectedMessage.name ?? "")").foregroundColor(Color("blue"))
                                        }
                                        Spacer()
                                    }
                                    
                                    HStack{
                                        
                                        
                                        HStack{
                                            
                                            switch selectedMessage.type ?? "" {
                                                
                                                case "image":
                                                    WebImage(url: URL(string: selectedMessage.value ?? " ")).resizable()
                                                        .scaledToFill()
                                                        .frame(width: UIScreen.main.bounds.width/3.5, height: 200)
                                                        .clipped()
                                                        .cornerRadius(12)
                                                    
                                                case "multipleImages":
                                                    ForEach(selectedMessage.urls ?? [], id: \.self) { image in
                                                        WebImage(url: URL(string: image)).resizable()
                                                            .scaledToFill()
                                                            .frame(width: UIScreen.main.bounds.width/3.5, height: 200)
                                                            .clipped()
                                                            .cornerRadius(12)
                                                    }
                                                    
                                                case "text", "followUpUserText", "followUpUserReplyText" , "repliedMessage":
                                                    Text("\(selectedMessage.value ?? "")").foregroundColor(FOREGROUNDCOLOR).lineLimit(5)
                                                default:
                                                    Text("Failed data")
                                            }
                                            
                                        
                                            if selectedMessage.edited ?? false{
                                                Text("(edited)").foregroundColor(.gray).font(.footnote)
                                            }
                                        }
                                        
                                        
                                        
                                        Spacer()
                                        
                                        
                                    }
                                    
                                    
                                    
                                }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background"))).padding(10)
                                Button(action:{
                                    withAnimation{
                                        self.showReplyView.toggle()
                                    }
                                },label:{
                                    ZStack{
                                        Circle().frame(width: 40, height: 40).foregroundColor(Color("Background"))
                                        Image(systemName: "xmark").foregroundColor(FOREGROUNDCOLOR)
                                    }
                                }).padding(.trailing,5)
                            }
                        }
                        Divider()
                        if urls.isEmpty{
                            HStack(alignment: .bottom){
                                
                                Button(action:{
                                },label:{
                                    ZStack{
                                        Circle().frame(width:35, height:35).foregroundColor(Color("Background"))
                                        Image(systemName: "camera").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                                    }
                                })
                                
                                
                                
                                Button(action:{
                                    self.urls = []
                                    self.selectedThumbnailImages = []
                                    self.isShowingMediaPicker.toggle()
                                },label:{
                                    ZStack{
                                        Circle().foregroundColor(Color("Background")).frame(width: 35, height: 35)
                                        Image(systemName: "photo.on.rectangle.angled").foregroundColor(FOREGROUNDCOLOR).font(.headline)
                                    }
                                })
//                                .mediaImporter(isPresented: $isShowingMediaPicker, allowedMediaTypes: .all, allowsMultipleSelection: true) { result in
//                                    switch result {
//                                        case .success(let urls):
//                                            self.urls = urls
//                                        case .failure(let error):
//                                            print(error)
//                                            self.urls = []
//                                            self.selectedThumbnailImages = []
//                                    }
//                                }
                                
                                Spacer()
//                                OmenTextField("Send a text..",text: $personalChatVM.text, returnKeyType: personalChatVM.text == "" ? .done : .send , onCommit: {
//                                    if personalChatVM.text != "" {
//
//                                       let lastMessageDate = personalChatVM.getLastMessage().timeStamp?.dateValue() ?? Date()
//                                        if Calendar.current.dateComponents([.day], from: lastMessageDate, to: Date()).day == 1 {
//                                            personalChatVM.sendNewDayMessage(chatID: chatID)
//                                        }
//                                        if showReplyView{
//                                            personalChatVM.sendReplyTextMessage(text: personalChatVM.text, user: userVM.user ?? User(), nameColor: self.getChatColor(userID: userVM.user?.id ?? " "), repliedMessageID: selectedMessage.id, messageType: personalChatVM.getLastMessage().userID == USER_ID ? "followUpUserReplyText" : "repliedMessage", chatID: personalChatVM.chat.id)
//                                            withAnimation{
//                                                self.showReplyView.toggle()
//                                            }
//                                        }else{
//                                            personalChatVM.sendTextMessage(text: personalChatVM.text, user: userVM.user ?? User(), timeStamp: Timestamp(), nameColor: self.getChatColor(userID: userVM.user?.id ?? " "), messageID: UUID().uuidString, messageType: "text", chatID: personalChatVM.chat.id, completion: { sent in
//                                                if sent{
//                                                    print("sent")
//                                                }else{
//                                                    print("failed to send")
//                                                }
//                                            })
//                                        }
//
//
//                                        if !personalChatVM.chat.usersIdlingID.contains(self.getPersonalChatUser().id ?? ""){
//                                            self.notificationSender.sendPushNotification(to: self.getPersonalChatUser().fcmToken ?? " ", title: userVM.user?.nickName ?? " ", body: personalChatVM.text)
//                                        }
//
//                                        DispatchQueue.main.async{
//
//                                            personalChatVM.scrollToBottom += 1
//                                        }
//
//
//
//
//                                    }
//                                    DispatchQueue.main.async{
//                                        withAnimation{
//                                            self.keyboardHeight = 0
//                                            UIApplication.shared.windows.forEach { $0.endEditing(true)}
//                                        }
//
//                                    }
//
//
//
//
//                                } ,canAddAnotherLine: $canAddAnotherLine, hasMicrophone: false).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                                
                                
                                Button(action:{
                                    self.showAddContent.toggle()
                                },label:{
                                    ZStack{
                                        Circle().frame(width:35, height:35).foregroundColor(Color("Background"))
                                        Image(systemName: "plus").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                                    }
                                })
                            }.padding().padding(.bottom,10).onReceive(personalChatVM.$text) { text in
                                if text != "" {
                                    personalChatVM.startTyping(userID: USER_ID, chatID: chatID)
                                }else{
                                    personalChatVM.stopTyping(userID: USER_ID, chatID: chatID)
                                }
                            }
                            
                        }else{
                            HStack(alignment: .top, spacing: 4){
                                if isLoadingMedia{
                                    VStack{
                                        Text("Loading Media").foregroundColor(Color.gray)
                                        ProgressView()
                                    }
                                }else{
                                    if personalChatVM.sendingMedia{
                                        
                                        if personalChatVM.failedToSend {
                                            HStack{
                                                Spacer()
                                                VStack{
                                                    Text("Failed to send media").foregroundColor(Color.red)
                                                    Button(action:{
                                                        personalChatVM.failedToSend = false
                                                        personalChatVM.sendingMedia = false
                                                    },label:{
                                                        Text("Try again?")
                                                    })
                                                }
                                                Spacer()
                                            }
                                        }else{
                                            VStack{
                                                Text("Sending Media...").foregroundColor(FOREGROUNDCOLOR)
                                                VStack(alignment: .leading){
                                                    if !images.isEmpty{
                                                        Text("\(personalChatVM.imagesSent) out of \(images.count) images sent").foregroundColor(Color.gray)
                                                    }
                                                    if !videos.isEmpty{
                                                        Text("\(personalChatVM.videosSent) out of \(videos.count) videos sent").foregroundColor(Color.gray)
                                                    }
                                                }
                                            }
                                        }
                                       
                                        
                                    }else{
                                        Button(action:{
                                            //todo
                                            withAnimation{
                                                self.urls = []
                                                self.selectedThumbnailImages = []
                                                self.images = []
                                                self.videos = []
                                            }
                                        },label:{
                                            Image(systemName: "xmark").font(.title).foregroundColor(Color.red)
                                        })
                                        ScrollView(.horizontal, showsIndicators: false){
                                            HStack{
                                                ForEach(images, id: \.self){ image in
                                                    Image(uiImage: image).resizable().scaledToFill().frame(width: 50, height: 50).clipped().cornerRadius(12)
                                                    
                                                }
                                                
                                                ForEach(0..<selectedThumbnailImages.count, id: \.self) { index in
//                                                    VideoThumbnailImage(videoUrl: videos[index], width: 50, height: 50).cornerRadius(12)
                                                    
                                                    Image(uiImage: selectedThumbnailImages[index]).resizable().scaledToFit().frame(width: 50, height: 50).clipped().cornerRadius(12)
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                
                                if !personalChatVM.sendingMedia {
                                    Spacer()
                                    Button(action:{
                                        //todo
                                        let dp = DispatchGroup()
                                        personalChatVM.sendingMedia = true
                                        if !images.isEmpty{
                                            
                                            if images.count == 1 {
                                                personalChatVM.sendImageMessage(image: images[0], user: userVM.user ?? User()) { sentImage in
                                                    if sentImage{
                                                        personalChatVM.finishedSendingImages = true
                                                    }else{
                                                        personalChatVM.failedToSend = true
                                                    }
                                                }
                                            }else{
                                                personalChatVM.sendMultipleImagesMessage(images: images, user: userVM.user ?? User()) { sentImages in
                                                    personalChatVM.finishedSendingImages = true
                                                }
                                            }
                                            
                                            
                                        }
                                        
                                        if !videos.isEmpty{
                                            if videos.count == 1 {
                                                
                                                self.getThumbnailUrl(thumbnail: selectedThumbnailImages[0], chatID: personalChatVM.chat.id) { string , _ in
                                                    if let string = string{
                                                        personalChatVM.sendVideoMessage(thumbnailUrlString: string  , videoUrl: videos[0], user: userVM.user ?? User()) { sentVideo in
                                                            personalChatVM.finishedSendingVideos = true
                                                        }
                                                    }else{
                                                        //todo there was an error
                                                        print("unable to get thumbnail image of video")
                                                        personalChatVM.finishedSendingVideos = true

                                                    }
                                                }
                                                
                                                
                                               
                                            }else{
                                               
                                                for thumbnail in
                                                        selectedThumbnailImages{
                                                    dp.enter()
                                                    self.getThumbnailUrl(thumbnail: thumbnail, chatID: personalChatVM.chat.id) { _, url in
                                                        if let url = url{
                                                            selectedThumbnailUrls.append(url)
                                                            dp.leave()
                                                        }else{
                                                            //todo there was an error
                                                            dp.leave()
                                                        }
                                                    }
                                                }
                                                dp.notify(queue: .main, execute: {
                                                    personalChatVM.sendMultipleVideosMessage(thumbnailUrls: selectedThumbnailUrls, videoUrls: videos, user: userVM.user ?? User()) { sentVideos in
                                                        personalChatVM.finishedSendingVideos = true
                                                    }
                                                })

                                            }
                                            
                                        }
                                      
                                        
                                    },label:{
                                        Image(systemName: "play.fill").font(.largeTitle).foregroundColor(Color("AccentColor"))
                                    }).disabled(isLoadingMedia)
                                }
                                
                            }.padding().padding(.bottom,30)
                        }
                        
                    }.background(Color("Color")).offset(y: -self.keyboardHeight)
                    
                }.opacity(userVM.hideBackground ? 0.2 : 1).disabled(userVM.hideBackground).onTapGesture(perform: {
                    if userVM.hideBackground {
                        userVM.hideBackground.toggle()
                    }
                    if self.showAddContent{
                        self.showAddContent.toggle()
                    }
                    if self.showOverlay{
                        self.showOverlay.toggle()
                    }
                    if self.showEditView{
                        self.showEditView.toggle()
                    }
                }).overlay {
                    if self.showOverlay{
                        VStack{
                            VStack(alignment: .leading, spacing: 5){
                                HStack{
                                    if selectedMessage.userID == userVM.user?.id ?? " "{
                                        Text("Me").foregroundColor(Color("AccentColor"))
                                    }else{
                                        Text("\(selectedMessage.name ?? " ")").foregroundColor(Color.blue)
                                    }
                                    Spacer()
                                    Text("\(selectedMessage.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                                }
                                HStack{
                                    Text("\(selectedMessage.value ?? "")").foregroundColor(FOREGROUNDCOLOR).lineLimit(5)
                                    if selectedMessage.edited ?? false{
                                        Text("(edited)").foregroundColor(.gray).font(.footnote)
                                    }
                                    
                                    Spacer()
                                }
                                HStack{
                                    
                                    
                                    
                                    if (personalChatVM.chat.usersThatHaveSeenLastMessage?.contains(self.getPersonalChatUser().id ?? "") ?? false){
                                        HStack(alignment: .center){
                                            
                                            Image(systemName: "play").foregroundColor(Color("AccentColor")).font(.caption)
                                            Text("Read").foregroundColor(Color.gray).font(.subheadline)
                                            
                                            
                                        }
                                        
                                        
                                        
                                    }else{
                                        HStack(alignment: .center){
                                            
                                            
                                            Image(systemName: "play.fill").foregroundColor(Color("AccentColor")).font(.caption)
                                            
                                            Text("Delivered").foregroundColor(Color.gray).font(.subheadline)
                                            
                                            
                                            
                                            
                                        }
                                        
                                    }
                                    
                                    
                                    
                                    Spacer()
                                }
                            }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color("Color")))
                            
                            if selectedMessage.userID == userVM.user?.id ?? "" {
                                VStack(alignment: .leading){
                                    Button(action:{
                                        withAnimation{
                                            self.showEditView.toggle()
                                            self.showOverlay.toggle()
                                            editText = self.selectedMessage.value ?? ""
                                            self.focused = true
                                        }
                                        
                                    },label:{
                                        HStack{
                                            Text("Edit")
                                            Spacer()
                                        }.foregroundColor(FOREGROUNDCOLOR)
                                    })
                                    Divider()
                                    Button(action:{
                                        withAnimation{
                                            self.showReplyView.toggle()
                                            self.showOverlay.toggle()
                                            userVM.hideBackground.toggle()
                                        }
                                        
                                    },label:{
                                        HStack{
                                            Text("Reply")
                                            Spacer()
                                        }
                                    }).foregroundColor(FOREGROUNDCOLOR)
                                    Divider()
                                    Button(action:{
                                        withAnimation{
                                            personalChatVM.deleteMessage(messageID: selectedMessage.id, chatID: personalChatVM.chat.id, user: userVM.user ?? User())
                                            self.showOverlay.toggle()
                                            userVM.hideBackground.toggle()
                                        }
                                        
                                        
                                    },label:{
                                        HStack{
                                            Text("Delete")
                                            Spacer()
                                        }
                                    }).foregroundColor(FOREGROUNDCOLOR)
                                    
                                }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color("Color")))
                            }else{
                                VStack{
                                    Button(action:{
                                        self.showReplyView.toggle()
                                        self.showOverlay.toggle()
                                        userVM.hideBackground.toggle()
                                    },label:{
                                        HStack{
                                            Text("Reply")
                                            Spacer()
                                        }
                                    }).foregroundColor(FOREGROUNDCOLOR)
                                }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color("Color")))
                                
                            }
                            
                            
                        }.frame(width: UIScreen.main.bounds.width-20)
                        
                    }
                    if showEditView{
                        VStack(alignment: .leading, spacing: 5){
                            HStack{
                                if selectedMessage.userID == userVM.user?.id ?? " "{
                                    Text("Me").foregroundColor(Color("AccentColor"))
                                }else{
                                    Text("\(selectedMessage.name ?? " ")").foregroundColor(Color.blue)
                                }
                                Spacer()
                                Text("\(selectedMessage.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                            }
                            
                            HStack{
                                TextField("\(selectedMessage.value ?? "")", text: $editText).padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                                
                                Button(action:{
                                    personalChatVM.editMessage(messageID: selectedMessage.id, chatID: personalChatVM.chat.id, text: editText)
                                    self.editText = ""
                                    self.showEditView.toggle()
                                    userVM.hideBackground.toggle()
                                },label:{
                                    Text("Send").padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Background")))
                                }).disabled(self.editText == "")
                            }
                            
                            
                        }.padding(10).background(RoundedRectangle(cornerRadius: 8).fill(Color("Color"))).frame(width: UIScreen.main.bounds.width-20)
                    }
                }
                
                
                
                BottomSheetView(isOpen: $showAddContent, maxHeight: UIScreen.main.bounds.height / 3) {
                    ChatAddContent(showAddContentView: $showAddContent, showAddEventView: $showAddEventView)
                }
                
                
                
            }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).frame(width: geometry.size.width, height: geometry.size.height)
                .offset(x: self.offset)
                .opacity(Double(1 - abs(self.offset / geometry.size.width)))
                .simultaneousGesture(DragGesture()
                    .onChanged { gesture in
                        if gesture.translation.width > 30 && self.urls.isEmpty{
                            isLeavingChat = true
                            UIApplication.shared.windows.forEach { $0.endEditing(true)}
                            self.offset = gesture.translation.width
                        }
                        if abs(self.offset) > geometry.size.width / 3 {
                            if !reachedHalfway{
                                reachedHalfway = true
                                UIDevice.vibrate()
                            }
                        }else{
                            reachedHalfway = false
                        }
                        
                    }
                    .onEnded { gesture in
                        if reachedHalfway {
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            withAnimation{
                                self.offset = 0
                                isLeavingChat = false
                                reachedHalfway = false
                            }
                        }
                    }
                )
        }
        .onAppear{
            personalChatVM.listenToMessages(chatID: chatID)
            personalChatVM.readLastMessage(chatID: chatID, userID: userVM.user?.id ?? " ")
            personalChatVM.openChat(userID: userVM.user?.id ?? " ", chatID: chatID)
            self.initKeyboardGuardian()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                personalChatVM.scrollToBottom += 1
            }
            
            
        }.onDisappear{
            personalChatVM.exitChat(userID: userVM.user?.id ?? " ", chatID: chatID)
            personalChatVM.removeListeners()
        } .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                personalChatVM.openChat(userID: userVM.user?.id ?? " ", chatID: chatID)
            }else if newPhase == .background{
                personalChatVM.exitChat(userID: userVM.user?.id ?? " ", chatID: chatID)
            }
        }.onChange(of: urls) { newValue in
            if !newValue.isEmpty {
                // Create a dispatch group to wait for all downloads to finish
                isLoadingMedia = true
                let group = DispatchGroup()
                
                
                for url in urls {
                    
                    switch try! url.resourceValues(forKeys: [.contentTypeKey]).contentType! {
                        case let contentType where contentType.conforms(to: .image):
                            //if image
                            group.enter()
                            
                            // Create a URLSession data task for each URL
                            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                                if let error = error {
                                    print("Error downloading photo: \(error.localizedDescription)")
                                } else {
                                    if let data = data, let image = UIImage(data: data) {
                                        // Add the downloaded image to the array
                                        images.append(image)
                                    }
                                }
                                
                                group.leave()
                                
                            }
                            task.resume()
                        case let contentType where contentType.conforms(to: .audiovisualContent):
                            group.enter()
                            videos.append(url)
                            selectedThumbnailImages.append(self.getThumbnailImageFromVideoRemoteUrl(url: url) ?? UIImage())
                            group.leave()
                        default:
                            group.enter()
                            print("error")
                            group.leave()
                    }
                    
                    
                    
                    
                }
                
                // Wait for all downloads to finish before continuing
                group.notify(queue: DispatchQueue.main) {
                    withAnimation{
                        isLoadingMedia = false
                    }
                }
                
                
                
                
            }
        }.onReceive(personalChatVM.$finishedSendingVideos) { newValue in
            if images.isEmpty && newValue || newValue && personalChatVM.finishedSendingImages {
                withAnimation{
                    self.urls = []
                    self.selectedThumbnailImages = []
                    self.videos = []
                    self.images = []
                    personalChatVM.sendingMedia = false
                    personalChatVM.imagesSent = 0
                    personalChatVM.videosSent = 0
                }
            }
        }.onReceive(personalChatVM.$finishedSendingImages) { newValue in
            if videos.isEmpty && newValue || newValue && personalChatVM.finishedSendingVideos {
                withAnimation{
                    self.urls = []
                    self.selectedThumbnailImages = []
                    self.videos = []
                    self.images = []
                    personalChatVM.sendingMedia = false
                    personalChatVM.imagesSent = 0
                    personalChatVM.videosSent = 0
                }
            }
        }
        
        
    }
    
    
}




extension View {
    func endEditing(_ force: Bool = true) {
        UIApplication.shared.windows.forEach { $0.endEditing(force)}
    }
    func delaysTouches(for duration: TimeInterval = 0.25, onTap action: @escaping () -> Void = {}) -> some View{
        modifier(DelaysTouches(duration: duration, action: action))
    }
}

fileprivate struct DelaysTouches: ViewModifier {
    @State private var disabled = false
    @State private var touchDownDate: Date? = nil
    
    var duration: TimeInterval
    var action: () -> Void
    
    func body(content: Content) -> some View {
        Button {
            action()
        } label: {
            content
        }.buttonStyle(DelaysTouchesButtonStyle(disabled: $disabled, duration: duration, touchDownDate: $touchDownDate))
            .disabled(disabled)
        
    }
}

fileprivate struct DelaysTouchesButtonStyle : ButtonStyle {
    @Binding var disabled: Bool
    var duration: TimeInterval
    @Binding var touchDownDate: Date?
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.onChange(of: configuration.isPressed, perform: handleIsPressed)
    }
    
    private func handleIsPressed(isPressed: Bool){
        if isPressed{
            let date = Date()
            touchDownDate = date
            
            DispatchQueue.main.asyncAfter(deadline: .now() + max(duration, 0), execute: {
                if date == touchDownDate{
                    disabled = true
                    
                    DispatchQueue.main.async{
                        disabled = false
                    }
                }
            })
        }else{
            touchDownDate = nil
            disabled = false
        }
    }
}


struct PullToRefreshView: View
{
    private static let minRefreshTimeInterval = TimeInterval(0.2)
    private static let triggerHeight = CGFloat(50)
    private static let indicatorHeight = CGFloat(50)
    private static let fullHeight = triggerHeight + indicatorHeight
    
    let backgroundColor: Color
    let foregroundColor: Color
    let isEnabled: Bool
    let onRefresh: () -> Void
    
    @State private var isRefreshIndicatorVisible = false
    @State private var refreshStartTime: Date? = nil
    
    init(bg: Color = .clear, fg: Color = .white, isEnabled: Bool = true, onRefresh: @escaping () -> Void)
    {
        self.backgroundColor = bg
        self.foregroundColor = fg
        self.isEnabled = isEnabled
        self.onRefresh = onRefresh
    }
    
    var body: some View
    {
        VStack(spacing: 0)
        {
            LazyVStack(spacing: 0)
            {
                Color.clear
                    .frame(height: Self.triggerHeight)
                    .onAppear
                    {
                        if isEnabled
                        {
                            withAnimation
                            {
                                isRefreshIndicatorVisible = true
                            }
                            refreshStartTime = Date()
                        }
                    }
                    .onDisappear
                    {
                        if isEnabled, isRefreshIndicatorVisible, let diff = refreshStartTime?.distance(to: Date()), diff > Self.minRefreshTimeInterval
                        {
                            onRefresh()
                        }
                        withAnimation
                        {
                            isRefreshIndicatorVisible = false
                        }
                        refreshStartTime = nil
                    }
            }
            .frame(height: Self.triggerHeight)
            
            indicator
                .frame(height: Self.indicatorHeight)
        }
        .background(backgroundColor)
        .ignoresSafeArea(edges: .all)
        .frame(height: Self.fullHeight)
        .padding(.top, -Self.fullHeight)
    }
    
    private var indicator: some View
    {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: foregroundColor))
            .opacity(isRefreshIndicatorVisible ? 1 : 0)
    }
}


struct PersonalChatSettingsView : View {
    @State var silenceNotifications = false
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Spacer()
                    Text("Chat Settings")
                    Spacer()
                }.padding(.top,50).padding(.horizontal)
                VStack(alignment: .leading){
                    Toggle("Silence Notifications", isOn: $silenceNotifications)
                }
            }
        }.onChange(of: silenceNotifications) { newValue in
            if newValue{
                
            }else{
                
            }
        }
    }
}
