//
//  AddEventDescriptionView.swift
//  Top Secret
//
//  Created by Bruce Blake on 5/26/23.
//

import Foundation
import SwiftUI
//import OmenTextField


struct AddEventDescriptionView : View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var description: String
    @State var canAddAnotherLine : Bool = true

    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Button(action:{
                        presentationMode.wrappedValue.dismiss()
                    },label:{
                        ZStack{
                            Circle().frame(width: 40, height: 40).foregroundColor(Color("Color"))
                            Image(systemName: "chevron.left").foregroundColor(FOREGROUNDCOLOR)
                        }
                    })
                    Spacer()
                    Text("Description").foregroundColor(FOREGROUNDCOLOR).font(.title3)
                    Spacer()
                    Circle().frame(width:40 , height: 40).foregroundColor(Color.clear)

                }.padding(.top,50).padding(.horizontal)
                
//                OmenTextField("\(description)", text: $description, canAddAnotherLine: $canAddAnotherLine).padding(10).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color"))).padding()
                Spacer()
            }
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}
