//
//  FriendCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 8/22/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct FriendCell: View {
    var user: User
    @ObservedObject var personalChatVM: PersonalChatViewModel
    var chat: ChatModel
    @EnvironmentObject var userVM: UserViewModel
    
    
    func getTimeSinceMessage(lastMessageDate: Date) -> String{
        let interval = (Date() - lastMessageDate)
        
        
        let seconds = interval.second ?? 0
        let minutes = (seconds / 60)
        let hours = (minutes / 60)
        let days = (hours / 24)
        var time = ""
        if seconds < 60{
            time = "\(seconds)s"
        }else if seconds < 3600  {
            time = "\(minutes)m"
        }else if seconds < 86400 {
            time = "\(hours)h"
        }else if seconds < 604800 {
            time = "\(days)d"
        }
        if time == "0s"{
            return "now"
        }else{
            return time
        }
        
    }
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            
            //Message indicator
            HStack(alignment: .center){
                
                if !((chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? " ") ?? false)){
                    
                    
                    Circle().frame(width: 12, height: 12).foregroundColor(Color("AccentColor"))
                }
                
                
                //Profile Picture
                WebImage(url: URL(string: user.profilePicture ?? ""))
                    .resizable()
                    .scaledToFill()
                    .frame(width:48,height:48)
                    .clipShape(Circle())
                
                HStack(alignment: .center){
                    
                    VStack(alignment: .leading, spacing: 0){
                        
                        VStack(alignment: .leading, spacing: 2){
                            Text("\(user.nickName ?? "")").foregroundColor(FOREGROUNDCOLOR).bold().font(.headline)
                            
                            
                            
                            
                            
                            
                            HStack(alignment: .center){
                                if chat.usersTypingID.contains(user.id ?? ""){
                                    Text("is typing...").foregroundColor(Color("AccentColor"))
                                }else{
                                    
                                    if (chat.lastMessageID ?? "") == "NO_MESSAGE" {
                                        HStack(spacing: 1){
                                            Text("Start a new chat with ").foregroundColor(FOREGROUNDCOLOR)
                                            Text("\(user.username ?? "")").foregroundColor(Color.gray)
                                            Text("!").foregroundColor(FOREGROUNDCOLOR)
                                        }.font(.subheadline).lineLimit(1)
                                        
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    if chat.lastMessage?.type == "postMessage"{
                                        Text("\(chat.lastMessage?.name ?? "") sent a post")
                                    }else if chat.lastMessage?.type == "eventMessage"{
                                        Text("\(chat.lastMessage?.name ?? "") sent an event")
                                    }else if chat.lastMessage?.type == "pollMessage"{
                                        Text("\(chat.lastMessage?.name ?? "") sent a poll")
                                    }else if chat.lastMessage?.type == "image"{
                                        Text("\(chat.lastMessage?.name ?? "") sent an image")
                                    }else if chat.lastMessage?.type == "video"{
                                        Text("\(chat.lastMessage?.name ?? "") sent a video")
                                    }else if chat.lastMessage?.type == "multipleImages"{
                                        Text("\(chat.lastMessage?.name ?? "") sent \(chat.lastMessage?.urls?.count ?? 0) images")
                                    }else if chat.lastMessage?.type == "multipleVideos"{
                                        Text("\(chat.lastMessage?.name ?? "") sent \(chat.lastMessage?.urls?.count ?? 0) videos")
                                    }
                                    
                                    else{
                                        Text("\( (chat.lastMessage ?? Message() ).value ?? "")").lineLimit(1).foregroundColor(chat.lastMessage?.type == "delete" ? Color("AccentColor") : (chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? "") ?? false ) ? Color.gray : FOREGROUNDCOLOR).font(.subheadline)
                                    }
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                    
                                }
                            }.foregroundColor(.gray)
                            
                            if ((chat.usersThatHaveSeenLastMessage?.contains(userVM.user?.id ?? " ") ?? false)){
                                
                                
                                if (chat.usersThatHaveSeenLastMessage?.contains(user.id ?? "") ?? false){
                                    HStack(alignment: .center){
                                        
                                        Image(systemName: "play").foregroundColor(Color("AccentColor")).font(.caption)
                                        Text("Read").foregroundColor(Color.gray).font(.subheadline)
                                        
                                        
                                    }
                                    
                                    
                                    
                                }else{
                                    HStack(alignment: .center){
                                        
                                        
                                        Image(systemName: "play.fill").foregroundColor(Color("AccentColor")).font(.caption)
                                        
                                        Text("Delivered").foregroundColor(Color.gray).font(.subheadline)
                                        
                                        
                                        
                                        
                                    }
                                    
                                }
                                
                                
                            }
                            
                        }
                        
                        
                        
                        
                    }
                    
                }
                Spacer()
                
                
                
                VStack(alignment: .leading, spacing: 5){
                    Text("\(self.getTimeSinceMessage(lastMessageDate: chat.lastActionDate?.dateValue() ?? Date() ))").font(.subheadline).foregroundColor(Color.gray)
                    
                    if(chat.usersTypingID.contains(userVM.user?.id ?? " ")){
                        Image(systemName: "pencil.line").foregroundColor(Color("AccentColor"))
                    }
                }
                
            }.padding()
        }.padding(.horizontal,10).background(Rectangle().stroke(Color("Color")))
    }
}


