//
//  EditStoryPost.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/13/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct EditStoryPost: View {
    
    @Binding var image : UIImage
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            Image(uiImage: image)
                .resizable()
                .aspectRatio(image.size, contentMode: .fill).resizeToScreenSize()

            VStack{
                
                HStack{
                    
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                            
                            Image(systemName: "chevron.left")
                                .font(.title3).foregroundColor(FOREGROUNDCOLOR)
                        }
                    }).padding(.leading,10)
                    
                    Spacer()
                }.padding(.top,50)
                
                Spacer()
                
                
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}

extension View {
    func resizeToScreenSize() -> some View{
        frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
}
