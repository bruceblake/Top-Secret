//
//  GroupNotificationCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 7/11/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct GroupNotificationCell: View {
    
    var groupNotification : GroupNotificationModel
    @EnvironmentObject var userVM : UserViewModel
    @EnvironmentObject var selectedGroupVM : SelectedGroupViewModel
    
    var body: some View {
        VStack{
            
            
            
            //TODO
            //user sent a text
            //user sent an image
            //user sent a video
            //user replied
            //user edited
            //user deleted a chat
            
            //group bio changed
            //group name changed
            //group motd changed
            //group earned a badge
            
            switch groupNotification.type ?? " "{
            case "eventCreated":
                GroupEventCreatedNotificationCell(groupNotification: groupNotification)
            case "acceptedGroupInvitation":
                UserAcceptedInvitationNotificationCell(groupNotification: groupNotification)
            case "declinedGroupInvitation":
                UserDeclinedInvitationNotificationCell(groupNotification: groupNotification)
            case "invitedToGroup":
                    UserInvitedToGroupNotificationCell(groupNotification: groupNotification)
            default:
                Text("\(groupNotification.type ?? "cock")")
            }
            
        }
        
    }
}



struct GroupEventCreatedNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    var groupNotificationVM = GroupNotificationViewModel()
    var body: some View {
        
        VStack(alignment: .leading){
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.sender ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading){
                    HStack{
                        Text("\((groupNotification.sender ?? User() ).username ?? "USER_USERNAME")").fontWeight(.bold).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                        Text("\(groupNotification.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                        Spacer()
                    }
                    Text("\((groupNotification.sender ?? User() ).nickName ?? "USER_USERNAME") created an event").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                }
              
            }
        }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
        
    }
}


struct UserInvitedToGroupNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    @EnvironmentObject var groupVM: SelectedGroupViewModel
    var body: some View {
        VStack{
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.sender ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                VStack(alignment: .leading){
                    HStack{
                        Text("\((groupNotification.sender ?? User() ).nickName ?? "USER_USERNAME")").fontWeight(.bold).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                        Text("\(groupNotification.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                        Spacer()
                    }
                 
                    
                    Text("invited \((groupNotification.receiver ?? User() ).username ?? "USER_USERNAME") to \(groupVM.group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                }
             
               
            }
        }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
    }
}


struct UserAcceptedInvitationNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    @EnvironmentObject var groupVM: SelectedGroupViewModel
    var body: some View {
        VStack{
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.sender ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                VStack(alignment: .leading){
                    HStack{
                        Text("\((groupNotification.sender ?? User() ).nickName ?? "USER_USERNAME")").fontWeight(.bold).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                        Text("\(groupNotification.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                        Spacer()
                    }
                  
                    
                    Text("accepted their invitation to \(groupVM.group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                }
             
               
            }
        }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
    }
}





struct UserDeclinedInvitationNotificationCell : View {
    
    var groupNotification: GroupNotificationModel
    @EnvironmentObject var groupVM: SelectedGroupViewModel
    var body: some View {
        VStack{
            HStack{
                
                
                
                WebImage(url: URL(string: (groupNotification.sender ?? User()).profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:40,height:40)
                    .clipShape(Circle())
                VStack(alignment: .leading){
                    HStack{
                        Text("\((groupNotification.sender ?? User() ).nickName ?? "USER_USERNAME")").fontWeight(.bold).font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                        Text("\(groupNotification.timeStamp?.dateValue() ?? Date(), style: .time)").foregroundColor(.gray).font(.footnote)
                        Spacer()
                    }
                  
                    
                    Text("declined their invitation to \(groupVM.group.groupName )").font(.subheadline).foregroundColor(FOREGROUNDCOLOR).lineLimit(1)
                }
             
               
            }
        }.padding(5).background(RoundedRectangle(cornerRadius: 12).fill(Color("Color")))
    }
}
