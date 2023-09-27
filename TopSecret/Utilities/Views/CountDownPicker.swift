//
//  CountDownPicker.swift
//  TopSecret
//
//  Created by Bruce Blake on 1/9/22.
//

import SwiftUI

struct CountDownPicker: View {
    
    
    @Binding var selectedHour: Int
    @Binding var selectedMinute: Int
    @Binding var selectedDay: Int
    var height = CGFloat(100)
    var widthDiviser = CGFloat(4)
    
  
    
    var body: some View {
        ZStack{
        GeometryReader { geometry in
            
              
                    HStack(spacing: 0) {
                        Spacer()
                        Picker("", selection: self.$selectedDay) {
                            ForEach(0..<7) {
                                Text("\(String($0)) days").tag($0)
                            }
                        }
                        .labelsHidden()
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(width: geometry.size.width / widthDiviser, height: height)
                        .clipped()
                        
                        Picker("", selection: self.$selectedHour) {
                            ForEach(0..<24) {
                                Text("\(String($0)) hours").tag($0)
                            }
                        }
                        .labelsHidden()
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(width: geometry.size.width / widthDiviser, height: height)
                        .clipped()
                        
                        Picker("", selection: self.$selectedMinute) {
                            ForEach(0..<60) {
                                
                                Text("\(String($0)) mins").tag($0)
                            }
                        }
                        .labelsHidden()
                        .fixedSize(horizontal: true, vertical: true)
                        .frame(width: geometry.size.width / widthDiviser, height: height)
                        .clipped()
                        
                        Spacer()
                        
                    }
                
            
        }
        .frame(height: height)
        .mask(Rectangle())
        }.edgesIgnoringSafeArea(.all)
        
    }
}


struct CountDownPicker_Previews: PreviewProvider {
    static var previews: some View {
        CountDownPicker(selectedHour: .constant(0), selectedMinute: .constant(0), selectedDay: .constant(0))
    }
}
