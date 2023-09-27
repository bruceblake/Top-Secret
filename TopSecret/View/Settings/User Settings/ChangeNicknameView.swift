//
//  ChangeNicknameView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/16/22.
//

import SwiftUI

struct ChangeNicknameView: View {
    @EnvironmentObject var registerVM: RegisterValidationViewModel
    @EnvironmentObject var userVM: UserViewModel
    @Binding var openNicknameScreen : Bool
    @State var nickName = ""
    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                HStack{
                  
                    Button(action:{
                        openNicknameScreen.toggle()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    
                    Spacer()
                }.padding(.top,50).padding(.leading,10)
                
                
                VStack{
                    Text("Change Nickname").fontWeight(.bold).font(.title)
                    Text("minimum of 11 characters").foregroundColor(.gray).padding(.horizontal,10).font(.body)
                }.padding(.bottom,150).padding(.top,40)
           
                    
                CustomTextField(text: $nickName, placeholder: userVM.user?.nickName ?? "", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                
                Button(action:{
                    registerVM.changeNickname(userID: userVM.user?.id ?? "", nickName: nickName)
                },label:{
                    Text("Save")
                })
                Spacer()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
       
       
    }
}

//struct ChangeNicknameView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeNicknameView()
//    }
//}
