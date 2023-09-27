//
//  UserEditProfilePageView.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/4/22.
//

import SwiftUI
import SDWebImageSwiftUI
//import OmenTextField

struct UserEditProfilePageView: View {
   
    @State var bio: String = ""
    @State var username : String = ""
    @State var nickName: String = ""
    @Environment(\.presentationMode) var dismiss
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var userEditVM = UserEditProfileViewModel()
    @EnvironmentObject var registerValidation : RegisterValidationViewModel
    @State var showErrorMessage : Bool = false
    @State var isShowingPhotoPicker : Bool = false
    @State var avatarImage : UIImage = (UIImage(named: "Icon") ?? UIImage())
    @State var images : [UIImage] = []
    @State var showContentView : Bool = false
    @Binding var showEditPage : Bool
    @State var changedProfilePicture : Bool = false
    @State var storedUsername : Bool = false
    @State var canAddAnotherLine: Bool = true
  
    var body: some View {
        
       
        ZStack{
            Color("Background")
            VStack{
                
                HStack{
                    
                    Button(action:{
                        if userEditVM.didChangeUsername || userEditVM.didChangeBio || userEditVM.didChangeNickName || userEditVM.didChangeProfilePicture {
                            withAnimation(.spring()){
                                showContentView.toggle()
                            }
                        }else{
                        dismiss.wrappedValue.dismiss()
                        }
                    },label:{
                        
                        Text("Cancel").foregroundColor(FOREGROUNDCOLOR).padding(10).background(Capsule().fill(Color("Color")))
                        
                    }).padding(.leading,10)
                    
                    Spacer()
                    
                    Text("Edit Profile").font(.largeTitle).bold()
                    
                    Spacer()
                    
                    Button(action:{
                        
                        
                       let dp = DispatchGroup()
                        
                        dp.enter()
                        userEditVM.saving = true
                        if userEditVM.didChangeUsername{
                            userEditVM.changeUsername(userID: userVM.user?.id ?? " ", username: registerValidation.username)
                        }
                        
                        if userEditVM.didChangeBio{

                            userEditVM.changeBio(userID: userVM.user?.id ?? " ", bio: bio)
                        }
                        
                        if userEditVM.didChangeNickName{
                            userEditVM.changeNickname(userID: userVM.user?.id ?? " ", nickName: registerValidation.nickName)
                        }
                        
                        if userEditVM.didChangeProfilePicture {
                            userEditVM.changeProfilePicture(userID: userVM.user?.id ?? " ", image: avatarImage)
                        }

                        dp.leave()
                        dp.notify(queue: .main, execute:{
                            userEditVM.saving = false
                            dismiss.wrappedValue.dismiss()
                        })
                        
                    },label:{
                        if userEditVM.saving {
                            ProgressView().foregroundColor(registerValidation.usernameErrorMessage == "valid!" || !showErrorMessage ? Color("AccentColor") : .gray).padding(10).background(Capsule().fill(Color("Color")))
                        }else{
                            Text("Save").foregroundColor(registerValidation.usernameErrorMessage == "valid!" || !showErrorMessage ? Color("AccentColor") : .gray).padding(10).background(Capsule().fill(Color("Color")))
                        }
                       
                            
                    }).padding(.trailing,10).disabled(showErrorMessage && registerValidation.usernameErrorMessage != "valid!")
                    

                    
                }.padding(.top,50).padding(.bottom)
                
                
                VStack(alignment: .leading, spacing: 20){
                    
                    VStack{
                        HStack{
                            Text("Profile Picture").bold()
                            Spacer()
                        }.padding(.leading)
                        
                      
                        if userEditVM.didChangeProfilePicture{
                            Image(uiImage: avatarImage) .resizable()
                                .scaledToFill()
                                .frame(width:50,height:50)
                                .clipShape(Circle())
                        }else{
                            WebImage(url: URL(string: userVM.user?.profilePicture ?? ""))
                                .resizable()
                                .scaledToFill()
                                .frame(width:50,height:50)
                                .clipShape(Circle())
                        }
                         
                      
                        Button(action:{
                            self.isShowingPhotoPicker.toggle()
                            self.changedProfilePicture = true
                        },label:{
                            Text("Change Profile Picture")
                        }).fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                            ImagePicker(avatarImage: $avatarImage,allowsEditing: true)
                        })
                    }
                    
                VStack{
                    HStack{
                        Text("Username").bold()
                        Spacer()
                        Text("\(registerValidation.username.count)/15").foregroundColor(registerValidation.username.count < 16 ? .gray : .red).font(.caption).padding(.trailing)
                    }.padding(.leading)
                    CustomTextField(text: $registerValidation.username, placeholder: "\(userVM.user?.username ?? "")", isPassword: false, isSecure: false, hasSymbol: false, symbol: "").foregroundColor(FOREGROUNDCOLOR)
                    if showErrorMessage{
                    Text("\(registerValidation.usernameErrorMessage)").padding(.top,5).foregroundColor(registerValidation.usernameErrorMessage == "valid!" ? .green : .red)
                    }
                }
                    
                    VStack{
                        HStack{
                            Text("Nickname").bold()
                            Spacer()
                        }.padding(.leading)
                        CustomTextField(text: $registerValidation.nickName, placeholder: "\(userVM.user?.nickName ?? "")", isPassword: false, isSecure: false, hasSymbol: false, symbol: "").foregroundColor(FOREGROUNDCOLOR)
                    }
                
                VStack{
                    HStack{
                        HStack{
                            Text("Bio")
                            Text("\(bio.count)/210").foregroundColor(bio.count < 211 ? .gray : .red).font(.caption).padding(.trailing)
                        }
                        Spacer()
                    }.padding(.leading)
              
//                    OmenTextField("\(userVM.user?.bio ?? " ")", text: $bio, canAddAnotherLine: $canAddAnotherLine).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).padding(.horizontal)
                    
                   
                }
                    
                  
                }
                
                        
                    
                
         
                Spacer()
                
               
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).opacity(showContentView ? 0.2 : 1).disabled(showContentView).overlay{
            if showContentView{
                SaveChangesOverlay(showContentView: $showContentView, dismiss: $showEditPage).frame(width: UIScreen.main.bounds.width/1.2,height: UIScreen.main.bounds.height/7).cornerRadius(16)
            }
        }.onReceive(registerValidation.$username) { newValue in
            if storedUsername{
                if newValue != userVM.user?.username ?? "" {
                    showErrorMessage = true
                }else{
                    showErrorMessage = false
                }
                userEditVM.didChangeUsername = true
            }
  

        }.onChange(of: avatarImage){ newValue in
            if changedProfilePicture {
                userEditVM.didChangeProfilePicture = true
            }
        }
        .onChange(of: registerValidation.nickName) { newValue in
            if storedUsername {
                userEditVM.didChangeNickName = true
            }
        }.onChange(of: bio) { newValue in
            userEditVM.didChangeBio = true
        }.onAppear{
            
            let dp = DispatchGroup()
            
            dp.enter()
            registerValidation.username = userVM.user?.username ?? " "
            registerValidation.nickName = userVM.user?.nickName ?? " "
            dp.leave()
            
            dp.notify(queue: .main, execute: {
            self.storedUsername = true
            })
        }
        
    }
}


struct SaveChangesOverlay : View {
    
    @Binding var showContentView : Bool
    @Binding var dismiss : Bool
    
    var body: some View {
   
                    VStack(spacing: 10){
                        
                        Text("You have unsaved changes")
                            .foregroundColor(FOREGROUNDCOLOR).font(.headline).bold()
                        
                        
                        HStack(spacing: 10){
                            Button(action:{
                                showContentView.toggle()
                                dismiss.toggle()
                            },label:{
                                Text("Discard Changes").font(.subheadline).padding(5).padding(.horizontal).background(RoundedRectangle(cornerRadius: 10).fill(Color("Background"))).foregroundColor(Color.red).lineLimit(1)
                            })
                            
                            
                            Button(action:{
                                showContentView.toggle()
                            },label:{
                                Text("Keep Editing").font(.subheadline).padding(5).padding(.horizontal).background(RoundedRectangle(cornerRadius: 10).fill(Color("Background"))).foregroundColor(Color("AccentColor"))
                            })
                        }
                        
                        
                    }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
    }
}

