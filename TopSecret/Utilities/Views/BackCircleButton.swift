//
//  BackCircleButton.swift
//  Top Secret
//
//  Created by Bruce Blake on 3/4/22.
//

import SwiftUI

struct BackCircleButton: View {
    var action: () -> Void
    var body: some View {
        
        Button(action:{
            action()
        },label:{
            ZStack{
                Circle().foregroundColor(Color("Color")).frame(width: 32, height: 32)
                
                Image(systemName: "chevron.left")
                    .font(.title3).foregroundColor(FOREGROUNDCOLOR)
            }
        })
    }
}

