//
//  UserNotificationView.swift
//  TopSecret
//
//  Created by Bruce Blake on 2/10/22.
//

import SwiftUI

struct UserNotificationView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @StateObject var notificationVM = UserNotificationViewModel()
    @Environment(\.presentationMode) var presentationMode
    
    private var newNotifications: [UserNotificationModel] {
        return userVM.notifications.filter {  noti in
            let date = Date()
            let dateDiff = Calendar.current.dateComponents([.day], from: noti.timeStamp?.dateValue() ?? Date(), to: date)
            let days = dateDiff.day ?? 0
            return days == 0
            //return if the difference in dates between Date() and timeStamp is less than 7 days
        }
        
    }
    
    
    private var yesterdayNotifications : [UserNotificationModel] {
        return userVM.notifications.filter {  noti in
            let date = Date()
            let dateDiff = Calendar.current.dateComponents([.day], from: noti.timeStamp?.dateValue() ?? Date(), to: date)
            let days = dateDiff.day ?? 0
            return days == 1
        }
    }
    
    private var thisWeekNotifications: [UserNotificationModel] {
        return userVM.notifications.filter {  noti in
            let date = Date()
            let dateDiff = Calendar.current.dateComponents([.day, .month], from: noti.timeStamp?.dateValue() ?? Date(), to: date)
            let months = dateDiff.month ?? 0
            let days = dateDiff.day ?? 0
            return months < 1 && days <= 7 && days > 1
            //return if the difference in dates between Date() and timeStamp is less than 7 days
        }
    }
    
    private var thisMonthNotifications: [UserNotificationModel] {
        return userVM.notifications.filter {  noti in
            let date = Date()
            let dateDiff = Calendar.current.dateComponents([.month], from: noti.timeStamp?.dateValue() ?? Date(), to: date)
            let months = dateDiff.month ?? 0
            return months == 1
            //return if the difference in dates between Date() and timeStamp is less than 7 days
        }
    }
    
    private var earlierNotifications: [UserNotificationModel] {
        return userVM.notifications.filter {  noti in
            let date = Date()
            let dateDiff = Calendar.current.dateComponents([.month], from: noti.timeStamp?.dateValue() ?? Date(), to: date)
            let months = dateDiff.month ?? 0
            return months > 1
            //return if the difference in dates between Date() and timeStamp is less than 7 days
        }
    }
    
    var body: some View {
        
        ZStack{
            Color("Background")
            VStack{
         
                       
                        
                    
                
                ScrollView(showsIndicators: false){
                    
                    VStack(alignment: .leading, spacing: 0){
                        VStack(alignment: .leading, spacing: 10){
                            if !newNotifications.isEmpty{
                                VStack{
                                    
                                   
                                    HStack{
                                        
                                    Text("New").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline)
                                        Spacer()
                                    }.padding(.leading,25)
                                    ForEach(newNotifications){ notification in
                                       
                                          
                                        UserNotificationCell(userNotification: notification).padding(.horizontal)

                                            
                                        Divider()

                                    }
                                }
                            }
                            
                            if !yesterdayNotifications.isEmpty{
                                VStack{
                                    
                                   
                                    HStack{
                                        
                                    Text("Yesterday").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline)
                                        Spacer()
                                    }.padding(.leading,25)
                                    ForEach(yesterdayNotifications){ notification in
                                       
                                          
                                        UserNotificationCell(userNotification: notification).padding(.horizontal)

                                            
                                        Divider()

                                    }
                                }
                            }
                          
                            if !thisWeekNotifications.isEmpty{
                                VStack{
                                    HStack{
                                        
                                    Text("This Week").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline)
                                        Spacer()
                                    }.padding(.leading,25)
                                    ForEach(thisWeekNotifications){ notification in
                                       
                                          
                                                UserNotificationCell(userNotification: notification).padding(.horizontal)

                                            
                                        Divider()

                                    }
                                }
                            }
                          
                            if !thisMonthNotifications.isEmpty{
                                VStack{
                                    HStack{
                                        
                                    Text("This Month").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline)
                                        Spacer()
                                    }.padding(.leading,25)
                                    ForEach(thisMonthNotifications){ notification in
                                       
                                          
                                                UserNotificationCell(userNotification: notification).padding(.horizontal)

                                            
                                        Divider()

                                    }
                                }
                            }
                            
                            
                            if !earlierNotifications.isEmpty{
                                VStack{
                                    HStack{
                                        
                                    Text("Eariler").foregroundColor(FOREGROUNDCOLOR).fontWeight(.bold).font(.headline)
                                        Spacer()
                                    }.padding(.leading,25)
                                    ForEach(earlierNotifications){ notification in
                                       
                                          
                                                UserNotificationCell(userNotification: notification).padding(.horizontal)

                                            
                                        Divider()

                                    }
                                }
                            }
                            
                            if userVM.notifications.isEmpty{
                                Text("You have no activity yet :(").foregroundColor(Color.gray)
                            }
                         
                           
                          
                            
                            
                          
                        }
                        
                        
                        
                    }.padding(.bottom, UIScreen.main.bounds.height/5)
                    
                    
                }
            }
            
        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true)
    }
}


struct UserNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        UserNotificationView().environmentObject(UserViewModel()).colorScheme(.dark)
    }
}
