//
//  ChatListCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 8/31/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatListCell: View {
    @StateObject var chatVM = ChatViewModel()
    var chat : ChatModel
    var body: some View {
        HStack{
            VStack{
                //Profile Picture
                WebImage(url: URL(string: chatVM.group.groupProfileImage ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:70,height:70)
                    .clipShape(Circle())
                    .padding()
            }.padding(.leading,10)
            
            VStack{
                HStack{
                    Text("\(chat.name ?? "")").fontWeight(.bold).foregroundColor(Color("Foreground"))
                    
              
            }.padding(.trailing,10)
        }
            Spacer()
    }.onAppear{
        chatVM.getGroup(groupID: chat.groupID ?? " ")
    }
    }
}
//struct ChatListCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatListCell(chat: ChatModel()).preferredColorScheme(.dark)
//    }
//}

