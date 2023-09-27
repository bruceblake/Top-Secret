//
//  RegisterPhoneView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct RegisterPhoneView: View {
    @State var phoneNumber: String = " "
    @State var isNext:Bool = false
    @Binding var usingEmail: Bool
    @EnvironmentObject var vm: UserViewModel

    
    var body: some View {
        
        
        ZStack {
            
            Color("Background")
            
            NavigationLink(
                destination:CreateUsername(),             isActive: $isNext,
                label: {
                    EmptyView()
                })
            VStack{
                
                
                
                VStack{
                    Text("Enter Phone Number").foregroundColor(Color("Foreground")).fontWeight(.bold).font(.largeTitle).padding(.bottom,10)
                    
                    CustomTextField(text: $phoneNumber, placeholder: "Phone Number", isPassword: false, isSecure: false, hasSymbol: true,symbol: "phone").padding(.horizontal,20)
                    
                    
                    
                    Button(action: {
                        self.isNext.toggle()
                    }, label: {
                        Text("Next")
                            .foregroundColor(Color("Foreground"))
                            .padding(.vertical)
                            .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                    }).padding()
                    
                    
                    Button(action:{
                        usingEmail.toggle()
                    },label:{Text("I want to use my email").font(.body)})
                    
                 
                    
                    Spacer()
                }
            }.padding(.top,100)
        }.edgesIgnoringSafeArea(.all)
    }
}


