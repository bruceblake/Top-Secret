////
////  GalleryPostCommentView.swift
////  TopSecret
////
////  Created by Bruce Blake on 3/1/22.
////
//
//import SwiftUI
//import SDWebImageSwiftUI
//
//struct GalleryPostCommentView: View {
//    
//    @EnvironmentObject var userVM: UserViewModel
//    @StateObject var galleryVM = GalleryRepository()
//    @State var value : CGFloat = 0
//    @Binding var galleryPost : GalleryPostModel
//    @Binding var comments : [GalleryPostCommentModel]
//    @State var text: String = ""
//    @State var blur: Bool = false
//    @Environment(\.presentationMode) var presentationMode
//    var body: some View {
//        
//        VStack(spacing: 0){
//        ZStack(alignment: .topLeading){
//            Color("Background")
//            VStack{
//                
//               
//                VStack{
//                    
//                    HStack{
//                        Spacer()
//                        Text("\(comments.count) comments").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
//                        Spacer()
//                        Button(action:{
//                            
//                        },label:{
//                            Image(systemName: "slider.horizontal.3").frame(width: 30, height: 30).foregroundColor(FOREGROUNDCOLOR)
//                        }).padding(.trailing,3)
//                    }.padding(.vertical,2)
//                    ScrollView{
//                        
//                        LazyVStack{
//                           
////                            ForEach(comments.indices, id: \.self){  index in
////                                GalleryPostCommentCell(comment: $comments[index], rank: index+1).padding(.horizontal,10).padding(.vertical,10)
////                            }
//                          
//                        }
//                    }
//                }.padding(.top,UIScreen.main.bounds.height/1.9)
//               
//                
//            
//            }
//            
//            VStack(spacing: 0){
//                
//                HStack{
//                    Button(action:{
//                        presentationMode.wrappedValue.dismiss()
//                    },label:{
//                        ZStack{
//                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Background"))
//                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
//                        }
//                    })
//                    Spacer()
//                    Text("Comments").font(.title).padding(.trailing,10)
//                    Spacer()
//                }.padding(.horizontal).padding(.top,45).background(Color("Color"))
//            
//  
//                
//                    ScrollView(.horizontal,showsIndicators: false){
//                        HStack{
//                            ForEach(galleryPost.posts ?? [], id: \.self){ post in
//                                WebImage(url: URL(string: post)).resizable().frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2.5).cornerRadius(16).padding(.vertical)
//
//                            }
//                        }
//                      
//                    }
//                 
//                
//            
//            
//            }.cornerRadius(16).background(Color("Color"))
//            
//          
//
//        }.opacity(blur ? 0.25 : 1).onTapGesture {
//            self.blur = false
//            self.value = 0
//            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//        }
//            
//            ZStack(alignment: .bottomLeading){
//                HStack{
//                    WebImage(url: URL(string: userVM.user?.profilePicture ?? "")).resizable().frame(width:30,height:30).clipShape(Circle()).padding(.leading,5)
//                    HStack{
//                        TextField("add comment...", text: $text).padding(.leading,5)
//                        Spacer()
//                        Button(action:{
//                            
//                            
//                            galleryVM.addComment(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ", userID: userVM.user?.id ?? " ", text: text)
//                           
//                            galleryVM.fetchPostComments(galleryID: galleryPost.id ?? " ", groupID: galleryPost.groupID ?? " ") { fetchedComments in
//                                comments = fetchedComments
//                            }
//                            
//                            text = ""
//                        },label:{
//                            Text("Send").disabled(text == "")
//                        }).padding(.trailing,4)
//                    }.padding(.vertical,8).background(Color("Background")).cornerRadius(12).padding(5)
//                   
//                }.padding([.horizontal,.bottom],5).padding(.vertical).background(Color("Color")).offset(y: -self.value).animation(.spring()).onAppear{
//                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
//                        let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
//                        let height = value.height
//                        self.value = height
//                        self.blur = true
//                    }
//                    
//                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
//                        
//                        self.value = 0
//                        self.blur = false
//                    }
//                }
//            }.background(Color("Color"))
//    }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
//    }
//}
//
////struct GalleryPostCommentView_Previews: PreviewProvider {
////    static var previews: some View {
////        GalleryPostCommentView()
////    }
////}
