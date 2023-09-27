//
//  EventCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/17/22.
//

import SwiftUI
import SDWebImageSwiftUI
struct EventCell: View {
    
   @State var event : EventModel
    @Binding var selectedEvent: EventModel
    @EnvironmentObject var userVM: UserViewModel
    @EnvironmentObject var shareVM: ShareViewModel

    @StateObject var eventVM = EventViewModel()
    
    
    func userHasLiked() -> Bool{
        return event.likedListID?.contains(userVM.user?.id ?? "") ?? false
    }
    
    func userHasDisliked() -> Bool{
        return event.dislikedListID?.contains(userVM.user?.id ?? "") ?? false

    }
    
    var body: some View {


        ZStack{
            Color("Color")
            VStack{
                HStack(alignment: .top){
                    HStack(alignment: .center){
                        ZStack(alignment: .bottomTrailing){
                            
                            NavigationLink(destination: GroupProfileView(group: event.group ?? GroupModel(), isInGroup: event.group?.usersID.contains(userVM.user?.id ?? " ") ?? false)) {
                                WebImage(url: URL(string: event.group?.groupProfileImage ?? "")).resizable().frame(width: 40, height: 40).clipShape(Circle())
                            }
                            
                            NavigationLink(destination: UserProfilePage(user: event.creator ?? User())) {
                                WebImage(url: URL(string: event.creator?.profilePicture ?? "")).resizable().frame(width: 18, height: 18).clipShape(Circle())
                            }.offset(x: 3, y: 2)
                            
                        }
                        
                        VStack(alignment: .leading, spacing: 1){
                            HStack{
                                Text("\(event.group?.groupName ?? "" )").font((.system(size: 15))).bold()
                                Text("\(event.timeStamp?.dateValue() ?? Date(), style: .time)").font(.system(size: 12))
                                
                            }
                            
                            HStack(spacing: 3){
                                Text("created by").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 12))
                                NavigationLink(destination: UserProfilePage(user: event.creator ?? User())) {
                                    Text("\(event.creator?.username ?? "")").foregroundColor(Color.gray).font(.system(size: 12))
                                }
                            }
                            
                        }
                    }
                    
                    Spacer()
                    
                    Button(action:{
                        
                    },label:{
                        Image(systemName: "ellipsis").foregroundColor(FOREGROUNDCOLOR)
                    }).padding(5)
                }.padding([.horizontal,.top],5)
                
                VStack(spacing: 1){
                    Text("\(event.eventName ?? "")").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 15))
                    Divider()
                }
                
                        HStack{
                            
                            VStack(alignment: .leading, spacing: 10){
                                HStack(){
                                    Image(systemName: "clock").font(.headline).foregroundColor(Color.gray)
                                    Text(event.eventStartTime?.dateValue() ?? Date(), style: .time).font(.subheadline).bold()
                                    Text("-").font(.subheadline).bold()
                                    Text(event.eventEndTime?.dateValue() ?? Date(), style: .time).font(.subheadline).bold()
                                }.foregroundColor(FOREGROUNDCOLOR)
                                    
                                    HStack(alignment: .center){
                                        Image(systemName: "calendar").font(.headline).foregroundColor(Color.gray)
                                        Text(event.eventStartTime?.dateValue() ?? Date(), style: .date).font(.subheadline).bold()

                                    }
                                    
                                    HStack(alignment: .center){
                                        Image(systemName: "mappin.and.ellipse").foregroundColor(Color.gray).font(.headline)
                                        Text(event.eventLocation ?? "").font(.subheadline).bold()
                                    }
                                Button(action:{
                                    
                                },label:{
                                    Text("RSVP").foregroundColor(FOREGROUNDCOLOR).padding(5).padding(.horizontal).background(RoundedRectangle(cornerRadius: 12).fill(Color("AccentColor")))
                                })
                            }
                          
                         
                            Spacer()
                            
                            
                            Image(uiImage: event.image ?? UIImage()).resizable().scaledToFit().cornerRadius(16).frame(width: 100, height: 175).padding(.trailing)
                        }.padding(.horizontal)
                        
                        
                    
                   
                
               
               
                    
                    

                
                //bottom bar
                HStack{
                    Text("4 friends attending")
                    Spacer()
                    
                    HStack(alignment: .top, spacing: 20){
                        Button(action:{
                            userVM.updateGroupEventLike(eventID: event.id , userID: userVM.user?.id ?? " ", actionToLike: true) { list in
                               
                                self.event.likedListID = list[0]
                                self.event.dislikedListID = list[1]
                            }
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: self.userHasLiked() ? "heart.fill" :  "heart").foregroundColor(self.userHasLiked() ? Color("AccentColor") : FOREGROUNDCOLOR).font(.system(size: 22))
                                Text("\(event.likedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })
                        
                        Button(action:{
                            userVM.updateGroupEventLike(eventID: event.id , userID: userVM.user?.id ?? " ", actionToLike: false) { list in
                                self.event.likedListID = list[0]
                                self.event.dislikedListID = list[1]
                            }
                        },label:{
                            VStack(spacing: 1){
                                Image(systemName: self.userHasDisliked() ? "heart.slash.fill" :  "heart.slash").foregroundColor(self.userHasDisliked() ? Color("AccentColor") :  FOREGROUNDCOLOR).font(.system(size: 20))
                                Text("\(event.dislikedListID?.count ?? 0)").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 14))
                            }
                        })

                        
                            Button(action:{
                                withAnimation{
                                    shareVM.selectedEvent = event
                                    shareVM.shareType = "event"
                                    shareVM.showShareMenu.toggle()
                                    userVM.hideBackground.toggle()
                                    userVM.hideTabButtons.toggle()
                                }
                            },label:{
                                Image(systemName: "arrowshape.turn.up.right").foregroundColor(FOREGROUNDCOLOR).font(.system(size: 22))
                            })
                 
                    }.padding(.trailing,5)
                    
                }.padding([.horizontal,.bottom],5)
            }
        }.cornerRadius(16)
        
    }
}


extension Date {
    
    static func -(recent: Date, previous: Date) -> (month: Int?, day: Int?, hour: Int?, minute: Int?, second: Int?) {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        let month = Calendar.current.dateComponents([.month], from: previous, to: recent).month
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        let second = Calendar.current.dateComponents([.second], from: previous, to: recent).second
        
        return (month: month, day: day, hour: hour, minute: minute, second: second)
    }
    
}



//struct EventCell_Previews: PreviewProvider {
//    static var previews: some View {
//        EventCell()
//    }
//}
