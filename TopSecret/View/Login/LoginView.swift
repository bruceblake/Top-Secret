//
//  LoginView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/3/21.
//

import SwiftUI

struct LoginView: View {
    @State var email = ""
    @State var password = ""
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var validationVM : RegisterValidationViewModel
    @StateObject var userCoreDataVM = UserCoreDataViewModel()
    @State var showForgotPasswordView = false
    @State var beginRegisterView: Bool = false
    @State var value: CGFloat = 0
    @State var showContentScreen : Bool = false
    var body: some View {
        
        NavigationView {
            ZStack{
                //Background color
                Color("Background")
                
                //Overal VStack
                VStack{
                    
                    
                    Spacer()
                    
                    
                    //Icon and Name
                    VStack(spacing: 0){
                        
                        
                        Image("topbarlogo").resizable().frame(width: 200, height: 200)
                        Text("Top Secret")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Color("Foreground"))
                        
                    }
                    
                    VStack(spacing: 10){
                        
                        Text(userVM.loginErrorMessage).foregroundColor(.red)
                        
                        //Text Fields
                        VStack(spacing: 20){
                            CustomTextField(text: $email, placeholder: "Email", isPassword: false, isSecure: false, hasSymbol: true,  symbol: "envelope")
                            CustomTextField(text: $password, placeholder: "Password", isPassword: true, isSecure: true, hasSymbol: true, symbol: "key")
                            
                            
                        }.padding(.horizontal)
                        //Forgot Password
                        HStack{
                            
                           
                          
                            
                            Spacer()
                            
                            Button(action: {
                                showForgotPasswordView = true
                            },label: {
                                Text("Forgot Password?").foregroundColor(Color("AccentColor")).font(.system(size: 12)).padding(.trailing,30)
                            })
                            
                        }
                        
                        Button(action: {
                            let dp = DispatchGroup()
                            self.showContentScreen.toggle()
                            dp.enter()
                            userVM.signIn(withEmail: email, password: password, completion: { fetchedUser in
                                userCoreDataVM.addUser(user: fetchedUser)
                                dp.leave()
                            })
                            
                            dp.notify(queue: .main, execute: {
                                self.showContentScreen.toggle()
                            })
                        }, label: {
                            Text("Login")   .foregroundColor(Color("Foreground"))
                                .padding(.vertical)
                                .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                        }).padding(.top,15)
                            .sheet(isPresented: $showForgotPasswordView, content: {
                                ForgotPasswordView(showForgotPasswordView: $showForgotPasswordView)
                            })
                        
                    }.padding(.top,50)
                    
                    Spacer()


                    HStack{
                        Spacer()
                        Text("Don't have an account?").font(.system(size: 13))
                        Button(action: {
                            self.beginRegisterView.toggle()
                        },label:{
                            Text("Register").foregroundColor(Color("AccentColor")).font(.system(size: 13))
                        })
                        
                        Spacer()
                    }.padding(.bottom,40)
                }.offset(y: -self.value)
                    .onAppear{
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { (noti) in
                            let value = noti.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
                            let height = value.height/2
                            self.value = height
                        }
                        
                        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { (noti) in
                            
                            self.value = 0
                        }
                    }
                
                NavigationLink(
                    destination: RegisterEmailView().environmentObject(validationVM),
                    
                    isActive: $beginRegisterView,
                    label: {
                        EmptyView()
                    })
                
                
                
            }.edgesIgnoringSafeArea(.all)
              .opacity(showContentScreen ? 0.2 : 1).disabled(showContentScreen).overlay {
                    if showContentScreen{
                        SignInOverlay().frame(width: UIScreen.main.bounds.width/1.5, height: UIScreen.main.bounds.height/3).cornerRadius(16)
                    }
                }
            
            
        }
        
    }
}



struct SignInOverlay : View {
    
    
    
    var body: some View {
        ZStack{
            Color("Color")
            VStack{
                
                Spacer()
                
                HStack{
                    
                    Spacer()
                    VStack{
                        Text("Logging in...")
                            .foregroundColor(FOREGROUNDCOLOR).font(.title).bold()
                        ProgressView()
                    }
                    Spacer()
                }
                
             
               
                Spacer()
            }
        }
    }
}
