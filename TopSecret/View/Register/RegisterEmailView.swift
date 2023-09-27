//
//  RegisterView.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/4/21.
//

import SwiftUI

struct RegisterEmailView: View {
    @State var isNext:Bool = false
    @State var usingEmail:Bool = true
    @State var showErrorMessage:Bool = false
    @EnvironmentObject var validationVM : RegisterValidationViewModel
    @Environment(\.presentationMode) var presentationMode
    
    
    
    
    var body: some View {
        
        
        
            ZStack {
                
                Color("Background")
                
                NavigationLink(
                    destination:CreateUsername().environmentObject(validationVM),             isActive: $isNext,
                    label: {
                        EmptyView()
                    })
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
                    
                    
                    
                    VStack{
                        Text("Enter Email").foregroundColor(Color("Foreground")).fontWeight(.bold).font(.largeTitle).padding(.bottom,10)
                        
                        CustomTextField(text: $validationVM.email, placeholder: "Email", isPassword: false, isSecure: false, hasSymbol: true,symbol: "envelope").padding(.horizontal,20)
                        
                        if showErrorMessage{
                        Text("\(validationVM.emailErrorMessage)").padding(.top,5).foregroundColor(validationVM.emailErrorMessage == "valid!" ? .green : .red)
                        }
                        Button(action: {
                            if validationVM.emailErrorMessage == "valid!"{
                              
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
                        
                        
                        
                        
                    
                    }
                    
                    Spacer()
                    
                }
                
            }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
        
    }
    
    

    
}
