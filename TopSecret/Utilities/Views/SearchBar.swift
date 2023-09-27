//
//  SearchBar.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/1/22.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var text : String
    var placeholder: String = ""
    var onSubmit : () -> (Void)
    var backgroundColor : Color = Color("Color")
    var showKeyboard : Bool = true
    @FocusState var focused : Bool
    var body: some View {
        HStack(spacing: 15){
            
            Image(systemName: "magnifyingglass").font(.system(size: 23, weight: .bold))
                .foregroundColor(.gray)
            
            TextField("\(placeholder)", text: $text).autocapitalization(.none).onSubmit{
              onSubmit()
            }.focused($focused)
            
            Spacer()
            
            Button(action:{
                self.text = ""
            },label:{
                Image(systemName: "xmark.circle").foregroundColor(Color("Foreground"))
            })
            
        }.padding(.vertical,10).padding(.horizontal).background(backgroundColor).cornerRadius(16).padding(.horizontal).onAppear{ 
            focused = true
        }
        
    }
}

//struct SearchBar_Previews: PreviewProvider {
//    static var previews: some View {
//        SearchBar(text: .constant("hello world"))
//    }
//}
