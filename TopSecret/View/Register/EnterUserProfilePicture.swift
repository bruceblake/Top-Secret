//
//  EnterUserProfilePicture.swift
//  TopSecret
//
//  Created by Bruce Blake on 11/29/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct EnterUserProfilePicture: View {
    
    @State var isShowingPhotoPicker:Bool = false
    @State var avatarImage = UIImage(named: "topbarlogo")!
    @State var isNext: Bool = false
    @EnvironmentObject var registerVM : RegisterValidationViewModel
    @State var images : [UIImage] = []
    @Environment(\.presentationMode) var presentationMode
    @State var pickedAnImage: Bool = false

    
    
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
                
                Text("Enter a profile picture!").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                
                ZStack(alignment: .bottomTrailing){
                    if pickedAnImage{
                        Image(uiImage: avatarImage)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                            .frame(width: 150, height: 150)
                        
                        Button(action:{
                            isShowingPhotoPicker.toggle()
                            
                        }, label:{
                            ZStack{
                                Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                                Image(systemName: "photo").foregroundColor(FOREGROUNDCOLOR)
                            }.offset(x: 5, y: 10)
                        })
                    }else{
                        Button(action:{
                            isShowingPhotoPicker.toggle()
                            
                        },label:{
                            ZStack{
                                Circle().strokeBorder(FOREGROUNDCOLOR, lineWidth: 3).frame(width: 150, height: 150)
                                
                                Image(systemName: "person")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(FOREGROUNDCOLOR)
                            }
                            
                        })
                        
                    }
                    
                    
                    
                }
                
                .fullScreenCover(isPresented: $isShowingPhotoPicker, content: {
                    ImagePicker(avatarImage: $avatarImage, allowsEditing: true)
                })
              
                
        Button(action: {
                    self.isNext.toggle()
            registerVM.userProfileImage = avatarImage
                }, label: {
                    Text("Next")
                        .foregroundColor(Color("Foreground"))
                        .padding(.vertical)
                        .frame(width: UIScreen.main.bounds.width/1.5).background(Color("AccentColor")).cornerRadius(15)
                }).padding()
                
                NavigationLink(
                    destination: CreatePassword(),
                    isActive: $isNext,
                    label: {
                        EmptyView()
                    })
                Spacer()
            }
            
           
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).onChange(of: avatarImage) { newValue in
            self.pickedAnImage = true
        }
    }
}

struct EnterUserProfilePicture_Previews: PreviewProvider {
    static var previews: some View {
        EnterUserProfilePicture().colorScheme(.dark)
    }
}
