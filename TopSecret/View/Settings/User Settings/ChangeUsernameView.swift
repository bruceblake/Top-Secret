//
//  ChangeUsernameView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/16/22.
//

import SwiftUI

struct ChangeUsernameView: View {
    @EnvironmentObject var userEditVM: UserEditProfileViewModel
    @EnvironmentObject var userVM : UserViewModel
    @State var username = ""
    @Binding var openUsernameScreen : Bool
    var body: some View {
        ZStack{
            Color("Background")
            
            VStack{
                HStack{
                  
                    Button(action:{
                        openUsernameScreen.toggle()
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
                    Text("Change Username").fontWeight(.bold).font(.title)
                    Text("You can change your username once every 2 weeks").foregroundColor(.gray).padding(.horizontal,10).font(.body)
                }.padding(.bottom,150).padding(.top,40)
           
                    
                CustomTextField(text: $username, placeholder: userVM.user?.username ?? "", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                
                Button(action:{
                    userEditVM.changeUsername(userID: userVM.user?.id ?? "", username: username)
                },label:{
                    Text("Save")
                })
                Spacer()
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct ChangeUsernameView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChangeUsernameView()
//    }
//}
