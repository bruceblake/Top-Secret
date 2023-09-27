//
//  UserSearchCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/3/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserSearchCell: View {
    var user: User
    var showActivity: Bool
    var showUninviteButton : Bool = false
    @StateObject var attendanceVM: EventAttendanceViewModel = EventAttendanceViewModel()
    var body: some View {
        
        VStack(alignment: .leading){
            HStack(alignment: .center){
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                
                VStack(alignment: .leading, spacing: 0){
                    
                    HStack{
                        Text("\(user.nickName ?? "")").foregroundColor(Color("Foreground"))
                        
                        if showActivity{
                            Menu(content:{
                                if user.isActive ?? false == false{
                                    Text("inactive since: \(user.lastActive?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                                }
                            },label:{
                                Circle().frame(width: 8, height: 8).foregroundColor(user.isActive ?? false ? Color.green : Color.red)
                            })                        }
                        
                    }
                    Text("@\(user.username ?? "")").font(.subheadline).foregroundColor(.gray)
                }
                Spacer()
                
                if showUninviteButton && (attendanceVM.event.creatorID ?? " ") == USER_ID && (user.id ?? " ") != USER_ID{
                    Button(action:{
                        attendanceVM.uninviteToEvent(userID: user.id ?? " ", eventID: attendanceVM.event.id )
                    },label:{
                        Text("Uninvite")
                    })
                }
            }.padding(10)
            Divider()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

//struct UserSearchCell_Previews: PreviewProvider {
//    static var previews: some View {
//        UserSearchCell()
//    }
//}
