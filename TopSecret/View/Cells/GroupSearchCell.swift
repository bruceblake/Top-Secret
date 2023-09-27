//
//  GroupSearchCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/7/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupSearchCell: View {
    var group : GroupModel
    var body: some View {
            
            HStack(alignment: .center){
                WebImage(url: URL(string: group.groupProfileImage))
                    .resizable()
                    .scaledToFill()
                    .frame(width:48,height:48)
                    .clipShape(Circle())
                    
                
                VStack(alignment: .leading){
                    
                    Text("\(group.groupName)").foregroundColor(Color("Foreground"))
                    Text("\(group.users.count) \(group.users.count > 1 ? "members" : "member")").foregroundColor(.gray)
                    

                }
                Spacer()
                
            
            }.padding(.leading).padding(.vertical,10)
            
         
    .edgesIgnoringSafeArea(.all)
    }
}

//struct GroupSearchCell_Previews: PreviewProvider {
//    static var previews: some View {
//        GroupSearchCell()
//    }
//}
