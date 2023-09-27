//
//  SettingsButtonCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/4/22.
//

import SwiftUI

struct SettingsButtonCell: View {
    @State var text: String = ""
    var includeDivider: Bool
    var action : () -> (Void)
    var body: some View {
        VStack{
        Button(action:{
            action()
        },label:{
            HStack(alignment: .center){
                Text(text).foregroundColor(FOREGROUNDCOLOR)
                    .padding(.leading)
                Spacer()
                
            }
        })
            if includeDivider {
                Divider()
            }
        }
    }
}

//struct SettingsButtonCell_Previews: PreviewProvider {
//    static var previews: some View {
//        SettingsButtonCell()
//    }
//}
