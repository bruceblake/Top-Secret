//
//  CreatePassword.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct CreatePassword: View {
    @State var password: String = ""
    @State var showErrorMessage:Bool = false
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var registerVM : RegisterValidationViewModel
    @State var showContentScreen : Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack{
            
            Color("Background")
            VStack{
                
                HStack{
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    }

                  
                    Spacer()
                    Circle().frame(width: 40, height: 40).foregroundColor(Color.clear)
                }.padding(.horizontal).padding(.top,50)
                
                Text("Create A Password").foregroundColor(Color("Foreground")).font(.largeTitle).fontWeight(.bold).padding(.horizontal)
                
                Text("Make sure your password is secure").font(.headline).padding(.bottom,30)
                
                
                
                
                CustomTextField(text: $registerVM.password, placeholder: "Password", isPassword: true, isSecure: true, hasSymbol: true ,symbol: "lock").padding(.horizontal,20)
                
                if showErrorMessage{
                Text(registerVM.passwordErrorMessage).padding(.top,5).foregroundColor(registerVM.passwordErrorMessage == "Password is valid!" ? .green : .red)
                }
                
                Button(action: {
                    if registerVM.passwordErrorMessage == "Password is valid!"{
                        showContentScreen.toggle()
                        let dp = DispatchGroup()
                        self.showContentScreen.toggle()

                        dp.enter()

                        userVM.createUser(email: registerVM.email, username: registerVM.username, nickName: registerVM.nickName,  birthday: registerVM.birthday, password: registerVM.password, profilePicture: registerVM.userProfileImage, completion: { userCreated in
                            if userCreated{
                                dp.leave()
                            }
                        })
                        dp.notify(queue: .main) {
                            self.showContentScreen.toggle()

                        }
                    }else{
                        showErrorMessage = true
                    }
                }, label: {
                    Text("Create Account")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).opacity(showContentScreen ? 0.5 : 1).disabled(showContentScreen).onTapGesture(perform: {
            if showContentScreen{
                showContentScreen.toggle()
            }
        }).overlay{
            if showContentScreen {
                CreateUserOverlay()
                    .frame(width: UIScreen.main.bounds.width/1.5, height: UIScreen.main.bounds.height/3).cornerRadius(16)
                   
         
            }
        }.navigationBarHidden(true)
    }
}


struct CreateUserOverlay : View {
    
    @EnvironmentObject var registerVM : RegisterValidationViewModel
    
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                
                Spacer()
                
                HStack{
                    
                    Spacer()
                    VStack{
                        Text("Creating \(registerVM.username)")
                            .foregroundColor(FOREGROUNDCOLOR).font(.subheadline).bold()
                        ProgressView()
                    }
                    Spacer()
                }
                
             
               
                Spacer()
            }
        }
    }
}

