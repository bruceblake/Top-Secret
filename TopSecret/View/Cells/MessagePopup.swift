//
//  MessagePopup.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/28/21.
//

import SwiftUI

struct MessagePopup: View {
   var isPresented : Bool
    var body: some View {
        if isPresented{
            ZStack{
                Color("LightBackground")
                VStack{
                HStack{
                  Text("pin")
                    Text("delete")
                    Text("edit")
                }
                }
            }.frame(width: 200, height:200)
            
        }
    }
}

struct MessagePopup_Previews: PreviewProvider {
    static var previews: some View {
        MessagePopup(isPresented: true)
    }
}
