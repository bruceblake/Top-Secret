//
//  EventListCell.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/2/22.
//

import SwiftUI
import Firebase

struct EventListCell: View {
    @State var eventName: String
    @State var eventLocation: String
    @State var eventTime: Timestamp
    @State var day : Int = 0
    @State var month: Int = 0
    
    var body: some View {
        ZStack{
            Color("Background")
            VStack{
                HStack{
                    Text("\(eventName)")
                        .font(.caption)
                    Text("\(eventLocation)")
                        .font(.caption)
                    Text("day: \(day), month: \(month)")
                }
            }
        }.onAppear{
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let components = Calendar.current.dateComponents([.month,.day], from: eventTime.dateValue())
                self.month = components.month ?? 0
                self.day = components.day ?? 0
            }
         
            
            
        }
    }
}
//
//struct EventListCell_Previews: PreviewProvider {
//    static var previews: some View {
//        EventListCell(eventName: "Kareoke", eventLocation: "Sebastian's House", eventDate: "January 14th", eventTime: "4:00 PM")
//    }
//}
