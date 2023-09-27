//
//  EnterBirthday.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI

struct EnterBirthday: View {
    
    @State var isNext:Bool = false
    @State var selectedDate = Date()
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var validationVM : RegisterValidationViewModel
    
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
                Text("Enter your birthday").foregroundColor(Color("Foreground")).font(.largeTitle).fontWeight(.bold).padding(.horizontal)
                //BIRTHDAY PICKER TODO
                
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                
                
                
                Button(action: {
                    validationVM.birthday = selectedDate
                    self.isNext.toggle()
           
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                NavigationLink(
                    destination: EnterUserProfilePicture().environmentObject(validationVM),
                    isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

struct EnterBirthday_Previews: PreviewProvider {
    static var previews: some View {
        EnterBirthday().preferredColorScheme(.dark).environmentObject(UserViewModel())
    }
}
