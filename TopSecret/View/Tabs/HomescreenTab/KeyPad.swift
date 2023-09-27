//
//  KeyPad.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/10/22.
//

import SwiftUI

struct KeyPad : View {
    
    @Binding var enteredSlots : [Int]
    @Binding var password : String
    @Binding var tryPassword : Bool
    @Binding var isDeveloping : Bool
    
    var width : CGFloat = 70
    var height  : CGFloat = 70
    
    var body: some View {
        VStack(spacing: 20){
            HStack(spacing: 15){
                
                ForEach(1..<4) { i in
                    Button(action:{
                        if password.count != 4 {
                            enteredSlots[password.count] = 1
                            password += "\(i)"
                        }
                    },label:{
                        ZStack{
                            Circle().frame(width: width, height: height).foregroundColor(Color("Color"))
                            Text("\(i)").foregroundColor(Color("AccentColor")).font(.title)
                        }
                    })
                    
                }
                
            }
            
            
            HStack(spacing: 15){
                ForEach(4..<7) { i in
                    Button(action:{
                        if password.count != 4 {
                            enteredSlots[password.count] = 1
                            password += "\(i)"
                        }
                    },label:{
                        ZStack{
                            Circle().frame(width: width, height: height).foregroundColor(Color("Color"))
                            Text("\(i)").foregroundColor(Color("AccentColor")).font(.title)
                        }
                    })
                    
                }
            }
            HStack(spacing: 15){
                ForEach(8..<11) { i in
                    Button(action:{
                        if password.count != 4 {
                            enteredSlots[password.count] = 1
                            password += "\(i)"
                        }
                    },label:{
                        ZStack{
                            Circle().frame(width: width, height: height).foregroundColor(Color("Color"))
                            Text("\(i == 10 ? 0 : i)").foregroundColor(Color("AccentColor")).font(.title)
                        }
                    })
                    
                }
            }
            HStack{
                
                Button(action:{
                    if password.count != 0 {
                        enteredSlots[password.count-1] = -1
                        password.removeLast()
                    }
                    
                },label:{
                    ZStack{
                        Capsule().frame(width: width + 45, height: height-10).foregroundColor(Color("Color"))
                        Text("Delete").foregroundColor(Color("AccentColor")).font(.title)
                    }
                })
                
                Button(action:{
                    tryPassword.toggle()
                },label:{
                    ZStack{
                        Capsule().frame(width: width + 45, height: height-10).foregroundColor(Color("Color"))
                        Text("Open").foregroundColor(Color("AccentColor")).font(.title)
                    }
                })
                
                
            }
            
            Button(action:{
                tryPassword.toggle()
            },label:{
                ZStack{
                    Capsule().frame(width: width + 45, height: height-10).foregroundColor(Color("AccentColor"))
                    Text("Development Button").foregroundColor(FOREGROUNDCOLOR).font(.title)
                }
                
            }).disabled(!isDeveloping)
            
            
        }
    }
}
