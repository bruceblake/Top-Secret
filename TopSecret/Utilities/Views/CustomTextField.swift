//
//  CustomTextField.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/4/21.
//

import SwiftUI

struct CustomTextField: View {
    @EnvironmentObject var userVM: UserViewModel
    @Binding var text: String
    var placeholder: String
    var isPassword:Bool = false
    @State var isSecure: Bool = false
    var hasSymbol: Bool = false
    var symbol: String = ""
    var numbersOnly: Bool = false
 
    var body: some View {
        ZStack{
            
            VStack{
                HStack(){
                    if(hasSymbol){
                    Image(systemName: symbol).padding(.leading,15)
                    }
                    
                    if isPassword {
                        
                        if numbersOnly {
                            SecureField(placeholder, text: $text).autocapitalization(.none).padding(.vertical).padding(.leading,15).keyboardType(.numberPad)
                        }else{
                            HStack{
                                if isSecure{
                                    SecureField(placeholder, text: $text).autocapitalization(.none).padding(.vertical).padding(.leading,15)
                                        Button(action:{
                                            self.isSecure.toggle()
                                        },label:{
                                            Image(systemName: isSecure ? "eye" : "eye.slash")
                                        }).padding(.trailing)
                                }else{
                                    TextField(placeholder, text: $text).autocapitalization(.none).padding(.vertical).padding(.leading,15)
                                        Button(action:{
                                            self.isSecure.toggle()
                                        },label:{
                                            Image(systemName: isSecure ? "eye" : "eye.slash")

                                        }).padding(.trailing)
                                }
                            
                            }
                        }
                        
                    }else{
                        if numbersOnly {
                            TextField(placeholder,text: $text).autocapitalization(.none).padding(.vertical).padding(.leading,15).keyboardType(.numberPad)
                        }else{
                            TextField(placeholder,text: $text).autocapitalization(.none).padding(.vertical).padding(.leading,15)
                             
                        }
                    }
                    
                }.background(RoundedRectangle(cornerRadius: 20).stroke(lineWidth: 2)).foregroundColor(FOREGROUNDCOLOR).padding(.horizontal)
            }
        }
    }
}

//struct CustomTextField_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomTextField(text: .constant( ""),placeholder: "Email", isSecure: false, hasSymbol: true,  symbol: "envelope").preferredColorScheme(.dark)
//    }
//}
