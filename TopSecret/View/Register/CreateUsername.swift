//
//  CreateUsername.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct CreateUsername: View {
    
    @State var isNext:Bool = false
    @State var showErrorMessage:Bool = false
    @EnvironmentObject var registerValidation : RegisterValidationViewModel
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
                Text("Create Your Username").foregroundColor(Color("Foreground")).font(.largeTitle).fontWeight(.bold).padding(.horizontal)
 
                CustomTextField(text: $registerValidation.username, placeholder: "Username", isPassword: false, isSecure: false, hasSymbol: true,symbol: "person").padding(.horizontal,20)
               
                if showErrorMessage{
                Text("\(registerValidation.usernameErrorMessage)").padding(.top,5).foregroundColor(registerValidation.usernameErrorMessage == "valid!" ? .green : .red)
                }
                Button(action: {
                    if registerValidation.usernameErrorMessage == "valid!"{
                    self.isNext.toggle()
                
                    }else{
                        showErrorMessage = true
                    }
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                NavigationLink(
                    destination: EnterFullName().environmentObject(registerValidation),
                    isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct CreateUsername_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateUsername().preferredColorScheme(.dark)
//            .environmentObject(UserViewModel())
//    }
//}
