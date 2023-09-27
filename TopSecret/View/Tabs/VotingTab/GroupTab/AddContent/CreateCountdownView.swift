//
//  CreateCountdownView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/22/22.
//

import SwiftUI
import Firebase

struct CreateCountdownView: View {
    @StateObject var groupVM = GroupViewModel()
    @Environment(\.presentationMode) var presentationMode
    @State var countdownName : String = ""
    @State var countdownDate: Date = Date()
    @Binding var group: GroupModel
    @EnvironmentObject var userVM: UserViewModel
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 40, height: 40)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading)
                    
                    
                    
                    Spacer()
                    
                    Text("Create A Countdown!")
                        .fontWeight(.bold).font(.title)
                    Spacer()
                }.padding(.top,50)
                
                
                VStack(spacing: 20){
                    //Event Name
                    
                    VStack(alignment: .leading){
                        Text("Countdown Name").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        VStack{
                            CustomTextField(text: $countdownName, placeholder: "Event Name", isPassword: false, isSecure: false, hasSymbol: false, symbol: "")
                        }
                    }.padding(.horizontal)
                    
                    VStack(alignment: .leading){
                        Text("Countdown Time").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold)
                        HStack{
                            DatePicker("", selection: $countdownDate)
                            Spacer()
                        }
                    }.padding(.horizontal)
                    
                    
                }.padding(.vertical,10)
                
                
                
                
              
                
                Spacer()
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

//struct CreateCountdownView_Previews: PreviewProvider {
//    static var previews: some View {
//        CreateCountdownView()
//    }
//}
