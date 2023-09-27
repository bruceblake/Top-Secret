//
//  EnterFullName.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct EnterFullName: View {
    
    @State var nickName: String = ""
    @State var isNext: Bool = false
    @EnvironmentObject var registerVM : RegisterValidationViewModel
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
                Text("Enter your nickname").foregroundColor(Color("Foreground")).font(.largeTitle).fontWeight(.bold).padding(.horizontal)
                
                Text("This is the name your friends will see you as").font(.headline).padding(.bottom,30)
                
                
                
                
                CustomTextField(text: $nickName, placeholder: "Nickname", isPassword: false, isSecure: false, hasSymbol: false,symbol: "none").padding(.horizontal,20)
                
                
                
                
                
                Button(action: {
                    self.isNext.toggle()
                    registerVM.nickName = nickName
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                NavigationLink(
                    destination: EnterBirthday().environmentObject(registerVM),
                    isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct EnterFullName_Previews: PreviewProvider {
    static var previews: some View {
        EnterFullName().preferredColorScheme(.dark)
            .environmentObject(UserViewModel())
    }
}
