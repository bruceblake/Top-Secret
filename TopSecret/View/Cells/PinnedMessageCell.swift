//
//  PinnedMessageCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase
import SDWebImageSwiftUI

struct PinnedMessageCell: View{

    var message: String
    var name: String
    var userProfilePicture: String
    var timestamp: Timestamp
    var pinnedBy: String
    var pinnedTime: String

    var body: some View {
      
            VStack{
                Text("Pinned Message!")
                HStack{
                    WebImage(url: URL(string: userProfilePicture ))
                        .resizable()
                        .scaledToFill()
                        .frame(width:50,height:50)
                        .clipShape(Circle())
                        .padding()
                
                    VStack(alignment: .leading){
                        HStack{
                            Text("\(name)")
                         
                        }
                        Text("\(message)")
                    }
                    Spacer()
                }.padding(.leading)
            }.frame(maxWidth: .infinity)
        
    }
}
//
//struct PinnedMessageCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PinnedMessageCell(pinnedMessage: )
//    }
//}
