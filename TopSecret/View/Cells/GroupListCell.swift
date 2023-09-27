//
//  GroupListCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 9/23/21.
//

import SwiftUI
import FirebaseStorage
import SDWebImageSwiftUI

struct GroupListCell: View {
  
    var group: GroupModel
    
    var body: some View {
       
        HStack(alignment: .firstTextBaseline){
            WebImage(url: URL(string: group.groupProfileImage ?? " "))
                .resizable()
                .scaledToFill()
                .frame(width:45,height:45)
                .clipShape(Circle())
                .padding()
            Text(group.groupName).foregroundColor(Color("Foreground"))
            Spacer()
            Text("\(group.memberAmount)").foregroundColor(Color("Foreground"))
        }.padding(.horizontal)
        
    }
}

//struct GroupListCell_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupListCell()
//    }
//}
