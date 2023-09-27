//
//  CountdownCell.swift
//  Top Secret
//
//  Created by Bruce Blake on 6/17/22.
//

import SwiftUI

struct CountdownCell: View {
    
   var countdown : CountdownModel
    
    func getTimeRemaining() -> Int {
        let interval = (countdown.endDate?.dateValue() ?? Date()) - Date()
        
        return interval.hour ?? 0
    }
    
    
    func isCurrentHour(date: Date) -> Bool{
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: date)
        
        let currentHour = calendar.component(.hour, from: Date())
        
        return hour == currentHour
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 30){
                VStack(spacing: 10){
                    Circle()
                        .fill(self.isCurrentHour(date: countdown.endDate?.dateValue() ?? Date()) ? Color("AccentColor") : .clear)
                        .frame(width: 15, height: 15)
                        .background(Circle().stroke(FOREGROUNDCOLOR,lineWidth: 1).padding(-3))
                        .scaleEffect(!self.isCurrentHour(date: countdown.endDate?.dateValue() ?? Date()) ? 0.8 : 1)
                    
                    Rectangle()
                        .fill(self.isCurrentHour(date: countdown.endDate?.dateValue() ?? Date()) ? Color("AccentColor") : Color("Color"))
                        .frame(width: 3)
                }
                
                VStack{
                    
                  
                    HStack(alignment: .top, spacing: 10){
                        VStack(alignment: .leading, spacing: 12){
                            
                            Text("\(countdown.countdownName ?? "COUNTDOWN_NAME")")
                                .font(.title2.bold())
                            
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading, spacing: 12){
                            Text("\(countdown.endDate?.dateValue() ?? Date(), style: .time)")
                            
                            if !self.isCurrentHour(date: countdown.endDate?.dateValue() ?? Date()){
                                Text("\(getTimeRemaining()) hours remaining!").foregroundColor(Color("AccentColor")).fontWeight(.bold)
                            }
                        }
                        
                    }
                }.foregroundColor(self.isCurrentHour(date: countdown.endDate?.dateValue() ?? Date()) ? FOREGROUNDCOLOR : .gray).padding(self.isCurrentHour(date: countdown.endDate?.dateValue() ?? Date()) ? 15 : 0).frame(maxWidth: .infinity, alignment: .leading).background(Color("Color").cornerRadius(25).opacity(self.isCurrentHour(date: countdown.endDate?.dateValue() ?? Date()) ? 1 : 0))
                
            }.frame(maxWidth: .infinity, alignment: .leading).padding()
        
    }
}

//struct CountdownCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CountdownCell()
//    }
//}
