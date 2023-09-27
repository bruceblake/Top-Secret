////
////  PollInfoCell.swift
////  TopSecret
////
////  Created by Bruce Blake on 1/13/22.
////
//
//import SwiftUI
//import SDWebImageSwiftUI
//
//struct PollInfoCell: View {
//    
//    @EnvironmentObject var userVM : UserViewModel
//    
//    @State var daysRemaining: Int = 0
//    @State var hoursRemaining: Int = 0
//    @State var minutesRemaining: Int = 0
//    @State var secondsRemaining: Int = 0
//    @State var timeRemaining: String = ""
//    @State var isFinished : Bool = false
//    
//    @State var year = 0
//    @State var month = 0
//    @State var day = 0
//    
//    @Binding var showInfoScreen: Bool
//    
//    @Binding var creator: User
//
//    
//    var poll: PollModel
//    //actual 
//    @Binding var currentPoll: PollModel
//    
//    
//    func endPoll(pollID: String){
//        //TODO
//        COLLECTION_POLLS.document(pollID).updateData(["finished":true])
//        print("Finished poll!")
//    }
//    
//    
//    func getLastTwoDigits(year: String) -> String{
//        var index = 0
//        var ans = ""
//        for digit in year{
//            if index > 1{
//                ans += String(digit)
//            }
//            index += 1
//        }
//        
//        return ans
//    }
//    
//    
//    func convertComponentsToDate(days: Int, hours: Int, minutes: Int, seconds: Int) -> String {
//        var ans = ""
//    
//        
//        
//        
//        
//        
//      
//        
//        let noDays = (days <= 0)
//        let noHours = (hours <= 0)
//        let noMinutes = (minutes <= 0)
//        let noSeconds = (seconds <= 0)
//        
//        if(noDays && noHours && noMinutes && noSeconds){
//            ans = "Finished!"
//            if !self.isFinished{
//                self.endPoll(pollID: poll.id ?? "")
//                self.isFinished = true
//
//            }
//            
//            
//        }else if(noDays && noHours && noMinutes && !noSeconds){
//            ans = "\(seconds) secs"
//        }else if(noDays && noHours && !noMinutes){
//            ans = "\(minutes) mins"
//        }else if (noDays && !noHours && noMinutes){
//            ans = "\(hours) hrs"
//        }else if (!noDays && noHours && noMinutes){
//            ans = "\(days) days"
//        }else if (!noDays && !noHours && !noMinutes){
//            ans = "\(days) days \(hours) hrs \(minutes) mins"
//        }else if (!noDays && !noHours && noMinutes){
//            ans = "\(days) days \(hours) hrs"
//        }else if (!noDays && noHours && !noMinutes){
//            ans = "\(days) days \(hours) hrs"
//        }else if (noDays && !noHours && !noMinutes){
//            ans = "\(hours) hrs \(minutes) mins"
//        }else if (noDays && noHours && !noMinutes && !noSeconds){
//            ans = "\(minutes) mins \(seconds) secs"
//        }
//        
//        return ans
//        
//    }
//    
//    var body: some View {
//        ZStack{
//            Color("Color")
//            VStack(spacing: 5){
//                
//                HStack(alignment: .center){
//                    Text("\(poll.groupName ?? "")").bold().font(.headline)
//                    Text("@\(creator.username ?? "")").foregroundColor(.gray).font(.footnote)
//                    Spacer()
//                    Button(action:{
//                        self.currentPoll = poll
//                        self.showInfoScreen = true
//                    },label:{
//                        Image(systemName: "info.circle").frame(width: 30, height: 30)
//                    })
//                }.padding(.horizontal, 5)
//              
//                HStack{
//                    
//                    if poll.completionType == "All Users Voted"{
//                        if poll.finished == false{
//                            Text("\(poll.usersAnswered?.count ?? 0)/\(poll.totalUsers ?? 0) users answered").foregroundColor(Color.green)
//                        }else{
//                            Text("Finished!").foregroundColor(Color.red)
//                        }
//                        
//                    }else if poll.completionType == "Countdown"{
//                        if poll.finished == false {
//                            Text("\(timeRemaining)").foregroundColor(Color.green)
//                        }else{
//                            Text("Finished!").foregroundColor(Color.red)
//                        }
//                    
//                    }
//                    
//                    Spacer()
//                    Text("\(month)/\(day)/\(getLastTwoDigits(year: String(year)))")
//                }.padding(.horizontal, 5).padding(.bottom,5)
//                
//                
//            }.background(Rectangle().stroke(FOREGROUNDCOLOR, lineWidth: 2))
//        }.onAppear{
//            
//        
//            let components = Calendar.current.dateComponents([.day, .month, .year], from: poll.dateCreated?.dateValue() ?? Date())
//
//            day = components.day ?? 0
//            month = components.month ?? 0
//            year = components.year ?? 0
//            
//           
//            
//            
//        }.edgesIgnoringSafeArea(.all).navigationBarHidden(true).frame(width: 250, height: 25).onReceive(userVM.$pollDurationTimer, perform: { _ in
//            let components = Calendar.current.dateComponents([.day, .hour, .minute, .second], from: Date(), to: poll.endDate?.dateValue() ?? Date())
//
//            self.daysRemaining = components.day ?? 0
//            self.hoursRemaining = components.hour ?? 0
//            self.minutesRemaining = components.minute ?? 0
//            self.secondsRemaining = components.second ?? 0
//            
//            self.timeRemaining = convertComponentsToDate(days: daysRemaining, hours: hoursRemaining, minutes: minutesRemaining, seconds: secondsRemaining)
//        })
//        }
//    }
//
//
////struct PollInfoCell_Previews: PreviewProvider {
////    static var previews: some View {
////        PollInfoCell(creator: User(), poll: PollModel()).colorScheme(.dark)
////    }
////}
//
//struct PollInfoCellTop : View {
//    
//    var body: some View {
//        HStack{
//            Text("4 hours left")
//        }.background(RoundedRectangle(cornerRadius: 16).stroke(Color("AccentColor")))
//    }
//}
