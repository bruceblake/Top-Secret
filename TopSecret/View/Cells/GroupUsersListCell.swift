//
//  GroupUsersListCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/24/21.
//

import SwiftUI
import SDWebImageSwiftUI


struct GroupUsersListCell: View {
    var user : User
    var isCurrentUser : Bool
    var nameColor : String
    var body: some View {
        VStack(alignment: .leading){
            HStack(alignment: .center){
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:48,height:48)
                    .clipShape(Circle())
                    
                
                VStack(alignment: .leading){
                    
                  
                        Text("\(user.nickName ?? "") \(isCurrentUser ? "(Me)" : "")").foregroundColor(Color(nameColor))
                    
                    

                    Text("\(user.username ?? "")").font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
            }.padding([.leading,.vertical])
            Divider()
        }
    .edgesIgnoringSafeArea(.all)
    }
}

struct GroupUsersListCell_Previews: PreviewProvider {
    static var previews: some View {
        GroupUsersListCell(user: User(), isCurrentUser: false, nameColor: "red").preferredColorScheme(.dark)
    }
}
