//
//  ForgotPasswordView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/4/21.
//

import SwiftUI

struct ForgotPasswordView: View {
    
    @Binding var showForgotPasswordView: Bool
    @State var email: String = ""
    @EnvironmentObject var userAuthVM: UserViewModel
    

    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                Text("Forgot Password?").foregroundColor(Color("Foreground")).fontWeight(.bold).font(.largeTitle).padding(.bottom,10)
                
                
                
                CustomTextField(text: $email, placeholder: "email", isPassword: false, isSecure: false, hasSymbol: false,symbol: "none").padding(.horizontal,20)
                
                
                
                Button(action: {
                    userAuthVM.resetPassword(email: email)
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                Button(action: {
                    showForgotPasswordView.toggle()
                }, label: {
                    Text("back")
                })
                Spacer()
                
            }.padding(.top,70)
            
           
        }
        
    }
}

struct ForgotPasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordView(showForgotPasswordView: .constant(true)).preferredColorScheme(.dark).environmentObject(UserViewModel())
    }
}
