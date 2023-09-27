//
//  MutualFriendCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/27/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct MutualFriendCell: View {
    var user: User
    var backgroundColor : Color
    var body: some View {
        HStack(alignment: .center){
            WebImage(url: URL(string: user.profilePicture ?? " "))
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 0){
                Text(user.nickName ?? "")
                Text("@\(user.username ?? "")").font(.subheadline).foregroundColor(.gray)
            }
        }.padding(10).background(RoundedRectangle(cornerRadius: 12).fill(backgroundColor)).edgesIgnoringSafeArea(.all)
    }
}

